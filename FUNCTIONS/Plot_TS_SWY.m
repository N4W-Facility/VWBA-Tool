function [VWB_R, VWB_Sw] = Plot_TS_SWY(ProjectPath, DateSPI, SPI, DroughtClass, Date, P, SwH, SwF, RH, RF, BasinArea, PWA,StatusPlot)
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
%
% -------------------------------------------------------------------------
%                             Inputs
% -------------------------------------------------------------------------
% sand  [0 - 1] : Porcentaje de arenas
% silt  [0 - 1] : Porcentaje de limos
% clay  [0 - 1] : Porcentaje de arcilla
%
% -------------------------------------------------------------------------
%                             Inputs
% -------------------------------------------------------------------------
% S     [0 - 1] : contenido de agua de saturación del suelo (L3/L3).
%
% -------------------------------------------------------------------------
%                             Descripción
% -------------------------------------------------------------------------
% Está función estima el contenido de agua de saturación del suelo a partir 
% de la textura del suelo. Los valores se toman del trabajo de:
% Rudiyanto et al. (2021)
% Las tablas utilizadas se puede encontrar en los siguientes links:
% https://doi.org/10.1016/j.geoderma.2021.115194

% Configurar gráfica
Fig     = figure('color',[1 1 1]);
T       = [15, 22];
set(Fig, 'Units', 'Inches', 'PaperPosition', [0, 0, T],'Position',...
[0, 0, T],'PaperUnits', 'Inches','PaperSize', T,'PaperType','usletter', 'Visible','off')         
hold on

% -------------------------------------------------------------------------
% SPI
% -------------------------------------------------------------------------
subplot(5,1,1)
hold on
% Plot de categorias de SPI
Ax1 = bar(DateSPI, SPI.*(DroughtClass==1), 'FaceColor',[82 140 86]/255,'FaceAlpha',0.8,'EdgeColor',[82 140 86]/255,'ShowBaseLine','off','BarWidth', 1);
Ax2 = bar(DateSPI, SPI.*(DroughtClass==2), 'FaceColor',[255 230 153]/255,'FaceAlpha',0.8,'EdgeColor',[255 230 153]/255,'ShowBaseLine','off','BarWidth', 1);
Ax3 = bar(DateSPI, SPI.*(DroughtClass==3), 'FaceColor',[243 221 221]/255,'FaceAlpha',0.85,'EdgeColor',[243 221 221]/255,'ShowBaseLine','off','BarWidth', 1);
Ax4 = bar(DateSPI, SPI.*(DroughtClass==4), 'FaceColor',[217 134 134]/255,'FaceAlpha',0.95,'EdgeColor',[217 134 134]/255,'ShowBaseLine','off','BarWidth', 1);
Ax5 = bar(DateSPI, SPI.*(DroughtClass==5), 'FaceColor',[180 82 82]/255,'FaceAlpha',0.99,'EdgeColor',[180 82 82]/255,'ShowBaseLine','off','BarWidth', 1);

% Etiqueta del eje X
xlabel('\bf Time (months)','Interpreter','latex','FontSize',20)

% Etiqueta del eje Y
ylabel('\bf Standardized Precipitation Index','Interpreter','latex','FontSize',20)

% Leyenda
legend([Ax1 Ax2 Ax3 Ax4 Ax5],{'\bf Wet period','\bf Mild Drought','\bf Moderate Drought','\bf Severe Drought','\bf Extreme Drought'},...
       'Location','northwest','NumColumns',5,'Interpreter','latex','FontSize',10);

% Limitar rango a la fecha
xlim([min(Date) - 12, max(Date) + 12])     
box off

% Configuración de ejes
set(gca, 'TickLabelInterpreter','latex', 'FontWeight','bold','Color','none', 'box','on','FontSize',14)

% -------------------------------------------------------------------------
% Precipitación
% -------------------------------------------------------------------------
subplot(5,1,2)

% Plot
plot(Date,P),

% Etiqueta del eje X
xlabel('\bf Time (day)','Interpreter','latex','FontSize',20)

% Etiqueta del eje Y
ylabel('\bf Precipitation (mm)','Interpreter','latex','FontSize',20)

% Configuración de ejes
set(gca, 'TickLabelInterpreter','latex', 'FontWeight','bold','Color','none', 'box','on','FontSize',14)

% -------------------------------------------------------------------------
% Humedad del suelo Bau
% -------------------------------------------------------------------------
subplot(5,1,3)

% Plot
plot(Date,SwH, 'Color',[0 .75 .75])

% Etiqueta del eje X
xlabel('\bf Time (day)','Interpreter','latex','FontSize',20)

% Etiqueta del eje Y
ylabel('\bf Soil Water Content - BaU (mm)','Interpreter','latex','FontSize',20)

% Configuración de ejes
set(gca, 'TickLabelInterpreter','latex', 'FontWeight','bold','Color','none', 'box','on','FontSize',14)

% -------------------------------------------------------------------------
% Humedad del suelo  NbS
% -------------------------------------------------------------------------
subplot(5,1,4)
plot(Date,SwF,'Color',[0 .75 .75])

% Etiqueta del eje X
xlabel('\bf Time (day)','Interpreter','latex','FontSize',20)

% Etiqueta del eje Y
ylabel('\bf Soil Water Content - NbS (mm)','Interpreter','latex','FontSize',20)

% Configuración de ejes
set(gca, 'TickLabelInterpreter','latex', 'FontWeight','bold','Color','none', 'box','on','FontSize',14)

% -------------------------------------------------------------------------
% Recarga
% -------------------------------------------------------------------------
subplot(5,1,5)
R = ((RF - RH)/1000)*BasinArea;
R(R<0) = 0;
plot(Date,R)

% Etiqueta del eje X
ylabel('\bf VWB $\bf (m^3)$','Interpreter','latex','FontSize',20)

% Etiqueta del eje Y
xlabel('\bf Time (day)','Interpreter','latex','FontSize',20)

% Configuración de ejes
set(gca, 'TickLabelInterpreter','latex', 'FontWeight','bold','Color','none', 'box','on','FontSize',14)

if StatusPlot
    % Guardar
    saveas(Fig,fullfile(ProjectPath,'SPI.png'))
end

% -------------------------------------------------------------------------
% Desagregar SPI
% -------------------------------------------------------------------------
y1      = year(DateSPI);
m1      = month(DateSPI);
y2      = year(Date);
m2      = month(Date);
SPInew  = sum(((y2 == y1')&(m2 == m1')).*SPI',2);

VWB_R   = sum(R(SPInew < 0),'omitnan')/10;

VWB_Sw  = (((sum(SwF(SPInew < 0)*PWA) + sum(RF(SPInew < 0))) - ...
          (sum(SwH(SPInew < 0)*PWA) + sum(RH(SPInew < 0))))/1000)*BasinArea; 
VWB_Sw  = VWB_Sw/10;

if StatusPlot
    % Escribir serie de tiempo
    Fc = BasinArea/1000;
    TS_Path = fullfile(ProjectPath,'02-Biophysic','TS_SWY.csv');
    ID_File = fopen(TS_Path,'w');
    fprintf(ID_File,'Year,Month,day,SPI,Recharge - BaU (m3),Recharge - NbS (m3),Sw - BaU (m3),Sw - BaU (m3)\n');
    fprintf(ID_File,'%d,%d,%d,%f,%f,%f,%f,%f\n', ...
           [year(Date) month(Date) day(Date) SPInew RH*Fc RF*Fc SwH*Fc SwF*Fc]');
    fclose(ID_File);
end