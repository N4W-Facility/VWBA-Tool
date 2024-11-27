function CC_avg = CC_Avg(app)
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
% This function estimates the average field capacity for the basin.
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
% PWP_avg    [mm]   : Average field capacity

% Progress Bar 
ProgressBar = waitbar(0, 'Processing precipitation data from the global database','Color',[1 1 1]);
wbch        = allchild(ProgressBar);
jp          = wbch(1).JavaPeer;
jp.setIndeterminate(1)

% Field capacity raster scale factor
SF          = 1/100;

% Coversion factor mm -> m
ConFac_1    = 1/1000;

% Coversion factor m -> mm
ConFac_2    = 1000;

% Read field capacity [m^3/m^3]
CC          = GRIDobj( fullfile(app.ProjectPath,'02-Biophysic','CC.tif') );
CC.Z        = CC.Z*SF;
CC.Z(CC.Z == 0) = NaN;

% Read soil depth [mm]
SD          = GRIDobj( fullfile(app.ProjectPath,'02-Biophysic','Soil_Depth.tif') );

% Soil depth is limited to 0.5 meters (500 mm). 
SD.Z(SD.Z > 500) = 500;

% Pixel area [m^2]
PixelArea   = ((SD.cellsize*110567)^2);

% Etimation field capacity [m^3]
CC_m3       = CC.Z.*(SD.Z*ConFac_1).*PixelArea;

% Estimation average field capacity [mm]
CC_avg      = (double(sum(CC_m3(:),'omitnan'))/app.BasinArea)*ConFac_2;

% Close waitbar
close(ProgressBar)