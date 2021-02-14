% optoforce_data_reconstruct
% please do not use the MATLAB built-in findpeaks
close all;
clear;
clc;

%optoforce_raw_coords_737875.2263681019.mat  valid: [1, 238]
%optoforce_raw_coords_737875.2270650695.mat  valid: [1, 272]

%load('optoforce_raw_coords_737875.2263681019.mat', 'x_t', 'y_t', 'z_t');
%valid = 1:238;
load('optoforce_raw_coords_737875.2270650695.mat', 'x_t', 'y_t', 'z_t');
valid = 1:272;
x_t = x_t(valid);
y_t = y_t(valid);
z_t = z_t(valid);
res_t = sqrt(x_t.^2+y_t.^2+z_t.^2);

figure;
subplot(4, 1, 1);
plot(x_t, 'b*-'); title('x-coords'); xlabel('time'); ylabel('force amplitude');
subplot(4, 1, 2);
plot(y_t, 'b*-'); title('y-coords'); xlabel('time'); ylabel('force amplitude');
subplot(4, 1, 3);
plot(z_t, 'b*-'); title('z-coords'); xlabel('time'); ylabel('force amplitude');
subplot(4, 1, 4);
plot(res_t, 'b*-'); title('resultant'); xlabel('time'); ylabel('force amplitude');

% here you can continue with your bump-detection code:
% 1st attempt: get just a mean
figure(2);
plot(1:1:length(res_t),mean(res_t)*ones(1,length(res_t)),'r-');
hold on;
plot(res_t, 'b*-'); title('resultant');

% 2nd attempt: mean with sliding window to get a better threshold
window_length1 = 151; % always odd
threshold1 = zeros(1,length(res_t));
for i = 1:length(res_t)
    x_start = max(1,i-floor(window_length1/2));
    x_end = min(length(res_t), i+floor(window_length1/2));
    threshold1(i) = mean(res_t(x_start:x_end));
end
bias = 0.2;
threshold1 = threshold1 + bias;

% smaller window to get the bumps
window_length2 = 15;
threshold2 = zeros(1, length(res_t));
for i = 1:length(res_t)
    x_start = max(1,i-floor(window_length2/2));
    x_end = min(length(res_t), i+floor(window_length2/2));
    threshold2(i) = mean(res_t(x_start:x_end));
end


bump_set = threshold2>threshold1; % boolean, bump if the value is 1


figure(3);
plot(threshold1, 'r-');
hold on;
plot(threshold2, 'g-');
plot(res_t, 'b*-');
%plot(bump_set.*ones(1,length(res_t)).*(max(res_t)+0.3), 'r-');



