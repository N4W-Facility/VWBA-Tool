function FDnew = GRIDobjESRI2FLOWobj(DEM,ESRI_FD)
% Posi = FLOWobj(DEM);
% Posi = double(Posi.ix);

%% Step 1 - Match between DEM and ESRI FD
%ESRI_FD.Z = fillmissing(ESRI_FD.Z,'nearest');
ESRI_FD.Z(isnan(DEM.Z)) = NaN;
DEM.Z(isnan(ESRI_FD.Z)) = NaN;

%% Step 2 - Sort elevation 
[~,Posi]    = sort(DEM.Z(:),'descend');
Posi(isnan(DEM.Z(Posi))) = [];
Posi(end)   = [];

%% Step 3 - Mapping Flow Direction
%  ESRI              FLOWobj
%  32 64 128     |   -1-nrrows -1 -1+nrrows
%  16     1      |   -nrrows    0   nrrows
%  8  4   2      |   1-nrrows   1  1+nrrows
% Row number
nrrows = ESRI_FD.size(1);
% TopoTools Flow Direction
dir1   = [nrrows,1+nrrows, 1, 1-nrrows, -nrrows, -1-nrrows, -1, -1+nrrows]';
% ESRI ArcGIS Flow Direction
dir2   = [1 2 4 8 16 32 64 128]'; 
% Mappping Flow Direction
[~,Pf] = ismember(ESRI_FD.Z(Posi),dir2);
% Eliminar pixeles que se salen de la matrix
ixc = (Posi + dir1(Pf));
Posi((ixc > prod(ESRI_FD.size))) = [];
% Mappping Flow Direction
[~,Pf] = ismember(ESRI_FD.Z(Posi),dir2);
ixc = (Posi + dir1(Pf));
Posi((ixc < 1)) = [];
% Mappping Flow Direction
[~,Pf] = ismember(ESRI_FD.Z(Posi),dir2);

%% Step 4 - Create Flow Direction Structure
% FDnew               = FLOWobj;
% FDnew.size          = ESRI_FD.size;
% FDnew.type          = 'single';
% FDnew.ix            = uint32(Posi);
% FDnew.ixc           = uint32(Posi + dir1(Pf));
% FDnew.fraction      = [];
% FDnew.cellsize      = ESRI_FD.cellsize;
% FDnew.refmat        = ESRI_FD.refmat;
% FDnew.georef        = ESRI_FD.georef;
% FDnew.fastindexing  = 0;
% FDnew.ixcix         = [];

nr   = prod(ESRI_FD.size);
refm = ESRI_FD.refmat;
siz  = ESRI_FD.size;

ix  = uint32(Posi);
ixc = uint32(Posi + dir1(Pf));

M = sparse(ix,ixc,true,nr,nr);
clear ix ixc    
FDnew = FLOWobj(M,'refmat',refm,'size',siz,'algorithm','toposort','cellsize',refm(2));