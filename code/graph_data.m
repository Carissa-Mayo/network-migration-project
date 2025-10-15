clear; clc; close all;

dataset = readtable("Data_tidy/all_Data.csv");
partition = readtable("Data_tidy/partition.csv");
partition.Properties.VariableNames = ["partitions"];
dataset.partition = partition.partitions;


ind = find(diff(dataset.partition) ~= 0);
string = "[";
B = days(5);
countMat = zeros(9,9);
nodeWeight = zeros(1,9);
for i = 1:numel(ind)
    index = ind(i);
    % i is index before change
    deltaTime = between(dataset.date_time(index), dataset.date_time(index+1));
    if time(deltaTime) < B
        countMat(dataset.partition(index),dataset.partition(index+1)) = countMat(dataset.partition(index),dataset.partition(index+1)) + 1;
        string = string + "(" + dataset.partition(index) + ", " + ...
            dataset.partition(index+1) + "), ";
        nodeWeight(dataset.partition(index)) = nodeWeight(dataset.partition(index)) + 1;

    end
end
string = string + "]";

index = 1;
scaleFactor = 1;
for fromPartition = 1:9
    for toPartition = 1:9
        weight = countMat(fromPartition, toPartition);
        if(weight ~= 0)
            %Write a string of code with weigth to 'code' variable
            iterationString = "G.add_edge(" + fromPartition + ", " + ...
                toPartition + ", weight=" + (weight/scaleFactor) + ")";
            code(index) = iterationString;
            index = index + 1;
        end
    end
end

scaleFactor = 1;
for node = 1:9
    weight = nodeWeight(node);
    iterationString = "G.add_node(" + node + ", weight=" ...
        + (weight/scaleFactor) + ")";
    code(index) = iterationString;
    index = index + 1;
end

outputFileName = "Data_tidy/code.txt";
fid = fopen(outputFileName, 'wt');
fprintf(fid, '%s\n', code);
fclose(fid);


