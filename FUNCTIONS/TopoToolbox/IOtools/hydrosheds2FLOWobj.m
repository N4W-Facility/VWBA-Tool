function FD = hydrosheds2FLOWobj(file)

%HYDROSHEDS2FLOWOBJ Import Hydrosheds flow direction raster to FLOWobj
%
% Syntax
%
%     FD = hydrosheds2FLOWobj(file)
%     FD = hydrosheds2FLOWobj(FLOWDIR)
%
% Description
%
%     hydrosheds2FLOWobj converts hydroshed flow direction grids to a
%     FLOWobj. DEM and flow directions grids can be downloaded from here:
%     https://hydrosheds.cr.usgs.gov/
%    
% Input arguments
%
%     file      location of file and filename (char)
%     FLOWDIR   GRIDobj with flow directions from hydrosheds
%
% Output arguments
%
%     FD        FLOWobj
%
% See also: FLOWobj, GRIDobj
%
% Author: Wolfgang Schwanghart (w.schwanghart[at]geo.uni-potsdam.de)
% Date: 26. April, 2018

if isa(file,'GRIDobj')
    FDIR = file;
else
    warning off
    FDIR = GRIDobj(file);
    warning on
end 


nr   = prod(FDIR.size);
refm = FDIR.refmat;
siz  = FDIR.size;
INAN = ~isnan(FDIR);

IX   = find(INAN.Z);
GC   = FDIR.Z(INAN.Z);

clear FDIR
clear INAN

gc = 2.^(0:7);
nrrows  = siz(1);
offsets = [nrrows nrrows+1 1 -nrrows+1 -nrrows -nrrows-1 -1 nrrows-1];

ix = [];
ixc = [];

for r = 1:numel(gc)
    I = GC == gc(r);
    ix  = [ix;IX(I)];
    ixc = [ixc;IX(I)+offsets(r)];
end
clear GC IX I

ix((ixc<1)|(ixc>nr)) = [];
ixc((ixc<1)|(ixc>nr)) = [];

G = digraph(ix, ixc);
G = remove_cycles(G);
% G = remove_cycles_dfsearch(G);
G = table2array(G.Edges);

M = sparse(G(:,1),G(:,2),true,nr,nr);
clear ix ixc    
FD = FLOWobj(M,'refmat',refm,'size',siz,'algorithm','toposort','cellsize',refm(2));

