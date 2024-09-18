function [WV, CV] = Method_A2(DFR, DD, RFF)
% Appendix A-2. Withdrawal and Consumption Methods
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
% The Withdrawal and Consumption methods enable estimation of the volumetric 
% benefit of activities that reduce water withdrawal, reduce non-revenue 
% water or reduce consumption
%
% -------------------------------------------------------------------------
%                             INPUT DATA
% -------------------------------------------------------------------------
%   DFR = Diversion flow rate
%   DD  = Duration of diversion
%   RFF = Return flow fraction
%
% -------------------------------------------------------------------------
%                             OUTPUT DATA
% -------------------------------------------------------------------------
%   WV  = Withdrawal volume
%   CV  = Consumed volum


% Withdrawal volume 
WV = DFR.*DD;

% Consumed volume 
CV = WV.*(1-RFF);

