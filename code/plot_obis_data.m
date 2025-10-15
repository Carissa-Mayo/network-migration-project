clear; clc; close all;

% Add name of each csv file you want to load to the array below
datasets = ["obis_seamap_species_173830_points.csv" ,"obis_seamap_species_173836_points.csv", "obis_seamap_species_173833_points.csv"];

% What method should be used when plotting data
plotBy = "Dataset"; % Options are: Month, Year, Animal, Dataset

earliestYear = 2000; % Ignore datasets before this year

% Only use data that was collected with this platform type
platformType = "tag"; % Set to "all" to use all platform types

figure; hold on;
legendVals = strings(numel(datasets),1);

for i = 1:numel(datasets)
    disp("Loading Dataset " + i);
    dataset = datasets(i);
    dataFull = readtable(dataset);

    % Filter by platform type and keep unique columns
    if platformType == "all"
        data = dataFull(:, {'date_time','dataset_id','row_id','latitude','longitude','species_name','common_name','platform'});
    else
        mask = dataFull.platform == platformType;
        data = dataFull(mask, {'date_time','dataset_id','row_id','latitude','longitude','species_name','common_name','platform'});
    end

    disp("Plotting Dataset " + i);

    % Make row_id numeric more robustly
    if iscellstr(data.row_id) || isstring(data.row_id)
        parts = split(string(data.row_id), '_');
        if size(parts,2) >= 2
            data.row_id_num = str2double(parts(:,2));
        else
            data.row_id_num = NaN(height(data),1);
        end
    else
        data.row_id_num = double(data.row_id);
    end

    % Sort by names, not column numbers
    data = sortrows(data, {'common_name','row_id_num'});

    % Derive time fields
    data.month = month(data.date_time);
    data.year  = year(data.date_time);

    % Daily means per animal (fixing averaging bug)
    animalIds = unique(data.dataset_id);

    normalizedData = table('Size',[0 5], ...
        'VariableTypes', ["double","double","string","string","datetime"], ...
        'VariableNames', ["latitude","longitude","dataset_id","common_name","date_time"]);

    for k = 1:numel(animalIds)
        di = data(data.dataset_id == animalIds(k) & data.year >= earliestYear, :);
        if isempty(di), continue; end
        di.date_time = dateshift(di.date_time, 'start', 'day');
        uniqDays = unique(di.date_time);
        for d = 1:numel(uniqDays)
            maskDay = di.date_time == uniqDays(d);
            latm = mean(di.latitude(maskDay), 'omitnan');
            lonm = mean(di.longitude(maskDay), 'omitnan');
            normalizedData = [normalizedData; ...
                {latm, lonm, string(animalIds(k)), string(di.common_name(1)), uniqDays(d)}];
        end
    end

    % Plot using normalizedData
    scatter(normalizedData.longitude, normalizedData.latitude, 4, 'filled');

    % Safer filename for output
    safeName = regexprep(normalizedData.common_name(1), '\s+', '_');
    writetable(normalizedData, safeName + ".csv");

    switch plotBy
        case 'Month'
            scatter(normalizedData.longitude, normalizedData.latitude, 4, month(normalizedData.date_time), 'filled');
            colorbar;
        case 'Year'
            scatter(normalizedData.longitude, normalizedData.latitude, 4, year(normalizedData.date_time), 'filled');
            colorbar;
        case 'Dataset'
            legendVals(i) = normalizedData.common_name(1);
            % already plotted above
        case 'Animal'
            ids = unique(normalizedData.dataset_id);
            for j = 1:numel(ids)
                m = normalizedData.dataset_id == ids(j);
                scatter(normalizedData.longitude(m), normalizedData.latitude(m), 4, 'filled');
            end
        otherwise
            error("Did not recognize requested plotBy type");
    end
end

plot_world();
title("Animal Location Separated By " +  plotBy, 'interpreter', 'latex');

if plotBy == "Dataset"
    legend(legendVals);
end
