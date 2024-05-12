function plotrun(lat, lon, color_start, color_end, width_start, width_end)

red_ramp = linspace(color_start(1), color_end(1), length(lat)-1);
green_ramp = linspace(color_start(2), color_end(2), length(lat)-1);
blue_ramp = linspace(color_start(3), color_end(3), length(lat)-1);
width_ramp = linspace(width_start, width_end, length(lat)-1);
for i = 1:length(lat)-1
    c = [red_ramp(i), green_ramp(i), blue_ramp(i)];
    w = width_ramp(i);
    geoplot([lat(i+1),lat(i)], [lon(i+1),lon(i)],'Color',c,'LineWidth',w)
    hold on
end
end

