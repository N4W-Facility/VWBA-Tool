function Porfolio_AgriPrac(app,Ap)
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

% Nombre de la región 
NameRegion = app.NameRegion;

% Start waitbar
wb = waitbar(0.1,'Starting processing','Color',[1 1 1]);

% -------------------------------------------------------------------------
% Coberturas
% -------------------------------------------------------------------------
% Leer raster de coberturas futuras
LULC        = GRIDobj( fullfile(app.ProjectPath,'02-Biophysic','LULC.tif') );
LULC_BaU    = GRIDobj( fullfile(app.ProjectPath,'02-Biophysic','LULC_BaU.tif') );
waitbar(0.15,wb,['Processing - Region: ', NameRegion]);

% -------------------------------------------------------------------------
% Cuenca
% -------------------------------------------------------------------------
ShpBasin    = shaperead(fullfile(app.ProjectPath,'01-Basins','Basin.shp'));
Basin       = polygon2GRIDobj(LULC,ShpBasin);
Basin.Z     = single(Basin.Z);
Basin.Z(Basin.Z == 0) = NaN;
PixelArea   = (Basin.cellsize*110567)^2;

% -------------------------------------------------------------------------
% Precipitación
% -------------------------------------------------------------------------
% Leer raster de precipitación
P  = GRIDobj( fullfile(app.ProjectPath,'02-Biophysic','P.tif'));
wb = waitbar(0.45,['Processing - Region: ', NameRegion]);

% -------------------------------------------------------------------------
% Evapotranspiración
% -------------------------------------------------------------------------
% Leer raster de vapotranspiración
ETP = GRIDobj( fullfile(app.ProjectPath,'02-Biophysic','ETP.tif') );
waitbar(0.60,wb,['Processing - Region: ', NameRegion]);

% -------------------------------------------------------------------------
% Número de curva
% -------------------------------------------------------------------------
% Leer raster de número de Curva
CN  = GRIDobj( fullfile(app.ProjectPath,'02-Biophysic','CN.tif') );
waitbar(0.75,wb,['Processing - Region: ', NameRegion]);

% -------------------------------------------------------------------------
% Priorización
% -------------------------------------------------------------------------
% Código coberturas
%     0	Ice
%     1	Water
%     2	Forest
%     3	Grassland
%     4	Agriculture
%     5	Urban
%     6	Bare Areas
%     7	Shrublands
%     8	Sparse Vegetation

% Escalamiento lineal de 0 a 1
Scaling     = @(x) ((1/(max(x) - min(x)))*x) - ((1/(max(x) - min(x)))*min(x)); 
% Detectar pixeles de cuenca. Solo se seleccionan los pixeles que tanto en 
% el escenario de linea base y BaU sean agrícolas 
DataP(:,1)  = find((LULC.Z == 4)&(LULC_BaU.Z == 4));
% Precipitación escalada
DataP(:,2)  = Scaling(P.Z(DataP(:,1)));
% Evapotranspiración escala
DataP(:,3)  = 1 - Scaling(ETP.Z(DataP(:,1)));
% Número de curva
DataP(:,4)  = Scaling(CN.Z(DataP(:,1)));
% Remplazar
DataP(isnan(DataP)) = 0;
% Priorización
Prio        = sum(DataP(:,2:4).*1/3,2);
% Ordenar de mayor a menor
[Prio, id]  = sort(Prio,'descend');
DataP       = DataP(id,:);
waitbar(0.9,wb,['Processing - Region: ', NameRegion]);

np = floor((Ap*1E4)./PixelArea);
% Portafolio
Porfolio = Basin*0;
if numel(Prio) > np
    Porfolio.Z(DataP(1:np,1)) = 1;
else
    Porfolio.Z(DataP(:,1)) = 1;
end

% Exportar raster de portafolio 
PorPath = fullfile(app.ProjectPath,'03-Porfolio','Portfolio_AgriPrac.tif');
Porfolio.GRIDobj2geotiff(PorPath);
% Progress
waitbar(1,wb,'Processing Ok');
close(wb);

%% mensaje
if numel(Prio) > np
    msgbox('Spatial distribution of the portfolio was successfully completed')
else
    app.Area_AgriPrac.Value = floor(numel(Prio)*PixelArea/1E4);
    warndlg(['Spatial distribution of the portfolio was successfully completed. ',...
            'However, the agricultural area of the analyzed basin only reaches ',...
            num2str(floor(numel(Prio)*PixelArea/1E4)),' ha. Therefore, consider using',...
            ' a lower intervention area for the analysis.'])
end

