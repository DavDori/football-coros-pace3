function data = extractFootballData(filename)
T = readstruct(filename,'FileType','xml');

laps = T.Activities.Activity.Lap;

i = 1;
data = cell(1,length(laps));
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
        if(any(strcmp(fieldnames(d.Extensions),'Speed')) && ~ismissing(d.Extensions))
            lap_table.Speed(j) = d.Extensions.Speed;
        else
            lap_table.Speed(j) = missing;
        end
        if(ismissing(d.Position))
            lap_table.LatitudeDegrees(j) = missing;
            lap_table.LongitudeDegrees(j) = missing;
        else
            lap_table.LatitudeDegrees(j) = d.Position.LatitudeDegrees;
            lap_table.LongitudeDegrees(j) = d.Position.LongitudeDegrees;
        end
    end
    data{i} = lap_table;
    str='LAP ['+string(i)+']: time='+string(lap.TotalTimeSeconds) + '[s]'+sprintf('\t')'...
        +'distance'+string(lap.DistanceMeters)+'[m]'+sprintf('\t')'...
        +'BPM max='+string(lap.MaximumHeartRateBpm.Value)+sprintf('\t')'...
        +'avg='+string(lap.AverageHeartRateBpm.Value);
    disp(str)
    i = i + 1;
end
end

