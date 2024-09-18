function VC = Method_A14(CO2e_P,CO2e_B,RZDW,PWA,RootDepth,RootArea,NTR)

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
%   NTR         = Number of times recharged (day)
%   CSSC        = Change in soil storage capacity 
%   RootDepth   = root zone depth (m)
%   RootArea    = root zone area (m^2)
%   RZDW        = Root zone dry weight (kg)
%   PWA         = Plant available water holding capacity coefficient ((m/m)/(kg/kg)) 
%   CO2_P       = CO2ewith-project (kg)
%   CO2_B       = CO2ebaseline (kg)
%
% -------------------------------------------------------------------------
%                             OUTPUT DATA
% -------------------------------------------------------------------------
%   VC   = Volume captured (m3)

% Ratio of absolute SOC to CO2e
F_CO2e  = (1/3.67);

% Cambio en el almacenamiento de carbono (kg)
C_CO2   = (CO2e_P - CO2e_B);

% Change in absolute SOC content (kg) 
CA_SOC  = C_CO2.*F_CO2e;

% Change in relative SOC content (kg/kg) 
CR_SOC  = CA_SOC/RZDW;

% Change in water holding capacity (m/m)
CWHC    = CR_SOC*PWA;

% Change in soil storage capacity (m3)
CSSC    = CWHC*RootDepth*RootArea;

% Volume captured 
VC      = NTR*CSSC;
