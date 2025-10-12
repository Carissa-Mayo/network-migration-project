clear; clc; close all;

%Add name of each csv file you want to load to the array below
datasets = ["obis_seamap_species_173830_points.csv" ,"obis_seamap_species_173836_points.csv", "obis_seamap_species_173833_points.csv"];

%What method should be used when plotting data
plotBy = "Dataset"; %Options are: Month, Year, Animal, Dataset

earliestYear = 2000; %Ignore datasets before this year

%Only use data that was collected with this platform type
platformType = "tag"; %Set to "all" to use all platform types

figure; hold on;
for i = 1:numel(datasets)
    disp("Loading Dataset " + i);
    dataset = datasets(i);
    dataFull = readtable(dataset);
    
    %Filter out only tag datasets
    if(platformType == "all")
        data = dataFull;
    else
        date_time = dataFull.date_time(dataFull.platform == platformType);
        dataset_id = dataFull.dataset_id(dataFull.platform == platformType);
        row_id = dataFull.row_id(dataFull.platform == platformType);
        latitude = dataFull.latitude(dataFull.platform == platformType);
        longitude = dataFull.longitude(dataFull.platform == platformType);
        species_name = dataFull.species_name(dataFull.platform == platformType);
        common_name = dataFull.common_name(dataFull.platform == platformType);
        %Create useful data table
        data = table(common_name, row_id, date_time, dataset_id, row_id, latitude, longitude, species_name);
    end
    disp("Plotting Dataset " + i);
    %Sort by dataset ID
    row_idValues = split(data.row_id, '_');
    data.row_id = str2double(row_idValues(:,2));
    data = sortrows(data, [1,2]); 
    data.month = month(data.date_time);
    data.year = year(data.date_time);
    animalIds = unique(data.dataset_id);
    data.common_name = convertCharsToStrings(data.common_name); %Switch from character array to strings for ease of use:)

    
    index = 1;
    normalizedData = table(1, 1, 1, "empty", datetime('now'), 'VariableNames', ["latitude", "longitude", "dataset_id", "common_name", "date_time"]);

    for animalIdIndex = 1:numel(animalIds)
        iterationData = data(data.dataset_id == animalIds(animalIdIndex) & year(data.date_time) >= earliestYear, :);
        iterationData.date_time = dateshift(iterationData.date_time, 'start', 'day');
        uniqueDate = unique(iterationData.date_time);
        for dateIndex = 1:numel(uniqueDate)
            iterationLatitude = iterationData.latitude(iterationData.date_time == uniqueDate(dateIndex));
            iterationLongitude = iterationData.longitude(iterationData.date_time == uniqueDate(dateIndex));
            
            holder = table(1, 1, 1, "empty", datetime('now'), 'VariableNames', ["latitude", "longitude", "dataset_id", "common_name", "date_time"]);
            holder.latitude(1) = mean(iterationLatitude(1));
            holder.longitude(1) = mean(iterationLongitude(1));
            holder.dataset_id(1) = animalIds(animalIdIndex);
            holder.common_name(1) = iterationData.common_name(1);
            holder.date_time(1) = uniqueDate(dateIndex);

            normalizedData = [normalizedData; holder];
        end

    end
    normalizedData = normalizedData(2:end, :);
    clear data
    legendVals(i) = normalizedData.common_name(1);
    scatter(normalizedData.longitude, normalizedData.latitude, 4, 'filled');
    
    writetable(normalizedData,normalizedData.common_name(1) + ".csv", 'Delimiter', ',', 'WriteRowNames', true);

    switch plotBy
        case 'Month'
            scatter(data.longitude, data.latitude,4,data.month,'filled');
            colorbar;
        case 'Year'
            scatter(data.longitude, data.latitude,4,data.year,'filled');
            colorbar;
        case 'Dataset'
            legendVals(i) = data.common_name(1);
            scatter(data.longitude, data.latitude, 4, 'filled');
            
        case 'Animal'
            for index = 1:numel(animalIds)
                animalID = animalIds(index);
                scatter(data.longitude(data.dataset_id == animalID), data.latitude(data.dataset_id == animalID),4, 'filled');
            end

        otherwise
            error("Did not recognize requested plotBy type");
    end
end
plot_world();
title("Animal Location Seperated By " +  plotBy, 'interpreter', 'latex')

if(plotBy == "Dataset")
   legend(legendVals);    
end
