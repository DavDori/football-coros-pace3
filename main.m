clc;
close all;
clear

%% Load data

filename = 'Data\fb_2024_05_10.tcx';
T = readstruct(filename,'FileType','xml');

%% Extract valuable data

laps = T.Activities.Activity.Lap;

i = 1;
for lap = laps
    str='LAP ['+string(i)+']: time='+string(lap.TotalTimeSeconds) + '[s]'+sprintf('\t')'...
        +'distance'+string(lap.DistanceMeters)+'[m]'+sprintf('\t')'...
        +'BPM max='+string(lap.MaximumHeartRateBpm.Value)+sprintf('\t')'...
        +'avg='+string(lap.AverageHeartRateBpm.Value);
    disp(str)
    i = i + 1;
end