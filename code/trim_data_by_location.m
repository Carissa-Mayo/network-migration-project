clear; clc; close all;

%Add name of each csv file you want to load to the array below
datasets = ["Data_tidy/Loggerhead.csv", "Data_tidy/Hawksbill.csv", "Data_tidy/Green Sea Turtle.csv"];

%What method should be used when plotting data
earliestYear = 2000; %Ignore datasets before this year

%Only use data that was collected with this platform type
platformType = "tag"; %Set to "all" to use all platform types
leftBound = -90; %Boundary in Decimal Degrees
rightBound = -60; %Boundary in Decimal Degrees
bottomBound = 5; %Boundary in Decimal Degrees
topBound = 25; %Boundary in Decimal Degrees

figure; hold on
allData = table(1, 1, 1, "empty", datetime('now'), 'VariableNames', ["latitude", "longitude", "dataset_id", "common_name", "date_time"]);

for i = 1:numel(datasets)
    disp("Loading Dataset " + i);
    dataset = datasets(i);
    data = readtable(dataset);

    %Filter Out Locations
    rowIndex = (data.longitude > leftBound & data.longitude < rightBound) & (data.latitude > bottomBound & data.latitude < topBound);
    data = data(rowIndex,:);

    %Filter out the Mexican West Coast
    mexicanLine = @(longitude) -1.36488 * longitude - 105.5;

    index = 1;
    goodPoints = [];
    rows = 2;
    while(index <= rows)
        pointLatitude = data.latitude(index);
        pointLongitude = data.longitude(index);

        lineLatitude = mexicanLine(pointLongitude);

        if(pointLatitude > lineLatitude)
            goodPoints = [goodPoints index];
        end
        [rows, ~] = size(data);
        index = index + 1;
    end
    data = data(goodPoints, :);


    scatter(data.longitude, data.latitude, 4, 'filled');
    legendVals(i) = data.common_name(1);
    fileData = table(data.latitude, data.longitude, data.dataset_id, data.common_name, data.date_time, 'VariableNames', ["latitude", "longitude", "dataset_id", "common_name", "date_time"]);
    allData = [allData; fileData];
end


allData = allData(2:end, :);
latlongs = table(allData.latitude, allData.longitude, 'VariableNames', ["latitude", "longitude"]);

writetable(allData,"Data_tidy/all_Data.csv");
writetable(latlongs,"Data_tidy/latlongs.txt", 'Delimiter', ' ', 'WriteRowNames', true);

partition = readtable("Data_tidy/partition.csv");
partition.Properties.VariableNames = ["partitions"];
allData.partition = partition.partitions;


%Finds the centroid of each partition
for i = 1:max(unique(partition.partitions))
    meanLatitude(i) = mean(allData(allData.partition == i, :).latitude);
    meanLongitude(i) = mean(allData(allData.partition == i, :).longitude);
    
    scatter(meanLongitude, meanLatitude, 100, 'magenta', 'filled');
end
colorbar
xValues = leftBound:0.1:rightBound;
index = 1;
for i = 1:numel(xValues)
    yValues(index) = mexicanLine(xValues(i));
    index = index + 1;
end

plot(xValues, yValues);

scatter(allData.longitude, allData.latitude, [], allData.partition, "filled");
xline(rightBound);
xline(leftBound);
yline(bottomBound);
yline(topBound);
plot_world();
xlim([leftBound rightBound]);
ylim([bottomBound topBound]);
