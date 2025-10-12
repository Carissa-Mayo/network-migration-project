function plot_world()
%PLOT_WORLD Plots 2D map of earth with relevent cities plotted
%   Adds 2D line plot and scatter plot to current figure window.
%   Coordinates in Latitude and Longitude
coastlineLocations = table2array(readtable("world_coastline_low.txt"));
% worldcities = readtable("C:\Users\Jackt\Desktop\TurtlePlotting\worldcities.csv");

plot(coastlineLocations(:, 1), coastlineLocations(:, 2), 'k');
hold on

%s = scatter(worldcities.lng(1:end), worldcities.lat(1:end), 0.2, 'filled');
% s.MarkerEdgeColor = [0.8500 0.3250 0.0980];
%s.MarkerFaceColor = [0.8500 0.3250 0.0980];
axis equal
xlim([-180 180]);
ylim([-90 90]);
xline(0)
yline(0)
xlabel("Longitude", 'interpreter', 'latex');
ylabel("Latitude", 'interpreter', 'latex');
xticks(-180:30:180);
yticks(-90:30:90);
grid on

end

