function Processing_TS_P(ProjectPath,DataBasePath)
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

% ProgressBar = waitbar(0, 'Processing precipitation data from the global database','Color',[1 1 1]);
% wbch        = allchild(ProgressBar);
% jp          = wbch(1).JavaPeer;
% jp.setIndeterminate(1)


% Leer cuenca raster
BasinShp     = shaperead(fullfile(ProjectPath,'01-Basins','Basin.shp'));

% -------------------------------------------------------------
%Leer serie de tiempo de los pixeles donde está la cuenca
% -------------------------------------------------------------
% Abrir archivo de precipitación
Tmp = matfile(fullfile(DataBasePath,'P','P.mat'));
% lectura de Longitud
Lon = Tmp.Lon;
% Lectura de latitud
Lat = flip(Tmp.Lat);
% Date
Date = Tmp.Date;

% Posición X
ix = [];
mf = 0;
while isempty(ix)
    ix = find((Lon > (BasinShp.BoundingBox(1,1)-mf))&(Lon < (BasinShp.BoundingBox(2,1)+mf)));
    mf = mf + 0.05;
end

% Posición Y
iy = [];            
mf = 0;
while isempty(iy)
    iy = find((Lat > (BasinShp.BoundingBox(1,2)-mf))&(Lat < (BasinShp.BoundingBox(2,2)+mf)));
    mf = mf + 0.05;
end

% Promedio para la cuenca
P = permute(mean(Tmp.Data(iy,ix,:),[1 2],'omitnan'),[1,3,2])';

% Escribir serie de tiempo
TS_Path = fullfile(ProjectPath,'02-Biophysic','P.csv');
ID_File = fopen(TS_Path,'w');
fprintf(ID_File,'Year,Month,day,Precipitation (mm)\n');
fprintf(ID_File,'%d,%d,%d,%f\n', [year(Date) month(Date) day(Date) P]');
fclose('all');

% Close waitbar
% close(ProgressBar)
