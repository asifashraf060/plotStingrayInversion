close all, clc, clear

%% Inputs

inv_folder_name  = '250428_161559';
iteration_no     = 7;
dws_lwBound      = 1;

% switches to activate & modulate analysis

% hang the srModel from elevation to plot the model w.r.t. MSL
hangModel      = 1;
dws_mask       = 1;
% plot the map and x sections of the model
plotInvModel   = 0;
    map_s      = 1;
    x_s        = 0;
% plot the inverted interface result
plotInvInt     = 0;
    pt         = 10;        % point distance for performing nearest neighborhood
% calculate the similarity to an average depth profile of a certain region 
smIndex        = 1;
    single     = 0;                     multi   = 1;        % must toggle one of single/multi off
        dp_intv_SI = 2;                     s_total = 3;
        SI_pick    = 1; dsi = .9;


%% Calculation

% set up directories

scriptDir = fileparts(mfilename('fullpath'));
cd(scriptDir)
cd ..

inpDir_shapefiles  = [pwd, '/inputs/shapefiles/'];

outDir_plot_mapSec = [pwd, '/outputs/plots/map_sections/'];
outDir_plot_xSecLn = [pwd, '/outputs/plots/x_sections@lons/'];
outDir_plot_xSecLt = [pwd, '/outputs/plots/x_sections@lats/'];
outDir_plot_intInv = [pwd, '/outputs/plots/interfaceInversion/'];
outDir_data_intInv = [pwd, '/outputs/data/interfaceInversion/'];
outDir_plot_smInd  = [pwd, '/outputs/plots/similarityIndex/'];
outDir_plot_SImap  = [pwd, '/outputs/plots/similarityIndex/SI_map/'];
outDir_plot_SIiso  = [pwd, '/outputs/plots/similarityIndex/isoSm_map/'];
outDir_data_SIiso  = [pwd, '/outputs/data/similarityIndex/isoSI/'];

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

% lat-lon from x-y
[ln, lt_fk] = xy2map(inv.srModel.xg, ... % converting X-Y to Lons-Lats for plotting
                        (linspace(min(inv.srModel.yg), max(inv.srModel.yg), length(inv.srModel.xg)))',...
                            srGeometry);
[ln_fk, lt] = xy2map((linspace(min(inv.srModel.xg), max(inv.srModel.xg), length(inv.srModel.yg)))',... % converting X to Lons for plotting
                        inv.srModel.yg,...
                            srGeometry);

disp('Calculating dws ...')
run("dws_calc.m")

% Hang the model from topography
if hangModel == 1
    disp('Hanging model from topography ...')
    [model_hanged, dp_hang_array] = hang_from_Elevation(inv.srModel, dws_mask, dws_modelSpace, dws_lwBound, .2);
end

%% plot model
% 
if plotInvModel == 1
    
    disp('Plotting the model ...')
    [CA, TV, TL] = custom_color(1.5, max(model_hanged(:)), 11, 'thermal-2');
    
    run("load_shapefiles.m") % loading all shapefiles for different structures

    % map sections
    if map_s == 1
        for i = 1:length(dp_hang_array)
        
            dp = dp_hang_array(i);
            model_mapSection = squeeze(model_hanged(:,:,i));
        
            figure('Position', [10 10 900 600])
            [C,h] = contourf(inv.srModel.LON, inv.srModel.LAT, model_mapSection, ...
                            1.5:.5:8.1);
            %C = CA; C(end+1,:) = 1;
            colormap(flip(jet(13)))
            caxis([1.5 8.1])
            %colorbar('Ticks', TV, 'TickLabels', TL)
            colorbar
            run('plot_shapefiles.m')
    
            xlim([ln_min ln_max]); ylim([lt_min lt_max])
    
            title(append('Map section at ', string(dp), ' km elevation'))
            set(gca, 'FontSize', 16)
            saveas(gcf, append(outDir_plot_mapSec, 'mapSec', string(i), '.png'))
            close all
        
        end
    end

    % x-sections
    if  x_s == 1
        [xSecLn_xg, xSecLn_yg] = meshgrid(ln, dp_hang_array); % mehsgrid to plot
        [xSecLt_xg, xSecLt_yg] = meshgrid(lt, dp_hang_array); % mehsgrid to plot
    
        % along the longitudes
        for i = c_top:c_bot
            
            lat = lt(i);
            model_xSection = squeeze(model_hanged(:,i,:));
    
            figure('Position', [10 10 900 600])
            [C,h] = contourf(xSecLn_xg, xSecLn_yg, model_xSection', ...
                                1.5:.5:max(model_hanged(:)));
            C = CA; C(end+1,:) = 1;
            colormap(flip(CA))
            caxis([1.5 max(model_hanged(:))])
            colorbar('Ticks', TV, 'TickLabels', TL)
            xlim([ln_min ln_max])
            ylim([-60 max(dp_hang_array)])
            title(append('X section at ', string(lat), ' latitude'))
            set(gca, 'FontSize', 16)
            saveas(gcf, append(outDir_plot_xSecLn, 'xSec', string(i), '.png'))
            close all
        end
    
        % along the latitudes
        for i = r_left:r_right
            
            lon = ln(i);
            model_xSection = squeeze(model_hanged(i,:,:));
    
            figure('Position', [10 10 900 600])
            [C,h] = contourf(xSecLt_xg, xSecLt_yg, model_xSection', ...
                                1.5:.5:max(model_hanged(:)));
            C = CA; C(end+1,:) = 1;
            colormap(flip(CA))
            caxis([1.5 max(model_hanged(:))])
            colorbar('Ticks', TV, 'TickLabels', TL)
            xlim([lt_min lt_max])
            ylim([-60 max(dp_hang_array)])
            title(append('X section at ', string(lon), ' longitude'))
            set(gca, 'FontSize', 16)
            saveas(gcf, append(outDir_plot_xSecLt, 'xSec', string(i), '.png'))
            close all
        end
    end
end

if plotInvInt == 1

    disp('Plotting the interface inversion result ...')
    run('plot_interfaceInversion.m')

end


%% Similarity Index

if smIndex == 1
    if single == 1
        disp('Calculating similarity index for single shapefile ...')
        run('similarity_index.m')
    end
    if multi == 1
        disp('Calculating similarity index for multiple shapefiles ...')
        run('similarity_index_multi.m')
    end
end



