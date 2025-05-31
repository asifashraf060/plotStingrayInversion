% load the shapefiles from input folder


%% import the shapefiles

% us states
s1 = shaperead(append(inpDir_shapefiles, 'cb_2018_us_state_500k.shp'));

% Siletz terrane
s2 = shaperead(append(inpDir_shapefiles, 'Siletz_terrane.shp'));

% klamath terrane
s3 = shaperead(append(inpDir_shapefiles, 'Klamath.shp'));

% Franciscan terrane
s4 = shaperead(append(inpDir_shapefiles, 'franciscan.shp'));

% CFM faults
s5 = shaperead(append(inpDir_shapefiles, 'cfm.shp'));

% wells et al. (2017) crustal faults
s6 = shaperead(append(inpDir_shapefiles, 'crustal_faults.shp'));

% propagator wakes
s7 = shaperead(append(inpDir_shapefiles, 'PSF_Horning2016.shp'));

% rougue fault
tb_rg = readtable(append(inpDir_shapefiles, 'rg_flt.txt'));