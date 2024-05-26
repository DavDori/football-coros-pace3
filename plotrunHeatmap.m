function plotrunHeatmap(lat_mesh, lon_mesh, time_grid, param_HM)

norm_time_grid = time_grid./max(time_grid(:));

for i = 1:param_HM.n
    for j = 1:param_HM.m
        if norm_time_grid(i,j) < param_HM.th
            continue;
        end        
        % Fill the rectangle with a color based on the time spent
        color = norm_time_grid(i,j)*param_HM.color_start ...
            + (1-norm_time_grid(i,j))*param_HM.color_end;  
        geoplot(lat_mesh(i,j), lon_mesh(i,j), 's', 'Color', color,'MarkerFaceColor',color);
        hold on
    end
end
geobasemap satellite
title('Heatmap of Time Spent in Each Cell Overlaid on Geoplot');