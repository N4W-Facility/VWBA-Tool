function S = Smax(sand, silt, clay)
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


% Matriz de almacenamiento
S = zeros(size(sand));

% -------------------------------------------------------------------------
% Sand
% -------------------------------------------------------------------------
id          = (silt + (1.5*clay)) < 0.15;
S(id)       = 0.432;

% -------------------------------------------------------------------------
% Loamy sand
% -------------------------------------------------------------------------
id          = ((silt + (1.5*clay)) >= 0.15) & ((silt + (2*clay)) < 0.3);
S(id)       = 0.463;

% -------------------------------------------------------------------------
% Sandy loam
% -------------------------------------------------------------------------
id          = (clay >= 0.07) & (clay <= 0.2) & (sand > 0.52) & ((silt + (2*clay)) >= 0.3);
S(id)       = 0.463;

id          = (clay < 0.07) & (silt < 0.5) & ((silt + (2*clay)) >= 0.3);
S(id)       = 0.463;

% -------------------------------------------------------------------------
% loam
% -------------------------------------------------------------------------
id          = (clay >= 0.07) & (clay <= 0.27) & (silt >= 0.28) & (silt < 0.5) & (sand <= 0.52);
S(id)       = 0.589;

% -------------------------------------------------------------------------
% Silt Loam
% -------------------------------------------------------------------------
id          = ((silt>=0.5) & (clay >= 0.12) & (clay<0.27)) | ((silt>=0.5) & (silt<0.8) & (clay<0.12));
S(id)       = 0.468;

% -------------------------------------------------------------------------
% Silt
% -------------------------------------------------------------------------
id          = (silt >= 0.8) & (clay < 0.12);
S(id)       = 0.445;

% -------------------------------------------------------------------------
% Sandy Clay Loam
% -------------------------------------------------------------------------
id          = (clay >= 0.2) & (clay < 0.35) & (silt < 0.28) & (sand > 0.45);
S(id)       = 0.656;

% -------------------------------------------------------------------------
% Clay Loam
% -------------------------------------------------------------------------
id          = (clay >= 0.27) & (clay < 0.4) & (sand > 0.2) & (sand <= 0.45);
S(id)       = 0.678;

% -------------------------------------------------------------------------
% Silty Clay Loam
% -------------------------------------------------------------------------
id          = (clay >= 0.27) & (clay < 0.4) & (sand <= 0.2);
S(id)       = 0.649;

% -------------------------------------------------------------------------
% Sandy Clay
% -------------------------------------------------------------------------
id          = (clay >= 0.35) & (sand >= 0.45);
S(id)       = 0.627;

% -------------------------------------------------------------------------
% Silty Clay
% -------------------------------------------------------------------------
id          = (clay >= 0.4) & (silt >= 0.4);
S(id)       = 0.596;

% -------------------------------------------------------------------------
% Clay
% -------------------------------------------------------------------------
id          = (clay >= 0.4) & (sand <= 0.45) & (silt < 0.4);
S(id)       = 0.597;

% Correción de ceros
id = ((clay == 0)&(sand == 0))&(silt==0);
S(id) = 0;