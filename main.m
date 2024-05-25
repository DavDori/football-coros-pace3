clc;
close all;
clear

%% Load data

filename ={'Data/fb1_2024_05_10.tcx'}% {'Data/fb_2024_05_10.tcx', 'Data/fb1_2024_05_10.tcx'};
% Extract valuable data
players = cellfun(@(n) extractFootballData(n), filename, 'UniformOutput', false);


%% Represent data

% select the track to represent
ID_TRACK = 1;
TAIL_TIME_WINDOW_s = 10;
COLOR_START = {[0.2,0.8,0.2],[0.5,0.7,0.1]};
COLOR_END = {[1,0,0],[0,0,1]};
WIDTH_START = 1;
WIDTH_END = 4;
ZOOM_OUT_perc = 20;

Hz = cellfun(@(p) 1 / mean(seconds(diff(p{ID_TRACK}.Time))), players, 'UniformOutput', false);
lat_min = min(cellfun(@(p) min(p{ID_TRACK}.LatitudeDegrees), players, 'UniformOutput', true));
lat_max = max(cellfun(@(p) max(p{ID_TRACK}.LatitudeDegrees), players, 'UniformOutput', true));
lon_min = min(cellfun(@(p) min(p{ID_TRACK}.LongitudeDegrees), players, 'UniformOutput', true)); 
lon_max = max(cellfun(@(p) max(p{ID_TRACK}.LongitudeDegrees), players, 'UniformOutput', true)); 

delta_map_lat = (lat_max - lat_min) * ZOOM_OUT_perc / 100.0;
delta_map_lon = (lon_max - lon_min) * ZOOM_OUT_perc / 100.0;

window_size = cellfun(@(f) round(TAIL_TIME_WINDOW_s * f), Hz); 
figure('Position',[0,500,1000,800])
ax = geoaxes;
for i = 1:size(track{ID_TRACK},1)
    
    for j = 1:length(track)
        i_low = max([i-window_size{j},1]);
        if(all(isnan(track{ID_TRACK}.LatitudeDegrees(i_low:i))) || all(isnan(track{ID_TRACK}.LongitudeDegrees(i_low:i))))
            continue;
        end
        tr = track{j};
        tr = tr{ID_TRACK};
        plotrun(tr.LatitudeDegrees(i_low:i), tr.LongitudeDegrees(i_low:i),...
            COLOR_START{j},COLOR_END{j},WIDTH_START,WIDTH_END)
        text(tr.LatitudeDegrees(i)+0.00001,tr.LongitudeDegrees(i)+0.00001,...
            string(tr.Speed(i))+"km/h",'Color',[1,1,1]);
    end
    geobasemap satellite
    geolimits([lat_min-delta_map_lat, lat_max+delta_map_lat],...
              [lon_min-delta_map_lon, lon_max+delta_map_lon])
    pause(0.05)
    clf
end