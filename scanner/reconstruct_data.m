close all;

data = load('hokuyo_and_phidget_measurement_data.mat').scanner_data;

% initialize an empty vector, later it will store the x,y,z coordintes in 3
% row
datapoints = []; 
for i = 1:size(data,1)
    % get the local coordinates and the corresponding angle in deg
    x_L = data{i,1};
    y_L = data{i,2};
    tilt = data{i,3};
    % calculate the global coordinates
    x_G = x_L;
    y_G = cosd(tilt) * y_L;
    z_G = sind(tilt) * y_L;
    % append these points into the end of the datapoints set in every
    % iteration
    datapoints = [datapoints [x_G; y_G; z_G]];
end

% put zero vectors where the abs value is greater than 700
zero_mask = abs(datapoints)>700;
zero_mask = zero_mask(1,:) | zero_mask(2,:) | zero_mask(3,:);
zero_mask = [zero_mask; zero_mask; zero_mask];
datapoints(zero_mask) = 0;


figure();
plot3(datapoints(1,:), datapoints(2,:), datapoints(3,:), '.');
title('Reconstructed figure');