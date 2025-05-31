% to plot imported shapefiles on the existing plot

hold on

mapshow(s1, 'EdgeColor', 'k', 'FaceColor', 'w', 'FaceAlpha', .01, 'LineWidth', 2)


plot(s4.X, s4.Y, 'k', 'LineWidth', 5)
plot(s4.X, s4.Y, 'g', 'LineWidth', 3)


plot(s3.X, s3.Y, 'k', 'LineWidth', 5)
plot(s3.X, s3.Y, 'm', 'LineWidth', 3)

plot(s2.X, s2.Y, 'k', 'LineWidth', 6)
plot(s2.X, s2.Y, 'y', 'LineWidth', 3)

for j = 1:length(s5)
    plot(s5(j).X, s5(j).Y, '--b', 'LineWidth',2)
end

for j = 1:length(s6)
    plot(s6(j).X, s6(j).Y, '--b', 'LineWidth',2)
end


for j = 1:length(s7)
    utmCRS = projcrs(32610); wgsCRS = geocrs(4326);
    [lat_s7, lon_s7] = projinv(utmCRS, s7(j).X, s7(j).Y);
    plot(lon_s7, lat_s7, '--r', 'LineWidth',1)
end

ln_rg = table2array(tb_rg(:,1));     lt_rg = table2array(tb_rg(:,2));

plot(ln_rg, lt_rg, '--b', 'LineWidth',2)