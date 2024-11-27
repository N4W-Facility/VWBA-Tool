function CN_avg = CN_Without_AgriPrac(app)
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
% This function estimates the average curve number for the basin.
%
% -------------------------------------------------------------------------
%                               INPUTS
% -------------------------------------------------------------------------
% ProjectPath       : Project Path
%
% -------------------------------------------------------------------------
%                               OUTPUTS
% -------------------------------------------------------------------------
% CN_avg    [dimensionless] : Average curve number 
% 

% Progress Bar
ProgressBar = waitbar(0, 'Processing precipitation data from the global database','Color',[1 1 1]);
wbch        = allchild(ProgressBar);
jp          = wbch(1).JavaPeer;
jp.setIndeterminate(1)

% Read curver number [dimensionless]
CN          = GRIDobj( fullfile(app.ProjectPath,'02-Biophysic','CN.tif') );

% Estimation average curver number [dimensionless]
CN_avg      = double(round(mean(CN.Z(:),'omitnan'),4));

% Close waitbar
close(ProgressBar)