close all, clc, clear

%% Inputs

inv_folder_name  = '250408_131744';
iteration_no     = 7;
dws_lwBound      = 5;

% switches to activate & modulate analysis
hangModel = 1;
plotModel = 0;
smIndex   = 1;
    dp_intv_SI = 1;
        SI_pick = 1;
            dsi = .9;



%% Calculation

% set up directories

scriptDir = fileparts(mfilename('fullpath'));
cd(scriptDir)
cd ..

outDir_plot_mapSec = [pwd, '/outputs/plots/map_sections/'];
outDir_plot_xSecLn = [pwd, '/outputs/plots/x_sections@lons/'];
outDir_plot_xSecLt = [pwd, '/outputs/plots/x_sections@lats/'];
outDir_plot_smInd  = [pwd, '/outputs/plots/similarityIndex/'];
outDir_plot_SImap  = [pwd, '/outputs/plots/similarityIndex/SI_map/'];
outDir_plot_SIiso  = [pwd, '/outputs/plots/similarityIndex/isoSm_map/'];


cd(scriptDir)

% get all the inversion files
[files] = grabFiles(inv_folder_name, iteration_no);

% load all the inversion files

% starting/initial model
int = load(files.theintModel);
% inverted model
inv = load(files.theinvModel);
% tlArrival
load(files.theArrival);
% srStation
load(files.theStation);
% srEvent
load(files.theEvent);
% srGeometry
load(files.theGeometry);
% tlPert
load(files.thePert);

disp('Inversion files are loaded')

disp('Interpolating DWS in model space ...')
[PertX, PertY, PertZ]    = meshgrid(tlPert.U.P.y, tlPert.U.P.x, tlPert.U.P.z);
[ModelX, ModelY, ModelZ] = meshgrid(inv.srModel.yg, inv.srModel.xg, inv.srModel.zg);
dws_modelSpace           = interp3(PertX, PertY, PertZ, tlPert.U.P.dws, ModelX, ModelY, ModelZ);

% Hang the model from topography
if hangModel == 1
    disp('Hanging model from topography ...')
    [model_hanged, dp_hang_array] = hang_from_Elevation(inv.srModel, dws_modelSpace, dws_lwBound, .2);
end

%% plot model
% 
if plotModel == 1
    
    disp('Plotting the model ...')
    [CA, TV, TL] = custom_color(1.5, max(model_hanged(:)), 11, 'thermal-2');
    
    % map sections
    for i = 1:length(dp_hang_array)
    
        dp = dp_hang_array(i);
        model_mapSection = squeeze(model_hanged(:,:,i));
    
        figure('Position', [10 10 900 600])
        [C,h] = contourf(inv.srModel.LON, inv.srModel.LAT, model_mapSection, ...
                        1.5:.5:max(model_hanged(:)));
        C = CA; C(end+1,:) = 1;
        colormap(flip(CA))
        caxis([1.5 max(model_hanged(:))])
        colorbar('Ticks', TV, 'TickLabels', TL)
        axis equal
        title(append('Map section at ', string(dp), ' km elevation'))
        set(gca, 'FontSize', 16)
        saveas(gcf, append(outDir_plot_mapSec, 'mapSec', string(i), '.png'))
        close all
    
    end

end

%% Similarity Index

if smIndex == 1

    disp('Calculating similarity index ...')
    run('similarity_index.m')

end



