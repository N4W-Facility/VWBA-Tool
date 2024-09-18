function CreateReport(app)
%% Resultados de VWBA 
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

%% Leer datos y plantillas
% Leer lista de indicadores
Data        = readtable('Info_html.csv');

% Leer template reporte
TextReport  = fileread('Template_Report.html');

%% Nombre de la cuenca
TextReport = strrep(TextReport,'01-NameBasin',app.AppVWBA.UserData.ProjectName);

%% Descripción
TextReport = strrep(TextReport,'02-DescriptionBasin',app.AppVWBA.UserData.Description);

%% Localización
PathFigBasin = fullfile(app.AppVWBA.ProjectPath,'04-Report','Basin.png');
TextReport = strrep(TextReport,'03-FigBasin',PathFigBasin);

%% Area de portafolios
TextReport = strrep(TextReport,'03-AreaAG',num2str(app.AppVWBA.Area_AgriPrac.Value,'%.2f'));
TextReport = strrep(TextReport,'03-AreaCR',num2str(app.AppVWBA.Area_CR.Value,'%.2f'));

%% Valores de indicadores VWBA
% Leer datos de tabla
Tmp         = app.Table.Data;
StatusPro   = Tmp.Var3;
Status      = Tmp.Var4;

% Leer todos los resultados delos indicadore
ValueIndex  = ReadVWB(app.AppVWBA);

% Crear datos de tabla
TextHTML = '            <tbody>\n';
for i = 1:length(Data.ID)
    if Status(i)
        if StatusPro(i)
            V = num2str(ValueIndex(i),'%.2f');
        else
            V = 'Not calculated';
        end
        TextHTML = ValueTable(  TextHTML,...
                                Data.Activity{i},...
                                Data.Index{i},...
                                Data.Objective{i},...
                                V,...
                                Data.Anexo{i},...
                                Data.Link{i});
        
    end
end
TextHTML = sprintf([TextHTML,'            </tbody>\n']);
TextReport  = strrep(TextReport,'            <!ValueTableVWBA>',TextHTML);

%% Métricas
Data = cell2table(app.TableMetrics.Data);
if app.StatusMetric.Value
    % Ejelcutar modelo SWY
    Ap = app.AreaInter.Value;
    if Data.Var2(3)
        [VWB_R,~] = SWY_Metrics(app,Ap);
    
        % Personas benficidas. Se toma el valor de 150 litros/hab.día.
        % Dotación mínima recomendada por la Organización Mundial de la Salud (OMS): 
        % 100 litros por habitante por día (para cubrir necesidades básicas de consumo e higiene).
        % Dotación promedio global estimada: Entre 150 y 300 litros por habitante 
        % por día (varía según las fuentes y metodologías de cálculo).
        % Países con dotaciones altas (más de 300 litros/hab/día): 
        % Estados Unidos, Canadá, Australia, algunos países europeos.
        % Países con dotaciones bajas (menos de 100 litros/hab/día): 
        % Países en vías de desarrollo, principalmente en África y Asia.
        BPeople = floor(VWB_R/((150/1000)*365));
    else
        BPeople = 0;
    end
    Ap = app.AreaInter.Value;
    
    % Factor de proporción
    Factor = Ap/(app.AppVWBA.BasinArea/10000);

    % Valores de métricas
    Values = [app.AppVWBA.LengthRivers*Factor,...
              (app.AppVWBA.LakesArea/10000)*Factor,...
              BPeople];

    % Construir tabla
    TextHTML = ['        <h2>Metrics</h2>\n',...
            '        <p>Freshwater metrics are estimated using the global databases recommended by TNC''s ',...
            'Freshwater Metrics Guide for the 2030 Goals. For rivers, the ',...
            '<a href="https://www.hydrosheds.org/"> HydroSHEDS Database</a> is utilized, while for wetlands, the ',...
            '<a href="https://www.hydrosheds.org/products/glwd">Global Lakes and Wetlands Database</a> is employed. ',...
            'The metrics for rivers and wetlands are proportional to the intervention area. ',...
            'The total number of beneficiaries is calculated as the ratio between the volume of recharged water ',...
            '(see <a href="https://nature4water.org/">A-15</a>) ',...
            'and the global average endowment volume estimated as 150 liters per person per day.</p>\n',...
            '        <table>\n',...
            '            <thead>\n',...
            '                <tr>\n',...
            '                    <th>Metrics</th>\n',...
            '                    <th>Value</th>\n',...
            '                </tr>\n',...
            '            </thead>\n',...
            '            <tbody>\n'];
    
    % Área de la cuenca
    TextHTML = MetricsTable(TextHTML,'Basin area (ha)',...
                                    num2str(app.AppVWBA.BasinArea/10000,'%.2f'));
    % Área de intervención terrestre
    TextHTML = MetricsTable(TextHTML,'Terrestrial intervention area (ha)',...
                                    num2str(Ap,'%.2f'));

    % Longitud total de ríos
    TextHTML = MetricsTable(TextHTML,'Total length of rivers in the basin (km)',...
                                    num2str(app.AppVWBA.LengthRivers,'%.2f'));

    % Área total de humedales
    TextHTML = MetricsTable(TextHTML,'Total area of wetlands in the basin (ha)',...
                                    num2str((app.AppVWBA.LakesArea/10000),'%.2f'));

    % Área total de humedales
    TextHTML = MetricsTable(TextHTML,'Estimated total number of people in the basin (people)',...
                                    num2str((app.AppVWBA.People),'%d'));

    for i = 1:length(Data.Var1)
        if Data.Var2(i)
            TextHTML = MetricsTable(TextHTML,Data.Var1{i},...
                                    num2str(Values(i),'%.2f'));
        end
    end
    TextHTML = sprintf([TextHTML,...
            '            </tbody>\n',...
            '        </table>\n']);
    TextReport  = strrep(TextReport,'        <!MetricTable>',TextHTML);
end

%% Biodiversidad
CatBio = {'Very high','High','Medium','Low','Very Low'};
if app.StatusBio.Value
    TextHTML = ['		<h2>Distribution of areas by importance for biodiversity</h2>\n',...
            '        <p>Areas of importance for biodiversity are estimated using data generated by ',...
            '<a href="https://zenodo.org/records/5006332">Jung et al. (2020)</a>. ',...
            'The categories are defined by five regular intervals. The proportion of ',...
            'watershed area falling into each category is consolidated in the table.</p>\n',...
            '        <table>\n',...
            '            <thead>\n',...
            '                <tr>\n',...
            '                    <th>Category</th>\n',...
            '                    <th>Area (ha)</th>\n',...
            '                    <th>Area (Percentage)</th>\n',...
            '                </tr>\n',...
            '            </thead>\n',...
            '            <tbody>\n'];
    for i = 1:length(CatBio)

        TextHTML = BioTable( TextHTML, ...
                             CatBio{i},...
                                num2str(app.AppVWBA.AreaBio(i)/10000,'%.2f'),...
                                num2str((app.AppVWBA.AreaBio(i)/app.AppVWBA.BasinArea)*100,'%.2f'));
    end
    TextHTML = sprintf([TextHTML,...
            '            </tbody>\n',...
            '        </table>\n']);
    TextReport  = strrep(TextReport,'		<!BioTable>',TextHTML);
end

% imagen de encabezado
TextReport  = strrep(TextReport,'Fig_Header', fullfile(app.AppVWBA.DataBasePath,'Report','N4W_Header.jpg') );

% Imagen de logo N4W
TextReport  = strrep(TextReport,'Fig_Footer_1', fullfile(app.AppVWBA.DataBasePath,'Report','N4WLogo.png') );

% Imagen de logo TNC
TextReport  = strrep(TextReport,'Fig_Footer_2', fullfile(app.AppVWBA.DataBasePath,'Report','TNCLogo.png') );

%% guardar reporte
FilePath = fullfile(app.AppVWBA.ProjectPath,'04-Report','Resport_VWBA.html');
ID_File = fopen(FilePath,'w');
fprintf(ID_File,'%s',TextReport);
fclose(ID_File);

end

%%
function TextHTML = ValueTable(TextHTML,NameAct,NameIndex,NameObj,ValueIndex,NameMethod,LinkMethod)
TextHTML = sprintf( [TextHTML,...
                     '                <tr>\n',...
                     '                    <td>%s</td>\n',...
                     '                    <td>%s</td>\n',...
                     '                    <td>%s</td>\n',...
                     '                    <td>%s</td>\n',...
                     '                    <td><a href="%s">%s</a></td>\n',...
                     '                <tr>\n'],...
                     NameAct,NameIndex,NameObj,ValueIndex,LinkMethod,NameMethod);
end

%% Tabla de metricas
function TextHTML = MetricsTable(TextHTML,NameMetric,ValueMetric)

TextHTML = sprintf( [TextHTML,...
            '                <tr>\n',...
            '                    <td>%s</td>\n',...
            '                    <td>%s</td>\n',...
            '                <tr>\n'],...
            NameMetric,ValueMetric);
end

%% Tabla Bio
function TextHTML = BioTable(TextHTML,NameCat,A1,A2)

TextHTML = sprintf( [TextHTML,...
            '                <tr>\n',...
            '                    <td>%s</td>\n',...
            '                    <td>%s</td>\n',...
            '                    <td>%s</td>\n',...
            '                <tr>\n'],...
            NameCat,A1,A2);

end