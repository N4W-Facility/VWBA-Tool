function [CheckArea,FinalArea] = Porfolio_CR_V2(app, Ap, PorPath)
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


ProgressBar = waitbar(0, 'Processing portfolio...','Color',[1 1 1]);
wbch        = allchild(ProgressBar);
jp          = wbch(1).JavaPeer;
jp.setIndeterminate(1)

% -------------------------------------------------------------------------
% Coberturas
% -------------------------------------------------------------------------
% Leer raster de coberturas históricas
LULC  = GRIDobj( fullfile(app.ProjectPath,'02-Biophysic','LULC.tif') );

% Leer raster de coberturas futuras
LULC_BaU = GRIDobj( fullfile(app.ProjectPath,'02-Biophysic','LULC_BaU.tif') );

% -------------------------------------------------------------------------
% Pixel
% -------------------------------------------------------------------------
PixelArea   = (LULC.cellsize*110567)^2;

% -------------------------------------------------------------------------
% Precipitación
% -------------------------------------------------------------------------
% Leer raster de precipitación
P  = GRIDobj( fullfile(app.ProjectPath,'02-Biophysic','P.tif'));

% -------------------------------------------------------------------------
% Evapotranspiración
% -------------------------------------------------------------------------
% Leer raster de vapotranspiración
ETP = GRIDobj( fullfile(app.ProjectPath,'02-Biophysic','ETP.tif') );

% -------------------------------------------------------------------------
% Número de curva
% -------------------------------------------------------------------------
% Leer raster de número de Curva
CN  = GRIDobj( fullfile(app.ProjectPath,'02-Biophysic','CN.tif') );

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

TotalArea   = 0;
%% Bosque
% Detectión de área de bosque que han sido degradada
Def         = find((LULC.Z == 2)~=(LULC_BaU.Z == 2));
% Portafolio
Porfolio    = LULC_BaU*0;
% Escalamiento lineal de 0 a 1
Scaling     = @(x) ((1/(max(x) - min(x)))*x) - ((1/(max(x) - min(x)))*min(x)); 
% Detectar pixeles de cuenca
DataP(:,1)  = Def;
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

% ha -> m2
Ap = (Ap*1E4);

np = floor(Ap./PixelArea);
if numel(Prio) > np
    Porfolio.Z(DataP(1:np,1))   = 2;
    Ap = 0;
    TotalArea = TotalArea + np;
else
    Porfolio.Z(DataP(:,1))      = 2;
    Ap = Ap - (numel(Prio)*PixelArea);
    TotalArea = TotalArea + numel(Prio);
end

clearvars DataP

%% Sparse Vegetation
% Detectión de cobertura
Def         = find((LULC.Z == 8)&(Porfolio.Z==0));
if (Ap > 0)&~isempty(Def)
    % Escalamiento lineal de 0 a 1
    Scaling     = @(x) ((1/(max(x) - min(x)))*x) - ((1/(max(x) - min(x)))*min(x)); 
    % Detectar pixeles de cuenca
    DataP(:,1)  = Def;
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
    
    np = floor(Ap./PixelArea);
    if numel(Prio) > np
        % Pixeles priorizados
        PoPo    = DataP(1:np,1);
        Porfolio.Z(PoPo) = 7;
        % Pixeles donde la cobertura en el escenario BaU es mejor
        idBest  = (LULC_BaU.Z(PoPo) == 2);                
        Porfolio.Z(PoPo(idBest))    = 2;           
        % Restar área
        Ap = 0;
        % Sumar Area total de intervención
        TotalArea = TotalArea + np;
    else
        % Pixeles priorizados
        PoPo    = DataP(:,1);
        Porfolio.Z(PoPo) = 7;
        % Pixeles donde la cobertura en el escenario BaU es mejor
        idBest  = (LULC_BaU.Z(PoPo) == 2);                 
        Porfolio.Z(PoPo(idBest))    = 2;          
        % Restar área
        Ap = Ap - (numel(Prio)*PixelArea);
        % Sumar Area total de intervención
        TotalArea = TotalArea + numel(Prio);
    end
    clearvars DataP
end

%% Shrublands
% Detectión de cobertura
Def         = find((LULC.Z == 7)&(Porfolio.Z==0));
if (Ap > 0)&~isempty(Def)
    % Escalamiento lineal de 0 a 1
    Scaling     = @(x) ((1/(max(x) - min(x)))*x) - ((1/(max(x) - min(x)))*min(x)); 
    % Detectar pixeles de cuenca
    DataP(:,1)  = Def;
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
    
    np = floor(Ap./PixelArea);
    if numel(Prio) > np
        % Pixeles priorizados
        PoPo    = DataP(1:np,1);
        % Pixeles donde la cobertura en el escenario BaU es mejor
        Porfolio.Z(PoPo) = 2; 
        % Restar área
        Ap = 0;
        % Sumar Area total de intervención
        TotalArea = TotalArea + np;
    else
        % Pixeles priorizados
        PoPo    = DataP(:,1);
        % Pixeles donde la cobertura en el escenario BaU es mejor 
        Porfolio.Z(PoPo) = 2;
        % Restar área
        Ap = Ap - (numel(Prio)*PixelArea);
        % Sumar Area total de intervención
        TotalArea = TotalArea + numel(Prio);
    end
    clearvars DataP
end


%% Bare Areas
% Detectión de cobertura
Def         = find((LULC.Z == 6)&(Porfolio.Z==0));
if (Ap > 0)&~isempty(Def)
    % Escalamiento lineal de 0 a 1
    Scaling     = @(x) ((1/(max(x) - min(x)))*x) - ((1/(max(x) - min(x)))*min(x)); 
    % Detectar pixeles de cuenca
    DataP(:,1)  = Def;
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
    
    np = floor(Ap./PixelArea);
    if numel(Prio) > np
        % Pixeles priorizados
        PoPo    = DataP(1:np,1);
        Porfolio.Z(PoPo) = 8;
        % Pixeles donde la cobertura en el escenario BaU es mejor
        idBest  = (LULC_BaU.Z(PoPo) == 2);                  
        Porfolio.Z(PoPo(idBest))    = 2;  
        idBest  = (LULC_BaU.Z(PoPo) == 7);
        Porfolio.Z(PoPo(idBest))    = 7;         
        % Restar área
        Ap = 0;
        % Sumar Area total de intervención
        TotalArea = TotalArea + np;
    else
        % Pixeles priorizados
        PoPo    = DataP(:,1);
        Porfolio.Z(PoPo) = 8; 
        % Pixeles donde la cobertura en el escenario BaU es mejor
        idBest  = (LULC_BaU.Z(PoPo) == 2);                  
        Porfolio.Z(PoPo(idBest))    = 2;  
        idBest  = (LULC_BaU.Z(PoPo) == 7);
        Porfolio.Z(PoPo(idBest))    = 7;                 
        % Restar área
        Ap = Ap - (numel(Prio)*PixelArea);
        % Sumar Area total de intervención
        TotalArea = TotalArea + numel(Prio);
    end
    clearvars DataP
end

%% Grassland
% Detectión de cobertura
Def         = find((LULC.Z == 3)&(Porfolio.Z==0));
if (Ap > 0)&~isempty(Def)
    % Escalamiento lineal de 0 a 1
    Scaling     = @(x) ((1/(max(x) - min(x)))*x) - ((1/(max(x) - min(x)))*min(x)); 
    % Detectar pixeles de cuenca
    DataP(:,1)  = Def;
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
    
    np = floor(Ap./PixelArea);
    if numel(Prio) > np
        % Pixeles priorizados
        PoPo    = DataP(1:np,1);
        Porfolio.Z(PoPo) = 7; 
        % Pixeles donde la cobertura en el escenario BaU es mejor
        idBest  = (LULC_BaU.Z(PoPo) == 2);                
        Porfolio.Z(PoPo(idBest))    = 2;          
        % Restar área
        Ap = 0;
        % Sumar Area total de intervención
        TotalArea = TotalArea + np;
    else
        % Pixeles priorizados
        PoPo    = DataP(:,1);
        Porfolio.Z(PoPo) = 7;
        % Pixeles donde la cobertura en el escenario BaU es mejor
        idBest  = (LULC_BaU.Z(PoPo) == 2);                 
        Porfolio.Z(PoPo(idBest))    = 2;          
        % Restar área
        Ap = Ap - (numel(Prio)*PixelArea);
        % Sumar Area total de intervención
        TotalArea = TotalArea + numel(Prio);
    end
    clearvars DataP
end

%% Agriculture
% Detectión de cobertura
Def         =find((LULC.Z == 4)&(Porfolio.Z==0));
if (Ap > 0)&~isempty(Def)
    % Escalamiento lineal de 0 a 1
    Scaling     = @(x) ((1/(max(x) - min(x)))*x) - ((1/(max(x) - min(x)))*min(x)); 
    % Detectar pixeles de cuenca
    DataP(:,1)  = Def;
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
    
    np = floor(Ap./PixelArea);
    if numel(Prio) > np
        % Pixeles priorizados
        PoPo    = DataP(1:np,1);
        % Pixeles donde la cobertura en el escenario BaU es mejor
        Porfolio.Z(PoPo) = 4; 
        % Restar área
        Ap = 0;
        % Sumar Area total de intervención
        TotalArea = TotalArea + np;
    else
        % Pixeles priorizados
        PoPo    = DataP(:,1);
        % Pixeles donde la cobertura en el escenario BaU es mejor 
        Porfolio.Z(PoPo) = 4;
        % Restar área
        Ap = Ap - (numel(Prio)*PixelArea);
        % Sumar Area total de intervención
        TotalArea = TotalArea + numel(Prio);
    end
    clearvars DataP
end

FinalArea = floor(TotalArea*PixelArea/1E4);

if FinalArea > (app.BasinArea/1E4)
    FinalArea = (app.BasinArea/1E4);
end

%% Guardar
% Exportar raster de portafolio 
Porfolio.Z = int8(Porfolio.Z);
Porfolio.GRIDobj2geotiff(PorPath);
% Progress
close(ProgressBar);

%% mensaje
if Ap == 0
    msgbox('Spatial distribution of the portfolio was successfully completed')
    CheckArea = false;
else
    CheckArea = true;
    warndlg(['Spatial distribution of the portfolio was successfully completed. ',...
            'However, the activity area of the analyzed basin only reaches ',...
            num2str(FinalArea),' ha. Therefore, consider using',...
            ' a lower intervention area for the analysis.'])
end