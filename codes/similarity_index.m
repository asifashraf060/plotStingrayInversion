
% use the slab to nan values below the slab

    % make slab from moho
slab = inv.srModel.interface(1).elevation + 6;

    % put nans below slab
Vp_woSlab = [];
for i = 1:length(dp_hang_array)
    
    dp = dp_hang_array(i);
    vp_xy = squeeze(model_hanged(:,:,i));
    
    vp_xy(find(slab>dp)) = nan;

    Vp_woSlab(:,:,i) = vp_xy;
end

% use dws to make the 3-D Vp model invisible where I don't have data
dws_modelSpace(dws_modelSpace<dws_lwBound) = NaN;
Vp_woSlab(isnan(dws_modelSpace)) = NaN;

% import shapefile
disp(' ')
theS1 = input('Enter shapefile directory: ');
S = shaperead(theS1);

% find regions within the boundary of shapefile
[lon_grid_s, lat_grid_s] = meshgrid(min(S.X):0.15:max(S.X),...
                                    min(S.Y):0.15:max(S.Y));
lon_grid_s_flat  = lon_grid_s(:); lat_grid_s_flat = lat_grid_s(:);
inside_shapefile = inpolygon(lon_grid_s_flat, lat_grid_s_flat, S.X, S.Y);

shapefile1_lon = lon_grid_s_flat(inside_shapefile);
shapefile1_lat = lat_grid_s_flat(inside_shapefile);

[s1_ln_g, s1_lt_g] = meshgrid(shapefile1_lon, shapefile1_lat);

% calculating average velocity depth profile for shapefile bounded region
disp(' ')
disp('Average velocity calc. within imported shapefile :')

avg_vp_dp_s = [];
for i = 1:dp_intv_SI:length(dp_hang_array)

    disp(append('    Looping through dp ', string(i), ' out of ', string(length(dp_hang_array))))

    vp_xy = squeeze(Vp_woSlab(:,:,i));
    vp_s  = griddata(inv.srModel.LON, inv.srModel.LAT, vp_xy, s1_ln_g, s1_lt_g);

    vp_s(isnan(vp_s)) = []; s_mean = mean(vp_s);

    avg_vp_dp_s = vertcat(avg_vp_dp_s, s_mean);

end

dp_sm = dp_hang_array(1:dp_intv_SI:end);

figure('Position', [10 10 400 800])
plot(dp_sm, avg_vp_dp_s, 'ob', 'LineWidth',2)
grid on
view([90 -90])
title('Average velocity profile')
ylabel('Velocity'); xlabel('Elevation (km)')
set(gca, 'LineWidth', 2, 'FontSize', 16)
saveas(gcf, append(outDir_plot_smInd, 'avg_pr.png'))

close all

% calculating similarity index w.r.t. average velocity depth profile
disp(' ')
disp('Working on SI ...')
s2_idx = [];
for i = 1:length(Vp_woSlab)

    vp_2D = squeeze(Vp_woSlab(i,:,:));

    s_idx = [];

    for j = 1:length(vp_2D)

        vp_1D = squeeze(vp_2D(j,:));
        vp_1D = vp_1D(1:dp_intv_SI:length(dp_hang_array));

        diff  = (abs(vp_1D' - avg_vp_dp_s));

        s_idx(j,:)  = diff;

    end

s_idx  = rescale((-1.* (s_idx-max(max(s_idx)))), 0, 1);

s2_idx(i,:,:) = s_idx;

end

disp('   plotting SI...')
[CA, TV, TL] = custom_color(0, 1, 9, 'jet');

x_str = []; y_str = []; z_str = [];
for i = 1:length(dp_sm)

    SI_map = squeeze(s2_idx(:,:,i));
    dp = dp_sm(i);

    figure('Position', [10 10 900 600])
    [C,h] = contourf(inv.srModel.LON, inv.srModel.LAT, SI_map, [0:0.1:1]);
    C = CA; C(end+1,:) = 1;
    colormap((CA))
    caxis([0 1])
    colorbar('Ticks', TV, 'TickLabels', TL)
    axis equal
    title(append('SI map at ', string(dp), ' km elevation'))
    set(gca, 'FontSize', 16)
    saveas(gcf, append(outDir_plot_SImap, 'mapSec', string(i), '.png'))
    close all

    if SI_pick == 1
        
        SI_map(find(SI_map<(dsi-.05))) = nan; SI_map(find(SI_map>(dsi+.05))) = nan;
        
        figure('Position', [10 10 900 600])
        [C,h] = contourf(inv.srModel.LON, inv.srModel.LAT, SI_map, [0:0.1:1]);
        C = CA; C(end+1,:) = 1;
        colormap((CA))
        caxis([0 1])
        colorbar('Ticks', TV, 'TickLabels', TL)
        axis equal

        hold on
        s1  = shaperead('/Users/asifashraf/Documents/Casc_Exp_Files/shapefiles/Siletz_terrane.shp');
        mapshow(s1, 'FaceAlpha',0.01, 'LineWidth',4, 'EdgeColor', 'y', 'LineStyle', '--')
        xlim([min(inv.srModel.LON(:)) max(inv.srModel.LON(:))])
        ylim([min(inv.srModel.LAT(:)) max(inv.srModel.LAT(:))])

        set(gca, 'FontSize', 16)
        
        title(append('at ', string(dp), ' km elv of ', string(dsi), ' SI',' [Pick then Press enter]'))

        [xSI,ySI] = ginput();
        dpSI = zeros(length(xSI), 1) + dp;

        if ~isempty(xSI)
            hold on
            plot(xSI, ySI, '-b')
            x_str = vertcat(x_str, xSI); 
            y_str = vertcat(y_str, ySI); 
            z_str = vertcat(z_str, dpSI);
        end

        title(append('at ', string(dp), ' km elv of ', string(dsi), ' SI'))
        
        saveas(gcf, append(outDir_plot_SIiso, 'mapSec', string(i), '.png'))
        close all

    end

end

fileID = fopen(append(outDir_data_SIiso,'isoSI_', string(dsi), '_str.txt'),'w');

fprintf(fileID, '%12.5s %12.5s %12.5s\n', 'X', 'Y', 'Z');

for i = 1:length(x_str)
    fprintf(fileID, '%12.5f %12.5f %12.5f\n', x_str(i), y_str(i), z_str(i));
end

fclose(fileID)









