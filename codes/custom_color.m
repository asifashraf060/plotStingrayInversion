function [ColorArray, TickValue, TickLabels] = custom_color(tick_start, tick_end, tick_totalN, ColorMap_string)

    %    Example Usage: --
    %    [CA, TV, TL] = custom_color(1.5, 8.1, 5, 'thermal-2');
    %    colormap(flip(CA))
    %    colorbar('Ticks', TV, 'TickLabels', TL)

    %    WEBSITE:https://www.mathworks.com/matlabcentral/fileexchange/120088-200-colormap

    load('/Users/asifashraf/Downloads/slanCM (1)/slanCM/slanCM_Data.mat');
    
    clrMp = ColorMap_string;

    for i = 1:length(slandarerCM)
        ind = find(strcmp(slandarerCM(i).Names, clrMp) == 1);
        if ~isempty(ind)
         clrMp_arr = slandarerCM(i).Colors(ind);
        end
    end

    clrMp_arr = clrMp_arr{1, 1};
    
    
        a = clrMp_arr(:,1); aa = (linspace(a(1), a(end), length(clrMp_arr)))';
        b = clrMp_arr(:,2); bb = (linspace(b(1), b(end), length(clrMp_arr)))';
        c = clrMp_arr(:,3); cc = (linspace(c(1), c(end), length(clrMp_arr)))';
    
        clrMp_arr_dv = [];
        clrMp_arr_dv(:,1) = aa; clrMp_arr_dv(:,2) = bb; clrMp_arr_dv(:,3) = cc;
    
    tick_m = linspace(tick_start, tick_end, tick_totalN);
    
    for i = 1:length(tick_m)
        
        tkLb(1,i) = string(round(tick_m(i), 2));
    
    end

    ColorArray = clrMp_arr;
    TickValue  = tick_m;
    TickLabels = tkLb;


end