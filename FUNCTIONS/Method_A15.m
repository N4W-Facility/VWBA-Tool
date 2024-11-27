function [R, Sw, Rr] = Method_A15(P, ET, CS, Q, Smax, FC, PWP, Ks)
% Nature For Water Facility - The Nature Conservancy
% -------------------------------------------------------------------------
% Matlab - R2023b 
% -------------------------------------------------------------------------
%                           BASIC INFORMATION
%--------------------------------------------------------------------------
% Author        : Jonathan Nogales Pimentel
% Email         : jonathan.nogales@tnc.org
% Date          : June, 2024
%
%--------------------------------------------------------------------------
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
%                              DESCRIPTION
% -------------------------------------------------------------------------
% This function estimates the Seasonal water availability for a basin as 
% described in appendix A15. 
% Appendix A-15: Increased recharge and seasonal water availability method
%
% -------------------------------------------------------------------------
%                                INPUTS
% -------------------------------------------------------------------------
%    P    [mm]   : Precipitation time series
%    ET   [mm]   : Potential evapotranspiration time series
%    CS   [mm]   : Canopy storage time series
%    Q    [mm]   : Runoff time series
%    Smax [mm]   : Soil water content at saturation
%    FC   [mm]   : Soil water content at field capacity
%    PWP  [mm]   : Soil water content at permanent wilting point
%    Ks   [mm/d] : Saturation hydraulic conductivity
%
% -------------------------------------------------------------------------
%                                OUTPUTS
% -------------------------------------------------------------------------
%    R    [mm]   : Recharge time series
%    SW   [mm]   : Soil water content time series
%    Rr   [mm]   : Percolation time series
% 
% -------------------------------------------------------------------------
%                               REFERENCES
% -------------------------------------------------------------------------
%    Fan, Y., Gong, J., Wang, Y., Shao, X., & Zhao, T. (2019). Application 
%    of Philip infiltration model to film hole irrigation. Water Supply, 
%    19(3), 978-985. https://doi.org/10.2166/ws.2018.185

% Recharge [mm]
R       = P*0;
% Infiltration [mm]
I       = P*0;
% Soil water content [mm]
Sw      = P*0; 
% Soil water content init [mm]
Swo     = FC;
% Percolation from the Soil to the aquifer [mm]
Rr      = P*0;

for i = 1:length(P)  
    % Infiltration [mm]
    I(i) = P(i) - ET(i) - CS(i) - Q(i);
    
    % Soil water content change [mm]
    Swi = Swo + I(i);
    
    % Check Soil moisture
    if Swi<0, Swi = 0; end
    
    % Check Infiltration
    if I(i) < 0, I(i) = 0; end            

    % Balance
    if Swi >= Smax
        % Recharge [mm]
        R(i) = I(i);
        % Soil moisture [mm]
        Swi  = Smax;
    elseif (Swi < Smax)&&(Swi > FC)
        % To estimate how much water percolates from the soil to the aquifer, 
        % Darcy's law is used where: q = Ki*i
        % Where i is the hydraulic gradient and Ki is the hydraulic 
        % conductivity for moisture at time i. To estimate i, it is assumed 
        % that it is proportional to the ratio between the infiltrated water 
        % in the soil and the saturation water content of the soil. Ki is 
        % estimated using the van Genuchten-Mualem model, considering the 
        % parameterization of a loam soil according to the parameters 
        % reported by Fan et al. (2018).
        % Van Genuchten-Mualem parameter
        n       = 1.56;
        m       = 1 - (1/n);
        % Saturation percentage [Dimensionless]
        Se      = ((Swi-PWP)/(Smax-PWP));
        % Hydraulic conductivity for soil moisture content i [mm/d]
        Ksi     = Ks*(Se^0.5)*(1 - (1 - Se^(1/m))^m)^2;
        % Percolated water [mm]
        Rr(i)   = (I(i)/(Smax - FC))*(Ksi);
        % Recharge [mm]
        R(i)    = min([Rr(i),I(i)]);
        % Soil moisture [mm]
        Swi     = Swi - R(i);
    else
        % Recharge [mm]
        R(i) = 0;
    end
    % Soil water content [mm]
    Sw(i) = Swi;
    Swo   = Swi;
end