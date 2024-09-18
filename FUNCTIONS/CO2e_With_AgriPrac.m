function CO2e = CO2e_With_AgriPrac(app)
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

ProgressBar = waitbar(0, 'Processing precipitation data from the global database','Color',[1 1 1]);
wbch        = allchild(ProgressBar);
jp          = wbch(1).JavaPeer;
jp.setIndeterminate(1)

% Leer portafolio
Porfolio    = GRIDobj( fullfile(app.ProjectPath,'03-Porfolio','Portfolio_AgriPrac.tif') );

% Leer Curver number
SOC        = GRIDobj( fullfile(app.ProjectPath,'02-Biophysic','SOC.tif') );

% Aumentar
SOC.Z(Porfolio.Z == 1) = SOC.Z(Porfolio.Z == 1)*1.027;

% Average CN
CO2e       = double(round(sum(SOC.Z(:),'omitnan'),0))*3.67;

% Close waitbar
close(ProgressBar)