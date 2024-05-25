function [timeline,timeline_id] = extractTimeline(players, ID_TRACK)

timeline_m = cellfun(@(p) p{ID_TRACK}.Time, players, 'UniformOutput', false);
len = cellfun(@(p) length(p{ID_TRACK}.Time), players, 'UniformOutput', true);
len = [1, len];
ub = cumsum(len(2:end));
lb = cumsum(len(1:end-1));

timeline_m = vertcat(timeline_m{:});
[timeline, tidx] = sort(timeline_m);

timeline_id = zeros(size(timeline));
for i = 1:length(ub)
    ubi = ub(i);
    lbi = lb(i);
    player_idx = find(tidx <= ubi & tidx >= lbi);
    timeline_id(player_idx) = i * ones(length(player_idx),1);
end
end

