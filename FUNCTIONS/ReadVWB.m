function Index = ReadVWB(app)
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

% lectura de indicadores
Index  = zeros(20,1);

% Agricultural practices - Reduced runoff
Index(1) = app.Index_AP1.Value;

% Agricultural practices - Volume captured
Index(2) = app.Index_AP2.Value;

% Agricultural practices - Volume improved
Index(3) = app.Index_AP3.Value;

% Demand management (Legal transactions) - Reduced withdrawal
Index(4) = app.Index_WCN1.Value;

% Demand management  (Improve water use efficiency) - Reduced withdrawal
Index(5) = app.Index_WCN2.Value;

% Demand management (Non-revenue Water) - Reduced withdrawal
Index(6) = app.Index_WCN3.Value; 

% Demand management (Agricultural irrigation efficiency) - Reduced withdrawal
Index(7) = app.Index_WCN4.Value; 

% Demand management (Land cover restoration) - Reduced withdrawal
Index(8) = app.Index_WCN5.Value; 

% Green and gray infrastructure - Volume captured
Index(9) = app.Index_GGI1.Value;

% Green and gray infrastructure - Volume treated
Index(10) = app.Index_GGI2.Value;

% Green and gray infrastructure - Volume provided
Index(11) = app.Index_GGI3.Value;

% Green and gray infrastructure - Volume provided
Index(12) = app.Index_GGI4.Value;

% Green and gray infrastructure - Increased or maintained inundation
Index(13) = app.Index_GGI5.Value;

% Green and gray infrastructure - Increased or maintained recharge
Index(14) = app.Index_GGI7.Value;

% Green and gray infrastructure - Volume improved
Index(15) = app.Index_GGI6.Value;

% Land conservation and restoration - Avoided runoff
Index(16) = app.Index_CR.Value;

% Land conservation and restoration - Increased or maintained seasonal water storage/Increased or maintained recharge
Index(17) = app.Index_CR_R.Value;

% Land conservation and restoration - Increased or maintained seasonal water storage/Increased or maintained recharge
Index(18) = app.Index_CR_Sw.Value;

% WASH - Volume provided
Index(19) = app.Index_WASH2.Value;

% WASH - Volume treated
Index(20) = app.Index_WASH.Value;