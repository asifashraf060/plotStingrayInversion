% to perform similarity index for multiple shapefiles


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

s_total = 3;

% Shapefile import -- user input
clear sst; % sst = shapefile structure
for i = 1:s_total
    sst(i).direc = input(append('Enter shapefile directory (', string(i), ...
                                '/', string(s_total), '): ' ));
    sst(i).name  = input('   name:');
end

% calculate within each shapefile
for i = 1:s_total

    S = shaperead(sst(i).direc);

    % find regions within the boundary of shapefile
    [lon_grid_s, lat_grid_s] = meshgrid(min(S.X):0.15:max(S.X),...
                                        min(S.Y):0.15:max(S.Y));
    lon_grid_s_flat  = lon_grid_s(:); lat_grid_s_flat = lat_grid_s(:);
    inside_shapefile = inpolygon(lon_grid_s_flat, lat_grid_s_flat, S.X, S.Y);
    shapefile1_lon = lon_grid_s_flat(inside_shapefile);
    shapefile1_lat = lat_grid_s_flat(inside_shapefile);
    [s1_ln_g, s1_lt_g] = meshgrid(shapefile1_lon, shapefile1_lat);

    disp(append('Avg V calc for shapefile-(', string(i),'/', string(s_total),')'))
    
    % average Vp at each depth
    avg_vp_dp_s = [];
    for j = 1:dp_intv_SI:length(dp_hang_array)
    
        disp(append('    dp (', string(i), '/', string(length(dp_hang_array), ')')))
    
        vp_xy = squeeze(Vp_woSlab(:,:,i));
        vp_s  = griddata(inv.srModel.LON, inv.srModel.LAT, vp_xy, s1_ln_g, s1_lt_g);
    
        vp_s(isnan(vp_s)) = []; s_mean = mean(vp_s);
    
        avg_vp_dp_s = vertcat(avg_vp_dp_s, s_mean);
    
    end

    % depth array corresponding to the Vp profile
    dp_sm = dp_hang_array(1:dp_intv_SI:end);

    % write the avg Vp profile
    fileID = fopen(append(outDir_plot_smInd, 'avg_Vp_', sst(i).name, '.txt'), 'w');
    fprintf(fileID, '%12.5s %12.5s\n', 'Dp', 'Vp');
    for j = 1:length(dp_sm)
        fprintf(fileID, '%12.5f %12.5f\n', dp_sm(i), avg_vp_dp_s(i))
    end
    fclose(fileID);

end