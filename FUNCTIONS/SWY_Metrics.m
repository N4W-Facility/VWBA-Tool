function [VWB_R, VWB_Sw] = SWY_Metrics(app,Ap)
% -------------------------------------------------------------------------
% Matlab Version - R2023b 
% -------------------------------------------------------------------------
%                              BASE DATA 
% -------------------------------------------------------------------------
% The Nature Conservancy - TNC
% 
% Project     : Herramienta de Beneficios Volumetricos
% 
% Author      : Jonathan Nogales Pimentel
%               Hydrology Specialist
%               jonathan.nogales@tnc.org
% 
% Date        : Mayo, 2024
% 
% -------------------------------------------------------------------------
% This program is free software: you can redistribute it and/or modify it 
% under the terms of the GNU General Public License as published by the 
% Free Software Foundation, either version 3 of the License, or option) any 
% later version. This program is distributed in the hope that it will be 
% useful, but WITHOUT ANY WARRANTY; without even the implied warranty of 
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. 
% ee the GNU General Public License for more details. You should have 
% received a copy of the GNU General Public License along with this program
% If not, see http://www.gnu.org/licenses/.

ProgressBar = waitbar(0, 'Processing ...','Color',[1 1 1]);
wbch        = allchild(ProgressBar);
jp          = wbch(1).JavaPeer;
jp.setIndeterminate(1)

% Leer precipitación
TS_Path = fullfile(app.AppVWBA.ProjectPath,'02-Biophysic','P.csv');
% Leer serie de tiempo
[ErrorStatus, P, Date] = app.AppVWBA.Read_TS(TS_Path);            
if ErrorStatus
    return
end

% Leer evapotrasnpiración
TS_Path = fullfile(app.AppVWBA.ProjectPath,'02-Biophysic','ETP.csv');
% Leer serie de tiempo
[ErrorStatus, ET, Date] = app.AppVWBA.Read_TS(TS_Path);            
if ErrorStatus
    return
end                      

% Leer canopy storage
TS_Path = fullfile(app.AppVWBA.ProjectPath,'02-Biophysic','CS.csv');
% Leer serie de tiempo
[ErrorStatus, CS, Date] = app.AppVWBA.Read_TS(TS_Path);            
if ErrorStatus
    return
end

% Crear portafolio
Path_Porfolio = fullfile(app.AppVWBA.ProjectPath,'03-Porfolio','Portfolio_Metrics.tif');
[CheckArea,FinalArea] = Porfolio_CR_V2(app.AppVWBA,Ap,Path_Porfolio);

if CheckArea
    app.AreaInter.Value = double(FinalArea);
end

% Leer CN de cobeturas actuales
CNH     = CN_Without_AgriPrac(app.AppVWBA);

% Leer CN de coberturas futuras
CNF     = CN_With_CR(app.AppVWBA,Path_Porfolio);

% Ejecutar Metodo Anexo 1 - Histórico
QH      = Method_A1(P, CNH);

% Ejecutar Metodo Anexo 1 - Futuro
QF      = Method_A1(P, CNF);

% Leer Smax
Smax    = Smax_Avg(app.AppVWBA);

% Leer CC
CC      = CC_Avg(app.AppVWBA);

% Conductividad hidráulica
Ks      = Ks_Avg(app.AppVWBA);

% Aplicar metodo para condición SbN
[RH, SwH] = Method_A15(P, ET, CS, QH, Smax, CC, Ks);

% Aplicar metodo para condición SbN
[RF, SwF] = Method_A15(P, ET, CS, QF, Smax, CC, Ks);

% SPI
[DateSPI, SPI, DroughtClass] = Index_SPI(Date, P, 'Index','SPI','SizeStep',1);
     
% Agua disponible para las plantas
PWA = PWA_Avg(app.AppVWBA);

[VWB_R, VWB_Sw] = Plot_TS_SWY(app.AppVWBA.ProjectPath, DateSPI, SPI, DroughtClass, Date, P, SwH, SwF, RH, RF, app.AppVWBA.BasinArea, PWA, false);

close(ProgressBar)