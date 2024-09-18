function [R, Sw] = Method_A15(P, ET, CS, Q, Smax, CC, Ks)
% Appendix A-13. Nonpoint Source Pollutant Reduction Method
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
%                               Description
% -------------------------------------------------------------------------
% he Curve Number method enables estimation of the volumetric benefit of
% the following activities using the referenced output indicators below:
%   - Land conservation
%   - Land cover restoration
%   - Agricultural best management practices (BMPs)
%
% -------------------------------------------------------------------------
%                             INPUT DATA
% -------------------------------------------------------------------------
%    R      = Recharge (mm)
%    I      = Infiltration (mm)
%    SW     = Soil water content (mm)
%    SAT    = Soil water content at saturation (mm)
%    FC     = Soil water content at field capacity (mm)
%    Rr     = Recharge rate (%)
%    ET     = Evapotranspiration (mm)
%    Q      = Runoff (mm)
%    Pgross = Gross precipitation (mm)
%    CS     = Canopy storage (mm)
%
% -------------------------------------------------------------------------
%                             OUTPUT DATA
% -------------------------------------------------------------------------
%   VC   = Volume captured (m3)

Pnet    = P*0; 
R       = P*0;
I       = P*0;
Sw      = P*0; 
Swo     = Smax;
Rr      = Ks/Smax; 
if Rr > 1, Rr= 1; end 
for i = 1:length(P)   
    % % Precipitación neta (mm)
    % % Pnet = P(i) - CS(i) - Q(i)

    % Infiltration (mm)
    I(i) = P(i) - ET(i) - CS(i) - Q(i);      

    % Cambio de humedad en el suelo (mm)
    Swo = Swo + I(i);

    if Swo<0
        Swo = 0;
    end

    if I(i) < 0
        I(i) = 0;
    end
    
    % Recharge (mm)
    if Swo>=Smax
        R(i) = I(i);
        Swo = Smax;
    elseif (Swo < Smax)&&(Swo>CC)
        R(i) = Rr.*I(i);
        Swo  = Swo - R(i);
    else
        R(i) = 0;
    end
    Sw(i) = Swo;

    % Seasonal water availability (mm)
    % SWA = SW.*PA + R;
end
