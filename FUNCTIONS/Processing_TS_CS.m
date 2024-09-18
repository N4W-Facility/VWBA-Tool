function Processing_TS_CS(app)
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
% -------------------------------------------------------------------------
%                              DESCRIPTION
% -------------------------------------------------------------------------
% De acuerdo con sun et al. (2015), la efectividad de la labranza cero (NT) 
% para reducir la escorrentía superficial es entre un 21,9% y un 27,2%.
% Para efectos de la herramienta se considera un valor promedio de 24.5%.
% El CN con actividades se estima como el valor que genere una reducción
% del 24.5% en la escorrentía con una precipitación de igual al percentil
% del 95% de la serie de tiempo de precipitaciones globales.
%
% -------------------------------------------------------------------------
%                               REFERENCES
% -------------------------------------------------------------------------
% Sun, Y., Zeng, Y., Shi, Q., Pan, X., & Huang, S. (2015). No-tillage 
% controls on runoff: A meta-analysis. Soil and Tillage Research, 153, 1-6.
% https://www.sciencedirect.com/science/article/pii/S0167198715000884

ProgressBar = waitbar(0, 'Processing precipitation data from the global database','Color',[1 1 1]);
wbch        = allchild(ProgressBar);
jp          = wbch(1).JavaPeer;
jp.setIndeterminate(1)

% Leer serie de tiempo
TS_Path = fullfile(app.ProjectPath,'02-Biophysic','P.csv');
[ErrorStatus, P, Date] = app.Read_TS(TS_Path);            
if ErrorStatus
    return
end

% Leer Smax
CS      = GRIDobj( fullfile(app.ProjectPath,'02-Biophysic','CS.tif') );
CS.Z(CS.Z == 0) = NaN;

% Average CN
CS_TS   = P.*(double(mean(CS.Z(:),'omitnan'))/100);

% Escribir serie de tiempo
TS_Path = fullfile(app.ProjectPath,'02-Biophysic','CS.csv');
ID_File = fopen(TS_Path,'w');
fprintf(ID_File,'Year,Month,day,Canopy Storage (mm)\n');
fprintf(ID_File,'%d,%d,%d,%f\n', [year(Date) month(Date) day(Date) CS_TS]');
fclose('all');

% Close waitbar
close(ProgressBar)