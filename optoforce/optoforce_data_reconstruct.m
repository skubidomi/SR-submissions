% optoforce_data_reconstruct
% please do not use the MATLAB built-in findpeaks
close all;
clear;
clc;

%optoforce_raw_coords_737875.2263681019.mat  valid: [1, 238]
%optoforce_raw_coords_737875.2270650695.mat  valid: [1, 272]

load('optoforce_raw_coords_737875.2263681019.mat', 'x_t', 'y_t', 'z_t');
valid = 1:238;
%load('optoforce_raw_coords_737875.2270650695.mat', 'x_t', 'y_t', 'z_t');
%valid = 1:272;
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

