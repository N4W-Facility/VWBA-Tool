function Smax_avg = Smax_Avg(app)
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
% This function estimates the average soil saturation water content for the 
% basin.
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
% Smax_avg    [mm]  : Average soil saturation water content
% 

% Progress Bar
ProgressBar = waitbar(0, 'Processing precipitation data from the global database','Color',[1 1 1]);
wbch        = allchild(ProgressBar);
jp          = wbch(1).JavaPeer;
jp.setIndeterminate(1)

% Soil saturation water content raster scale factor
SF_Smax     = 1/100;

% Coversion factor mm -> m
ConFac_1    = 1/1000;

% Coversion factor m -> mm
ConFac_2    = 1000;

% Read soil saturation water content [m^3/m^3]
Smax        = GRIDobj( fullfile(app.ProjectPath,'02-Biophysic','Smax.tif') );
Smax.Z      = Smax.Z*SF_Smax;
Smax.Z(Smax.Z == 0) = NaN;

% Read soil depth [mm]
SD          = GRIDobj( fullfile(app.ProjectPath,'02-Biophysic','Soil_Depth.tif') );

% Soil depth is limited to 0.5 meters (500 mm). 
SD.Z(SD.Z > 500) = 500;

% Pixel area [m^2]
PixelArea   = ((Smax.cellsize*110567)^2);

% Estimation soil saturation water content [m^3]
Smax_m3     = Smax.Z.*(SD.Z*ConFac_1).*PixelArea;

% Etimation average soil saturation water content [mm]
Smax_avg    = (double(sum(Smax_m3(:),'omitnan'))/app.BasinArea)*ConFac_2;

% Close waitbar
close(ProgressBar)