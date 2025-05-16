function [BasinArea, varargout] = ClipInfo(app)
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
warning off

nw = 22;
pnw = 1;

% Nombre de la región 
NameRegion  = app.AppVWBA.NameRegion;

% Progress bar
wb = waitbar(0, 'Processing ... ','Color',[1 1 1]);


% -------------------------------------------------------------------------
% Coberturas
% -------------------------------------------------------------------------
% Leer raster de coberturas futuras
LULC = GRIDobj( fullfile(app.AppVWBA.DataBasePath,'LULC','Historic',['LULC_',NameRegion,'.tif']) );
pnw = pnw + 1;
try
    waitbar(pnw/nw, wb,'Processing ... ');
catch
    wb = waitbar(pnw/nw, 'Processing ... ','Color',[1 1 1]);
end

% -------------------------------------------------------------------------
% Cuenca
% -------------------------------------------------------------------------
% Leer shapefile de la cuenca
ShpBasin    = shaperead(fullfile(app.ProjectPath,'01-Basins','Basin.shp'));
% Convertir Shp a raster
Basin       = polygon2GRIDobj(LULC,ShpBasin);
% Cambiar formato de datos a singles
Basin.Z     = single(Basin.Z);
% Asignar NaN a valores 0waitbar(0
Basin.Z(Basin.Z == 0) = NaN;
% Progress bar
pnw = pnw + 1;
try
    waitbar(pnw/nw, wb,'Processing ... ');
catch
    wb = waitbar(pnw/nw, 'Processing ... ','Color',[1 1 1]);
end

% Basin Area (m2)
BasinArea = double(sum(Basin.Z(:),'omitnan').*(Basin.cellsize*110567)^2);
app.AppVWBA.BasinArea = BasinArea;

% -------------------------------------------------------------------------
% Rios Hydroshed
% -------------------------------------------------------------------------
% leer
Rivers  = shaperead(fullfile(app.AppVWBA.DataBasePath,'Rivers',['Rivers_',NameRegion,'.shp']) );
% Leer los boundary de los tramos de río
Fun     = @(x) sum(x)/2;
Points  = cell2mat(cellfun(Fun,{Rivers.BoundingBox}','UniformOutput',false));
% Identificar que tramos están dentro
id      = inpolygon(Points(:,1),Points(:,2),[ShpBasin.X],[ShpBasin.Y]);
% Eliminar tramos que estan por fuera
Rivers  = Rivers(id);
% Longitud total de ríos
LengthRivers = sum([Rivers.LENGTH_KM]);
% Guardar shp de ríos para la cuenca
shapewrite(Rivers, fullfile(app.ProjectPath,'01-Basins','Rivers.shp') )
% Progress bar
pnw = pnw + 1;
try
    waitbar(pnw/nw, wb,'Processing ... ');
catch
    wb = waitbar(pnw/nw, 'Processing ... ','Color',[1 1 1]);
end

% -------------------------------------------------------------------------
% Lakes (Raster)
% -------------------------------------------------------------------------
% Leer raster 
Lakes  = GRIDobj( fullfile(app.AppVWBA.DataBasePath,'Lakes',['Lake_',NameRegion,'.tif']) );
% Alinear pixel al raster de coberturas y recortar extensión con NaN
Lakes  = crop(resample(Lakes,LULC,'nearest').*Basin);
%sistema de referencia
% Spatial Reference LULC 
RLULC = georefpostings();
RLULC.LatitudeLimits            = Lakes.georef.SpatialRef.YWorldLimits;
RLULC.LongitudeLimits           = Lakes.georef.SpatialRef.XWorldLimits;
RLULC.RasterSize                = Lakes.size;
RLULC.ColumnsStartFrom          = 'north';
RLULC.RowsStartFrom             = 'west';
% Guardar raster
geotiffwrite(fullfile(app.ProjectPath,'02-Biophysic','Lakes.tif') ,Lakes.Z,RLULC)
% Área de humedales
Lakes.Z(isnan(Lakes.Z)) = 0;
LakesArea = double(sum(Lakes.Z(:))./10)*1E4;
% Progress bar
pnw = pnw + 1;
try
    waitbar(pnw/nw, wb,'Processing ... ');
catch
    wb = waitbar(pnw/nw, 'Processing ... ','Color',[1 1 1]);
end

% -------------------------------------------------------------------------
% DEM
% -------------------------------------------------------------------------
% Leer raster 
DEM     = GRIDobj( fullfile(app.AppVWBA.DataBasePath,'DEM',['DEM_',NameRegion,'.tif']) );
Slope   = DEM.gradient8('degree');
% Alinear pixel al raster de coberturas y recortar extensión con NaN
DEM     = crop(resample(DEM,LULC,'nearest').*Basin);
Slope   = crop(resample(Slope,LULC,'nearest').*Basin);
% Guardar raster
geotiffwrite(fullfile(app.ProjectPath,'02-Biophysic','DEM.tif') ,DEM.Z,RLULC)
geotiffwrite(fullfile(app.ProjectPath,'02-Biophysic','Slope.tif') ,Slope.Z,RLULC)
% Progress bar
pnw = pnw + 1;
try
    waitbar(pnw/nw, wb,'Processing ... ');
catch
    wb = waitbar(pnw/nw, 'Processing ... ','Color',[1 1 1]);
end

% -------------------------------------------------------------------------
% Load Countries Polygon
% -------------------------------------------------------------------------
% Leer shapefile de la cuenca
ShpC    = shaperead(fullfile(app.AppVWBA.DataBasePath,'Countries','Countries.shp'));
% Convertir Shp a raster
C       = polygon2GRIDobj(DEM,ShpC,'Code');
% Cambiar formato de datos a singles
C.Z     = single(C.Z);
% Asignar NaN a valores (0)
C.Z       = C.Z.*~isnan(DEM.Z);
C.Z(C.Z == 0) = NaN;
% Guardar raster
geotiffwrite(fullfile(app.ProjectPath,'02-Biophysic','Countries.tif') ,C.Z,RLULC)
% Progress bar
pnw = pnw + 1;
try
    waitbar(pnw/nw, wb,'Processing ... ');
catch
    wb = waitbar(pnw/nw, 'Processing ... ','Color',[1 1 1]);
end

% -------------------------------------------------------------------------
% Cobertura linea base
% -------------------------------------------------------------------------
% Leer raster 
LULC_BaU  = GRIDobj( fullfile(app.AppVWBA.DataBasePath,'LULC','Future',['LULC_',NameRegion,'.tif']) );
% Alinear pixel al raster de coberturas y recortar extensión con NaN
LULC_BaU  = crop(resample(LULC_BaU,LULC,'nearest').*Basin);
% Guardar raster
geotiffwrite(fullfile(app.ProjectPath,'02-Biophysic','LULC_BaU.tif') ,LULC_BaU.Z, RLULC)
% Progress bar
pnw = pnw + 1;
try
    waitbar(pnw/nw, wb,'Processing ... ');
catch
    wb = waitbar(pnw/nw, 'Processing ... ','Color',[1 1 1]);
end

% -------------------------------------------------------------------------
% Biodiversity
% -------------------------------------------------------------------------
% Leer raster 
Bio  = GRIDobj( fullfile(app.AppVWBA.DataBasePath,'Bio',['Bio_',NameRegion,'.tif']) );
% Alinear pixel al raster de coberturas y recortar extensión con NaN
Bio.Z(isnan(Bio.Z)) = -999;
Bio  = crop(resample(Bio,LULC,'nearest').*Basin);
Bio.Z(Bio.Z == -999) = NaN;
% Estimar áreas de categorias. Este raster tiene valores de 1 a 100, donde 
% 1 indica prioridad 1 para la biodiveridad y 100 la ultima prioridad para
% la conservación. En este orden de ideas, las categorias estan dadas por
% 00 - 20   -> Very high
% 20 - 40   -> High
% 40 - 60   -> Medium
% 60 - 80   -> Low
% 80 - 100  -> Very Low
VCat = [0 20:20:100]';
AreaBio = VCat*0;
for i = 1:numel(VCat)-1
    AreaBio(i) = sum( (Bio.Z(:) > VCat(i)).*(Bio.Z(:) <= VCat(i+1)) ).*((LULC.cellsize*110567)^2);
end
% Guardar raster
geotiffwrite(fullfile(app.ProjectPath,'02-Biophysic','ImpBio.tif') ,Bio.Z, RLULC)
% Progress bar
pnw = pnw + 1;
try
    waitbar(pnw/nw, wb,'Processing ... ');
catch
    wb = waitbar(pnw/nw, 'Processing ... ','Color',[1 1 1]);
end

% -------------------------------------------------------------------------
% MSA (factor de escala 1000)
% -------------------------------------------------------------------------
% Leer raster 
MSA     = GRIDobj( fullfile(app.AppVWBA.DataBasePath,'MSA',['MSA_',NameRegion,'.tif']) );
% Alinear pixel al raster de coberturas y recortar extensión con NaN
MSA = crop(resample(MSA,LULC,'nearest').*Basin);
% Guardar raster
geotiffwrite(fullfile(app.ProjectPath,'02-Biophysic','MSA.tif') ,MSA.Z, RLULC)
% Progress bar
pnw = pnw + 1;
MSA_Mean = [min(MSA.Z(:)) mean(MSA.Z(:),"omitmissing") max(MSA.Z(:))]/1000;
try
    waitbar(pnw/nw, wb,'Processing ... ');
catch
    wb = waitbar(pnw/nw, 'Processing ... ','Color',[1 1 1]);
end

% -------------------------------------------------------------------------
% People
% -------------------------------------------------------------------------
% Leer raster 
Pe = GRIDobj( fullfile(app.AppVWBA.DataBasePath,'People',['People_',NameRegion,'.tif']) );
Pe.Z = Pe.Z./((Pe.cellsize*110567)^2);
% Alinear pixel al raster de coberturas y recortar extensión con NaN
Pe = crop(resample(Pe,LULC,'nearest').*Basin);
Pe = resample(Pe,crop(Basin),'nearest');
% Guardar raster
geotiffwrite(fullfile(app.ProjectPath,'02-Biophysic','People.tif') ,Pe.Z, RLULC)
% Progress bar
pnw = pnw + 1;
People = double(round(sum(Pe.Z(:),"omitmissing").*((Pe.cellsize*110567)^2),0));
try
    waitbar(pnw/nw, wb,'Processing ... ');
catch
    wb = waitbar(pnw/nw, 'Processing ... ','Color',[1 1 1]);
end

% -------------------------------------------------------------------------
% Precipitación
% -------------------------------------------------------------------------
% Leer raster 
P  = GRIDobj( fullfile(app.AppVWBA.DataBasePath,'P','Year',['P_',NameRegion,'.tif']) );
% Alinear pixel al raster de coberturas y recortar extensión con NaN
P  = crop(resample(P,LULC,'nearest').*Basin);
% Guardar raster
geotiffwrite(fullfile(app.ProjectPath,'02-Biophysic','P.tif') ,P.Z, RLULC)
% Progress bar
pnw = pnw + 1;
try
    waitbar(pnw/nw, wb,'Processing ... ');
catch
    wb = waitbar(pnw/nw, 'Processing ... ','Color',[1 1 1]);
end

% -------------------------------------------------------------------------
% Evapotranspiración
% -------------------------------------------------------------------------
% Leer raster
ETP = GRIDobj( fullfile(app.AppVWBA.DataBasePath,'ETP','Year',['ETP_',NameRegion,'.tif']) );
% Alinear pixel al raster de coberturas y recortar extensión con NaN
ETP = crop(resample(ETP,LULC,'nearest').*Basin);
% Guardar raster
geotiffwrite(fullfile(app.ProjectPath,'02-Biophysic','ETP.tif') ,ETP.Z, RLULC)
% Progress bar
pnw = pnw + 1;
try
    waitbar(pnw/nw, wb,'Processing ... ');
catch
    wb = waitbar(pnw/nw, 'Processing ... ','Color',[1 1 1]);
end

% -------------------------------------------------------------------------
% CC
% -------------------------------------------------------------------------
% Leer raster
CC  = GRIDobj( fullfile(app.AppVWBA.DataBasePath,'CC',['CC_',NameRegion,'.tif']) );
% Alinear pixel al raster de coberturas y recortar extensión con NaN
CC  = crop(resample(CC,LULC,'nearest').*Basin);
% Guardar raster
geotiffwrite(fullfile(app.ProjectPath,'02-Biophysic','CC.tif') ,CC.Z, RLULC)
% Progress bar
pnw = pnw + 1;
try
    waitbar(pnw/nw, wb,'Processing ... ');
catch
    wb = waitbar(pnw/nw, 'Processing ... ','Color',[1 1 1]);
end

% -------------------------------------------------------------------------
% PMP
% -------------------------------------------------------------------------
% Leer raster
PMP  = GRIDobj( fullfile(app.AppVWBA.DataBasePath,'PMP',['PMP_',NameRegion,'.tif']) );
% Alinear pixel al raster de coberturas y recortar extensión con NaN
PMP = crop(resample(PMP,LULC,'nearest').*Basin);
% Guardar raster
geotiffwrite(fullfile(app.ProjectPath,'02-Biophysic','PMP.tif') ,PMP.Z, RLULC)
% Progress bar
pnw = pnw + 1;
try
    waitbar(pnw/nw, wb,'Processing ... ');
catch
    wb = waitbar(pnw/nw, 'Processing ... ','Color',[1 1 1]);
end

% -------------------------------------------------------------------------
% Smax
% -------------------------------------------------------------------------
% Leer raster
Smax  = GRIDobj( fullfile(app.AppVWBA.DataBasePath,'Smax',['Smax_',NameRegion,'.tif']) );
% Alinear pixel al raster de coberturas y recortar extensión con NaN
Smax  = crop(resample(Smax,LULC,'nearest').*Basin);
% Guardar raster
geotiffwrite(fullfile(app.ProjectPath,'02-Biophysic','Smax.tif') ,Smax.Z, RLULC)
% Progress bar
pnw = pnw + 1;
try
    waitbar(pnw/nw, wb,'Processing ... ');
catch
    wb = waitbar(pnw/nw, 'Processing ... ','Color',[1 1 1]);
end

% -------------------------------------------------------------------------
% BD
% -------------------------------------------------------------------------
% Leer raster de número de Curva
BD  = GRIDobj( fullfile(app.AppVWBA.DataBasePath,'BD',['BD_',NameRegion,'.tif']) );
% Alinear pixel al raster de coberturas y recortar extensión con NaN
BD  = crop(resample(BD,LULC,'nearest').*Basin);
% Guardar raster
geotiffwrite(fullfile(app.ProjectPath,'02-Biophysic','BD.tif') ,BD.Z, RLULC)
% Progress bar
pnw = pnw + 1;
try
    waitbar(pnw/nw, wb,'Processing ... ');
catch
    wb = waitbar(pnw/nw, 'Processing ... ','Color',[1 1 1]);
end
%}
% -------------------------------------------------------------------------
% Soil Groups
% -------------------------------------------------------------------------
% Leer raster
SG  = GRIDobj( fullfile(app.AppVWBA.DataBasePath,'SG',['SoilGroup_',NameRegion,'.tif']) );
% Alinear pixel al raster de coberturas y recortar extensión con NaN
SG  = crop(resample(SG,LULC,'nearest').*Basin);
% Guardar raster
geotiffwrite(fullfile(app.ProjectPath,'02-Biophysic','SG.tif') ,SG.Z, RLULC)
% Progress bar
pnw = pnw + 1;
try
    waitbar(pnw/nw, wb,'Processing ... ');
catch
    wb = waitbar(pnw/nw, 'Processing ... ','Color',[1 1 1]);
end

% -------------------------------------------------------------------------
% Soil Depth
% -------------------------------------------------------------------------
% Leer raster
SD  = GRIDobj( fullfile(app.AppVWBA.DataBasePath,'Soil_Depth',['Soil_Depth_',NameRegion,'.tif']) );
% Alinear pixel al raster de coberturas y recortar extensión con NaN
SD  = crop(resample(SD,LULC,'nearest').*Basin);
% Se limita la profundidad del suelo a 500 mm para los análisis del SWY
SD.Z(SD.Z>500) = 500;
% Guardar raster
geotiffwrite(fullfile(app.ProjectPath,'02-Biophysic','Soil_Depth.tif') ,SD.Z, RLULC)
% Progress bar
pnw = pnw + 1;
try
    waitbar(pnw/nw, wb,'Processing ... ');
catch
    wb = waitbar(pnw/nw, 'Processing ... ','Color',[1 1 1]);
end

% -------------------------------------------------------------------------
% Ks
% -------------------------------------------------------------------------
% Leer raster
Ks  = GRIDobj( fullfile(app.AppVWBA.DataBasePath,'Ks',['Ks_',NameRegion,'.tif']) );
% Alinear pixel al raster de coberturas y recortar extensión con NaN
Ks  = crop(resample(Ks,LULC,'nearest').*Basin);
% Guardar raster
geotiffwrite(fullfile(app.ProjectPath,'02-Biophysic','Ks.tif') ,Ks.Z, RLULC)
% Progress bar
pnw = pnw + 1;
try
    waitbar(pnw/nw, wb,'Processing ... ');
catch
    wb = waitbar(pnw/nw, 'Processing ... ','Color',[1 1 1]);
end

% -------------------------------------------------------------------------
% recorte
% -------------------------------------------------------------------------
% Alinear pixel al raster de coberturas y recortar extensión con NaN
LULC    = crop(LULC.*Basin);
% Guardar raster
geotiffwrite(fullfile(app.ProjectPath,'02-Biophysic','LULC.tif') ,LULC.Z, RLULC)
% Área de bosque
ForestArea = sum(LULC.Z(:) == 2)*((LULC.cellsize*110567)^2);
% Progress bar
pnw = pnw + 1;
try
    waitbar(pnw/nw, wb,'Processing ... ');
catch
    wb = waitbar(pnw/nw, 'Processing ... ','Color',[1 1 1]);
end

% -------------------------------------------------------------------------
% Crear raster de CN
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

% Leer Número de curvas
Table  = readmatrix( fullfile(app.AppVWBA.DataBasePath,'CN.csv'));
Table = Table(:,3:end);
CN = SG;
for i = 0:8
    for j = 1:4
        CN.Z((LULC_BaU.Z == i)&(SG.Z == j)) = Table(i+1,j);
    end
end
% Guardar raster
geotiffwrite(fullfile(app.ProjectPath,'02-Biophysic','CN.tif') ,CN.Z, RLULC)
% Progress bar
pnw = pnw + 1;
try
    waitbar(pnw/nw, wb,'Processing ... ');
catch
    wb = waitbar(pnw/nw, 'Processing ... ','Color',[1 1 1]);
end

% -------------------------------------------------------------------------
% Soil Organic Carbon
% -------------------------------------------------------------------------
% Leer SOC
SOC = SG;
CS  = SG;
for i = 0:8
    % SOC (Ton/ha -> Ton)
    SOC.Z(LULC.Z == i) = Table(i+1,5)*(((Basin.cellsize*110567)^2)/10000);
    % CS
    CS.Z(LULC.Z == i) = Table(i+1,6);
end
% Guardar raster
geotiffwrite(fullfile(app.ProjectPath,'02-Biophysic','SOC.tif') ,SOC.Z, RLULC)
% Guardar raster
geotiffwrite(fullfile(app.ProjectPath,'02-Biophysic','CS.tif') ,CS.Z, RLULC)
% Progress bar
pnw = pnw + 1;
try
    waitbar(pnw/nw, wb,'Processing ... ');
catch
    wb = waitbar(pnw/nw, 'Processing ... ','Color',[1 1 1]);
end

% -------------------------------------------------------------------------
% Procesar datos de precipitación para la cuenca
% -------------------------------------------------------------------------
Processing_TS_P(app.AppVWBA.ProjectPath,app.AppVWBA.DataBasePath);

% -------------------------------------------------------------------------
% Procesar datos de evapotranspiración para la cuenca
% -------------------------------------------------------------------------
Processing_TS_ETP(app.AppVWBA.ProjectPath,app.AppVWBA.DataBasePath);

% -------------------------------------------------------------------------
% Canopy Storage
% -------------------------------------------------------------------------
Processing_TS_CS(app.AppVWBA)

% Progress
close(wb);

% -------------------------------------------------------------------------
% Outputs
% -------------------------------------------------------------------------
% Area of forest in the basin (m^2)
varargout{1} = ForestArea;
% Length of rivers in the basin (km)
varargout{2} = LengthRivers;
% Wetland area in the basin (m^2)
varargout{3} = LakesArea;
% Areas of importance for biodiversity (m^2)
varargout{4} = AreaBio;
% Number of people
varargout{5} = People;
% Potential intervention area for conservation and restoration (m^2)
varargout{6} = sum(sum(LULC.Z(:) == [2 3 6 7 8]))*((Basin.cellsize*110567)^2);
% Potential intervention area for agricultural practices BMPs (m^2)
varargout{7} = sum(sum(LULC.Z(:) == 4))*((Basin.cellsize*110567)^2);
% Species abundance (MSA)
varargout{8}  = MSA_Mean;