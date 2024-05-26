clc;
close all;
clear

%% Load data

filename = {'Data/fb1_2024_05_10.tcx'};
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

[timeline, timeline_player] = extractTimeline(players, ID_TRACK);


Hz = cellfun(@(p) 1 / mean(seconds(diff(p{ID_TRACK}.Time))), players, 'UniformOutput', false);

lat_min = min(cellfun(@(p) min(p{ID_TRACK}.LatitudeDegrees), players, 'UniformOutput', true));
lat_max = max(cellfun(@(p) max(p{ID_TRACK}.LatitudeDegrees), players, 'UniformOutput', true));
lon_min = min(cellfun(@(p) min(p{ID_TRACK}.LongitudeDegrees), players, 'UniformOutput', true)); 
lon_max = max(cellfun(@(p) max(p{ID_TRACK}.LongitudeDegrees), players, 'UniformOutput', true)); 

delta_map_lat = (lat_max - lat_min) * ZOOM_OUT_perc / 100.0;
delta_map_lon = (lon_max - lon_min) * ZOOM_OUT_perc / 100.0;





%% Heatmap

param_HM.th = 0.01;
param_HM.m = 20; % Number of rows (latitude)
param_HM.n = 20; % Number of columns (longitude)
param_HM.color_start = [1,0,0];
param_HM.color_end = [0.3,0.6,1];

% Create the edges of the bins
lat_edges = linspace(lat_min, lat_max, param_HM.n+1);
lon_edges = linspace(lon_min, lon_max, param_HM.m+1);

data = players{1}{ID_TRACK};
time_grid = zeros(param_HM.n, param_HM.m);
% Loop through each point and accumulate time spent in each cell
timediff = [1;seconds(diff(data.Time))];
lat_centers = (lat_edges(1:end-1) + lat_edges(2:end)) / 2;
lon_centers = (lon_edges(1:end-1) + lon_edges(2:end)) / 2;

for i = 1:length(data.LatitudeDegrees)
    % Find the indices of the cell for the current latitude and longitude
    lat_idx = find(data.LatitudeDegrees(i) < lat_edges, 1) - 1;
    lon_idx = find(data.LongitudeDegrees(i) < lon_edges, 1) - 1;
    
    % Make sure the indices are within the grid bounds
    lat_idx = max(1, min(lat_idx, param_HM.n));
    lon_idx = max(1, min(lon_idx, param_HM.m));
    
    % Accumulate the time in the corresponding cell
    time_grid(lat_idx, lon_idx) = time_grid(lat_idx, lon_idx) + timediff(i);
end

% Create latitude and longitude coordinates for the centers of the cells
[lon_mesh, lat_mesh] = meshgrid(lon_centers, lat_centers);


%% Represent heatmap

figure()
plotrunHeatmap(lat_mesh, lon_mesh, time_grid, param_HM)


%% Video

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