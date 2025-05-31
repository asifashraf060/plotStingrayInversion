%% Script to plot the results of interface inversion
%
%  Asif, Nov 2023

% srOutput file type
file             = append('srRays_PmP*.mat');
% get directories of all pmp rays
srOutput_dir_pmp = dir(append(files.srOutputFolder, file));

[srEvent.x, srEvent.y] = map2xy(srEvent.longitude, srEvent.latitude, srGeometry);

for iarr=1:length(tlArrival.station)
tlArrival.xsta(iarr)=srStation.x(strcmp(srStation.name,tlArrival.station(iarr)));
tlArrival.ysta(iarr)=srStation.y(strcmp(srStation.name,tlArrival.station(iarr)));
tlArrival.xevt(iarr)=srEvent.x(find(srEvent.id==tlArrival.eventid(iarr)));
tlArrival.yevt(iarr)=srEvent.y(find(srEvent.id==tlArrival.eventid(iarr)));
end

% Make empty arrays for x, y position on the inverted interface
x_on_int = [];
y_on_int = [];

% Seperate the PmP phases from tlArrival
ii_ph = find(strcmp(tlArrival.phase, 'PmP')>0);
all_stations_pmp = unique(tlArrival.station(ii_ph));

for nn = 1:length(srOutput_dir_pmp)

    theRays  = append(srOutput_dir_pmp(nn).folder, '/', srOutput_dir_pmp(nn).name);
    load(theRays);
    
    station_index = find(strcmp(all_stations_pmp(nn), tlArrival.station)>0);

    staid = tlArrival.station(station_index);
    eid = tlArrival.eventid(station_index);

    xi  = tlArrival.xsta(station_index);
    yi  = tlArrival.ysta(station_index);
    zi  = zeros(size(yi));

    xe  = tlArrival.xevt(station_index);
    ye  = tlArrival.yevt(station_index);
    ze  = zeros(size(ye));

    disp(append('Calculating ray no. ', string(nn), ' out of ', string(length(srOutput_dir_pmp)), ' ...'))
    for idx = 2
        for ii = 1:length(eid)  % for each event id in the tlArrival that goes
            % with the stations loaded rays for
            [ie, je, ke] = xyz2ijk(xe(ii), ye(ii), ze(ii), srRays(idx).ghead);
            nstart       = ijk2num(ie, je, ke, srRays(idx).ghead);
            n            = iprec2ind(srRays(idx).iprec, nstart);
            [xr, yr, zr] = iprec2xyz(n, srRays(idx).ghead);
            nrays           = length(staid);
            RayPaths.x      = cell(nrays,1);
            RayPaths.y      = cell(nrays,1);
            RayPaths.z      = cell(nrays,1);
            RayPaths.elev   = cell(nrays,1);
            RayPaths.x{ii}  = [xi(ii);xr;xe(ii)];
            RayPaths.y{ii}  = [yi(ii);yr;ye(ii)];
            RayPaths.z{ii}  = [zi(ii);zr;ze(ii)];
            [RayPaths.lon{ii},RayPaths.lat{ii}] = xy2map(RayPaths.x{ii},RayPaths.y{ii},srGeometry);
            [ir,jr,~]         = xyz2ijk(RayPaths.x{ii},RayPaths.y{ii},RayPaths.z{ii},srRays(idx).ghead);
            nr                = ijk2num(ir,jr,ones(size(ir)),srRays(idx).ghead);
            RayPaths.elev{ii} = srRays(idx).elevation(nr) + RayPaths.z{ii};

            if min(RayPaths.z{ii})<0
                ind = find(RayPaths.z{ii} == min(RayPaths.z{ii}));
                x_on_int = vertcat(x_on_int,RayPaths.x{ii}(ind));
                y_on_int = vertcat(y_on_int,RayPaths.y{ii}(ind));
            end
        end
    end
end

% { 
%Plotting to check the bouncing points of PmP
figure
plot(srStation.x, srStation.y, '*r')
hold on
plot(srEvent.x, srEvent.y, '.r')
plot(x_on_int, y_on_int, '.k')
title('Bouncing points for all the PmP rays')
set(gca, 'FontSize', 16)
saveas(gcf, append(outDir_plot_intInv, 'pmp_bouncing_points.png'))
close all
%}

%% Transfer those bouncing point (bp) coordinates to the model space

[lon_bp, lat_bp] = xy2map(x_on_int, y_on_int, srGeometry);

% get the lat lon from model space based on bouncing points
lon_model = [];     lat_model = [];
for i = 1:length(lon_bp)

    ln = lon_bp(i); lt = lat_bp(i);
    [rLn, cLn] = find(int.srModel.LON > ln-.00001 & int.srModel.LON < ln+.00001);
    [rLt, cLt] = find(int.srModel.LAT > lt-.00001 & int.srModel.LAT < lt+.00001);
    
    r = intersect(rLn, rLt);              c = intersect(cLn, cLt);
    
    lonM = int.srModel.LON(r,c);          latM = int.srModel.LAT(r,c);
        
    if isempty(find(lon_model == min(lonM))) || isempty(find(lat_model == min(latM)))
        lon_model = vertcat(lon_model, min(lonM)); 
        lat_model = vertcat(lat_model, min(latM));
    end

end

% get the indices for the model lat-lon
lln = inv.srModel.LON(:,1);     llt = inv.srModel.LAT(1,:);
r_all = [];     c_all = [];
for i = 1:length(lon_model)

    r = find(abs(lln-lon_model(i)) == min(abs(lln-lon_model(i))));
    c = find(abs(llt-lat_model(i)) == min(abs(llt-lat_model(i))));
    
    % take the nearest points specified by point distance at the beginning
    n = pt*2 + 1;
    mt_r = [];
    for j = 1:n
        o = -pt:1:pt;
        z = zeros(n);
        mt_r(j,:) = squeeze(z(1,:))+o(j)+r;
    end
    mt_c = [];
    for j = 1:n
        o = -pt:1:pt;
        z = zeros(n);
        mt_c(:,j) = squeeze(z(:,1))+o(j)+c;
    end
        
    r_all = vertcat(r_all, r, mt_r(:));
    c_all = vertcat(c_all, c, mt_c(:));

end

%% Mask the interface
ind             = sub2ind(size(inv.srModel.interface(1).elevation), r_all, c_all);
inv_interp      = nan(size(inv.srModel.interface(1).elevation));
inv_interp(ind) = inv.srModel.interface(1).elevation(ind);


int_interp      = nan(size(int.srModel.interface(1).elevation));
int_interp(ind) = int.srModel.interface(1).elevation(ind);

%% Write the masked interface in a text file
ind = find(~isnan(int_interp));

int_interp_op = inv_interp(ind);
int_x_op      = inv.srModel.interface(1).X(ind);
int_y_op      = inv.srModel.interface(1).Y(ind);

[int_lon, int_lat] = xy2map(int_x_op, int_y_op, srGeometry);

fileID = fopen(append(outDir_data_intInv,'masked_inverted_Interface.txt'), 'w');
if fileID == -1
    error('Failed to open the file.');
end

% Write the header
fprintf(fileID, '%s\t%s\t%s\n', 'lon', 'lat', 'depth');

% Write the data
for i = 1:length(int_lon)
    fprintf(fileID, '%f\t%f\t%f\n', int_lon(i), int_lat(i), int_interp_op(i));
end

% {
% plot to check the masked version

xlm = [min(int.srModel.LON(:)) max(int.srModel.LON(:))];         ylm = [min(int.srModel.LAT(:)) max(int.srModel.LAT(:))];
xA = min(xlm):.01:max(xlm);   yA  = min(ylm):.01:max(ylm);
[xAG, yAG] = meshgrid(xA, yA);
int_cut = griddata(int.srModel.LON, int.srModel.LAT, int.srModel.interface(1).elevation, xAG, yAG);
inv_cut = griddata(inv.srModel.LON, inv.srModel.LAT, inv.srModel.interface(1).elevation, xAG, yAG);

figure('Position', [10 10 2000 1200])

subplot(1,2,1)
[c,h] = contour(xAG', yAG', -1.*(inv_cut'), [10:2.5:40],  'LineStyle', '--', 'LineWidth',2);
clabel(c,h)
hold on
contourf(inv.srModel.LON', inv.srModel.LAT', -1.*(inv_interp'), [10:2.5:40], 'LineStyle', '-');
colormap("cool")
colorbar
title('Inverted Interface')
set(gca, 'FontSize', 16)

subplot(1,2,2)
[c,h] = contour(xAG', yAG', -1.*(int_cut'), [10:2.5:40],  'LineStyle', '--', 'LineWidth',2);
clabel(c,h)
hold on
contourf(inv.srModel.LON', inv.srModel.LAT', -1.*(int_interp'), [10:2.5:40], 'LineStyle', '-');
colormap("cool")
colorbar
title('Initial Interface')
set(gca, 'FontSize', 16)

saveas(gcf, append(outDir_plot_intInv, 'result.png'))

figure
contourf(inv.srModel.LON', inv.srModel.LAT', (int_interp - inv_interp)', 'LineStyle', '-')
colormap("cool")
colorbar
title('Interface perturbation in inversion')
set(gca, 'FontSize', 16)

saveas(gcf, append(outDir_plot_intInv, 'perturb.png'))


