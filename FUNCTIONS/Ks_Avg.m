function Ks_avg = Ks_Avg(app)
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

ProgressBar = waitbar(0, 'Processing ...','Color',[1 1 1]);
wbch        = allchild(ProgressBar);
jp          = wbch(1).JavaPeer;
jp.setIndeterminate(1)

% Leer CC
Ks      = GRIDobj( fullfile(app.ProjectPath,'02-Biophysic','Ks.tif') );
Ks.Z(Ks.Z == 0) = NaN;

% Average CN
Ks_avg      = double(mean(Ks.Z(:),'omitnan'))*0.2;

% Close waitbar
close(ProgressBar)