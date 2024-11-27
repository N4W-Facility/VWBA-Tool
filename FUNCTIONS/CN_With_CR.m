function CN_avg = CN_With_CR(app,Path_Porfolio)
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
% Depending on the hydrologic soil type, a cover can have four curve 
% numbers. In this sense, the curve number for conservation and restoration 
% activities is assigned as the lowest curve number following the current 
% curve number.
%
% -------------------------------------------------------------------------
%                                INPUTS
% -------------------------------------------------------------------------
%    Path_Porfolio: Path of the conservation and restoration portfolio 
%
% -------------------------------------------------------------------------
%                                OUTPUTS
% -------------------------------------------------------------------------
%    CN_avg    [dimensionless] : Average curve number 
%

ProgressBar = waitbar(0, 'Processing ...','Color',[1 1 1]);
wbch        = allchild(ProgressBar);
jp          = wbch(1).JavaPeer;
jp.setIndeterminate(1)

% Guardar raster
LULC_BaU    = GRIDobj( fullfile(app.ProjectPath,'02-Biophysic','LULC_BaU.tif') );

% grupos de suelos
SG          = GRIDobj( fullfile(app.ProjectPath,'02-Biophysic','SG.tif') );

% Leer portafolio
Porfolio    = GRIDobj( Path_Porfolio );

% Remplazar coberturas de portafolio
LULC_BaU.Z(Porfolio.Z > 0) = Porfolio.Z(Porfolio.Z > 0);

% Leer Número de curvas
Table  = readmatrix( fullfile(app.DataBasePath,'CN.csv'));
Table = Table(:,3:end);
CN = SG;
for i = 0:8
    for j = 1:4
        CN.Z((LULC_BaU.Z == i)&(SG.Z == j)) = Table(i+1,j);
    end
end

% Average CN
CN_avg      = double(round(mean(CN.Z(:),'omitnan'),4));

% Close waitbar
close(ProgressBar)