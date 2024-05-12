clc;
close all;
clear

%% Load data

filename = 'Data\fb_2024_05_10.tcx';
T = readstruct(filename,'FileType','xml');

%% Extract valuable data

laps = T.Activities.Activity.Lap;

i = 1;
track = cell(1,length(laps));
for lap = laps
    data_points = lap.Track.Trackpoint;

    varTypes = ["datetime","double","double","double","double"];
    varNames = ["Time","HeartRateBpm","Speed","LatitudeDegrees","LongitudeDegrees"];
    sz = [size(data_points,2), 5];
    lap_table = table('Size',sz,'VariableTypes',varTypes,'VariableNames',varNames);

    for j = 1:size(data_points,2)
        d = data_points(j);
        lap_table.Time(j) = datetime(d.Time,'Format',"uuuu-MM-dd'T'HH:mm:ss'Z'");
        if(ismissing(d.HeartRateBpm))
            lap_table.HeartRateBpm(j) = missing;
        else
            lap_table.HeartRateBpm(j) = d.HeartRateBpm.Value;
        end
        if(ismissing(d.Extensions))
            lap_table.Speed(j) = missing;
        else
            lap_table.Speed(j) = d.Extensions.Speed;
        end
        if(ismissing(d.Position))
            lap_table.LatitudeDegrees(j) = missing;
            lap_table.LongitudeDegrees(j) = missing;
        else
            lap_table.LatitudeDegrees(j) = d.Position.LatitudeDegrees;
            lap_table.LongitudeDegrees(j) = d.Position.LongitudeDegrees;
        end
    end
    track{i} = lap_table;
    str='LAP ['+string(i)+']: time='+string(lap.TotalTimeSeconds) + '[s]'+sprintf('\t')'...
        +'distance'+string(lap.DistanceMeters)+'[m]'+sprintf('\t')'...
        +'BPM max='+string(lap.MaximumHeartRateBpm.Value)+sprintf('\t')'...
        +'avg='+string(lap.AverageHeartRateBpm.Value);
    disp(str)
    i = i + 1;
end

clear i lap d data_points sz T varNames varTypes str

%% Repair missing data
% check for missing values or NaN and replace them by looking at their
% closest neighbour

for i = 1:size(track{ID_TRACK},1)

end

%% Represent data

% select the track to represent
ID_TRACK = 1;
TIME_WINDOW_s = 20;
COLOR_START= [0.5,0.4,0.2];
COLOR_END = [1,0,0];
WIDTH_START = 0.5;
WIDTH_END = 3;
ZOOM_OUT_perc = 20;

Hz = 1 / mean(seconds(diff(track{ID_TRACK}.Time)));

lat_min = min(track{ID_TRACK}.LatitudeDegrees);
lat_max = max(track{ID_TRACK}.LatitudeDegrees); 
lon_min = min(track{ID_TRACK}.LongitudeDegrees); 
lon_max = max(track{ID_TRACK}.LongitudeDegrees);

delta_map_lat = (lat_max - lat_min) * ZOOM_OUT_perc / 100.0;
delta_map_lon = (lon_max - lon_min) * ZOOM_OUT_perc / 100.0;

window_size = round(TIME_WINDOW_s * Hz); 
figure('Position',[0,500,1000,800])
for i = 1:size(track{ID_TRACK},1)
    if(all(isnan(track{ID_TRACK}.LatitudeDegrees(i_low:i))) || all(isnan(track{ID_TRACK}.LongitudeDegrees(i_low:i))))
        continue;
    end
    i_low = max([i-window_size,1]);
    
    plotrun(track{ID_TRACK}.LatitudeDegrees(i_low:i), track{ID_TRACK}.LongitudeDegrees(i_low:i),...
        COLOR_START,COLOR_END,WIDTH_START,WIDTH_END)
    geobasemap satellite
    geolimits([lat_min-delta_map_lat, lat_max+delta_map_lat],...
              [lon_min-delta_map_lon, lon_max+delta_map_lon])
    pause(0.1);
    clf
end