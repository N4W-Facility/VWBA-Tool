function CN_avg = CN_With_AgriPrac(app,Path_Porfolio)
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
% According to sun et al. (2015), the effectiveness of no-tillage (NT) in 
% reducing surface runoff is between 21.9% and 27.2%. For the purposes of 
% the tool, an average value of 24.5% is considered. The NC with activities 
% is estimated as the value that generates a 24.5% reduction in runoff with 
% a precipitation of equal to the 95% percentile of the global precipitation 
% time series.
%
% -------------------------------------------------------------------------
%                                INPUTS
% -------------------------------------------------------------------------
%    Path_Porfolio: Path of the agricultural practices portfolio 
%
% -------------------------------------------------------------------------
%                                OUTPUTS
% -------------------------------------------------------------------------
%    CN_avg    [dimensionless] : Average curve number 
%
% -------------------------------------------------------------------------
%                               REFERENCES
% -------------------------------------------------------------------------
% Sun, Y., Zeng, Y., Shi, Q., Pan, X., & Huang, S. (2015). No-tillage 
% controls on runoff: A meta-analysis. Soil and Tillage Research, 153, 1-6.
% https://www.sciencedirect.com/science/article/pii/S0167198715000884

ProgressBar = waitbar(0, 'Processing precipitation data from the global database','Color',[1 1 1]);
wbch        = allchild(ProgressBar);
jp          = wbch(1).JavaPeer;
jp.setIndeterminate(1)

% Leer precipitación
TS_Path = fullfile(app.ProjectPath,'02-Biophysic','P.csv');
Tmp     = readmatrix(TS_Path);
P       = Tmp(:,4);

% Calular precipiración promedio
Pm      = quantile(P(P>0),0.95);

% Escorrentía
CN_T    = (0:0.0001:100)';
Q_T     = Method_A1(Pm, CN_T);
id      = Q_T>0; 

% Leer portafolio
%Path_Porfolio   = fullfile(app.ProjectPath,'03-Porfolio','Portfolio_AgriPrac.tif');
Porfolio        = GRIDobj( Path_Porfolio );

% Leer Curver number
CN      = GRIDobj( fullfile(app.ProjectPath,'02-Biophysic','CN.tif') );

% Determinación de CN para condición sin actividades
Q       = Method_A1(Pm, CN.Z(Porfolio.Z == 1))*(1 - 0.245);

% Reducir valor de CN
CN.Z(Porfolio.Z == 1) = interp1(Q_T(id),CN_T(id),Q);

% Average CN
CN_avg      = double(round(mean(CN.Z(:),'omitnan'),4));

% Close waitbar
close(ProgressBar)