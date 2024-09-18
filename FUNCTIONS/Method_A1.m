function Q = Method_A1(P, CN)
% Appendix A-1. Curve Number Method
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
%   P   = Precipitation (mm)
%   CN  = Curve Number (Ad)
%
% -------------------------------------------------------------------------
%                             OUTPUT DATA
% -------------------------------------------------------------------------
%   Q   = Runoff (mm)

%  Potential maximum retention after runoff begins (mm)
S = (25400./CN) - 254;

% Runoff (mm)
Q = ((P - (0.2.*S)).^2)./(P + (0.8.*S));

% Check Zeros values
Q(P <= 0.2*S) = 0;
