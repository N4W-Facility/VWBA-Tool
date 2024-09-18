function VI = Method_A13(Q, IIA, TIN, NA, NL)
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
%   Q   = Post-Project Runoff or Post-Project Recharge 
%   IIA = Incremental Improvement by Activity 
%   TIN = Total Improvement Needed 
%   NA  = Number of WQ Challenges Addressed by Activity
%   NL  = Number of WQ Challenges Caused by Land Use
% -------------------------------------------------------------------------
%                             OUTPUT DATA
% -------------------------------------------------------------------------
%   Q   = Volume Improved  (m3)

% Fraction Improved
FI  = IIA./TIN;
% Fraction Challenges Addressed
FCA = NA./NL;
% Volume Improved 
VI  = Q.*FI.*FCA;


