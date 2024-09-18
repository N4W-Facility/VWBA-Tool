function Object_BF(Params, TypeSbN, U, D, A, AET, C, T, Sl, S, F, B)
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
%                             INPUT DATA
% -------------------------------------------------------------------------
% Params    = Pesos de las variables
% TypeSbN   = Tipo de SbN [true = protección | false = otras]
% Las entradas listadas deben ser raster en formato GRIDobj de Topotoolbox. 
%     U     = Índice de Fuente Aguas Arriba
%     D     = Índice de Retención Aguas Abajo
%     A     = Precipitación anual media (mm)
%     AET   = Evapotranspiración real anual media (mm)
%     C     = Índice de Cobertura Vegetal (Ad)
%     T     = Índice de Textura de Suelos (Ad)
%     Sl    = Índice de Pendiente (Ad)
%     S     = Profundidad del Suelo (mm)
%     F     = Índice de Número de Curva (Ad)
%     B     = Índice de Beneficiarios (Ad)

if TypeSbN == 1
    % Conservación
    SO = (U + (1-D) + (0.2.*A) + (0.2*(1-AET)) + (0.2*C) + (0.2*(1-T)) + (0.2*(1-Sl)) + (0.5*S) + (0.5*F) + B)/5;
elseif TypeSbN == 2
    % Restauración
    SO = (U + (1-D) + (0.2.*A) + (0.2*(1-AET)) + (0.2*(1-C)) + (0.2*(1-T)) + (0.2*(1-Sl)) + (0.5*S) + (0.5*(1-F)) + B)/5;
elseif TypeSbN == 3
    % Agricultural practices (agroforestry)
    SO = (U + (1-D) + (0.2.*A) + (0.2*(1-AET)) + (0.2*(1-C)) + (0.2*(1-T)) + (0.2*(1-Sl)) + (0.5*S) + (0.5*(1-F)) + B)/5;
elseif TypeSbN == 4
    % Agricultural practices (agroforestry)
    SO = (U + (1-D) + (0.2.*A) + (0.2*(1-AET)) + (0.2*(1-C)) + (0.2*(1-T)) + (0.2*(1-Sl)) + (0.5*S) + (0.5*(1-F)) + B)/5;
elseif TypeSbN == 5
    % Demand management
    SO = (U + (1-D) + (0.2.*A) + (0.2*(1-AET)) + (0.2*(1-C)) + (0.2*(1-T)) + (0.2*(1-Sl)) + (0.5*S) + (0.5*(1-F)) + B)/5;
end
