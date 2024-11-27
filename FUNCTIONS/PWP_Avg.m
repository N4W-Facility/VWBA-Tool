function PWP_avg = PWP_Avg(app)
% Nature For Water Facility - The Nature Conservancy
% -------------------------------------------------------------------------
% Matlab - R2023b 
% -------------------------------------------------------------------------
%                           BASIC INFORMATION
%--------------------------------------------------------------------------
% Author        : Jonathan Nogales Pimentel
% Email         : jonathan.nogales@tnc.org
% Project       : GF0001-Program_Intelligence
% Date          : November, 2024
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
% This function estimates the average permanent wilting point for the basin
%
% -------------------------------------------------------------------------
%                               INPUTS
% -------------------------------------------------------------------------
% ProjectPath       : Project Path
% BasinArea   [m^2] : Basin area
%
% -------------------------------------------------------------------------
%                               OUTPUTS
% -------------------------------------------------------------------------
% PWP_avg    [mm]   : Average permanent wilting point 


% Permanent wilting point raster scale factor
SF          = 1/100;

% Coversion factor mm -> m
ConFac_1    = 1/1000;

% Coversion factor m -> mm
ConFac_2    = 1000;

% Read permanent wilting point [m^3/m^3]
PWP          = GRIDobj( fullfile(app.ProjectPath,'02-Biophysic','PMP.tif') );
PWP.Z        = PWP.Z*SF;
PWP.Z(PWP.Z == 0) = NaN;

% Read soil depth [mm]
SD          = GRIDobj( fullfile(app.ProjectPath,'02-Biophysic','Soil_Depth.tif') );

% Soil depth is limited to 0.5 meters (500 mm). 
SD.Z(SD.Z > 500) = 500;

% Pixel area [m^2]
PixelArea   = ((SD.cellsize*110567)^2);

% Estimation permanent wilting point [m^3]
PWP_m3       = PWP.Z.*(SD.Z*ConFac_1).*PixelArea;

% Estimation average permanent wilting point [mm]
PWP_avg      = (double(sum(PWP_m3(:),'omitnan'))/app.BasinArea)*ConFac_2;