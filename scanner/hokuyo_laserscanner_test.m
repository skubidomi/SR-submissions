% Hokuyo URG-04LX-UG01 laserscanner test script
% general description: laserscanner_description___URG_04LX_UG01.pdf
% communication protocol: laserscanner_communication_protocol___URG_04LX_UG01.pdf

% Check under Control Panel / System / Device Manager to which serial port
% your device is attached, and update this code.
% Under linux: sudo ln -s /dev/ttyACM0 /dev/ttyS100

% The communication with the sensor is based on ascii-messages. Please read
% carefully at least the general description + chapter 5, 6.2, 7, 8.1 of
% the communication protocol. We will use 3-character encoding, and we will
% acquire single scans (last parameter of command MD).

close all;
clear all;





% #####
% step1: initialization of MATLAB serial object
lidar=serial('COM10', 'BaudRate', 19200);
set(lidar, 'Timeout', 1);
set(lidar, 'InputBufferSize', 40000);
set(lidar, 'Terminator', 'LF');




% #####
% step2: ask the driver to use the newer communication protocol + setting
% up higher speed on the serial line
fopen(lidar);
pause(0.1);
fprintf(lidar, 'SCIP2.0');
pause(0.1);
read_counter = 12;
[data, num_of_bytes] = fscanf(lidar);
read_counter = read_counter-num_of_bytes;
while read_counter>0
    [data, num_of_bytes] = fscanf(lidar);
    read_counter = read_counter-num_of_bytes;
end

fprintf(lidar, 'SS115200');
pause(0.1);
read_counter = 15;
[data, num_of_bytes] = fscanf(lidar);
read_counter = read_counter-num_of_bytes;
while read_counter>0
    [data, num_of_bytes] = fscanf(lidar);
    read_counter = read_counter-num_of_bytes;
end
set(lidar, 'BaudRate', 115200);




% #####
% step3: gathering some state-information from the laser-scanner.
% Later on you can comment out this step, this has here just demonstration
% purposes right now.
fprintf(lidar, 'II');
pause(0.1);
[data, num_of_bytes] = fscanf(lidar);
read_data = [data];
while num_of_bytes>0
    [data, num_of_bytes] = fscanf(lidar);
    read_data = [read_data, data];
end
read_data




% #####
% step4: a complete measurement, from step 44 till step 725: 682 steps
% number of scans = 1
fprintf(lidar,'MD0044072501101');
pause(0.1);
% we will receive 2 packets:
% - the 2nd/grey packet with length = 21 bytes(on page 11 in the comm. protocol pdf)
% - the 5th packet with length = 26 + 31x66 + 64 + 1 = 26 + 2111 bytes (on
%   page 11 in the comm. protocol pdf 'When data is more than 64 bytes and
%   terminates with remaining bytes')
%
% How to process them? 
% - first 47 bytes are not real measurement values, so we can neglect them
% - from the 66 bytes long units: the first 64 is measurement data
% - from the 64 bytes long unit: the first 62 is measurement data
% This means 31x64 + 62 = 2046 data bytes. Assuming that we are using
% 3-character encoding, this means 2046/3 = 682 measurement points, which
% is exactly what we wanted.
measurement_data = [];
[data, num_of_bytes] = fscanf(lidar);
received_bytes = num_of_bytes;
while num_of_bytes>0 && length(measurement_data)<2046
    if received_bytes <= 47
        [data, num_of_bytes] = fscanf(lidar);
        received_bytes = received_bytes + num_of_bytes;
    elseif num_of_bytes>1
        % we can assume, that after the packet-headers (and before the last
        % LF), we are receiving the data-blocks separately:
        measurement_data = [measurement_data, data(1:end-2)];
        [data, num_of_bytes] = fscanf(lidar);
        received_bytes = received_bytes + num_of_bytes;
    end
end

% lets check the size of the measurement data:
if length(measurement_data) ~= 2046
    fprintf('error with the number of received data-points\n');
    fprintf(lidar,'QT');
    fclose(lidar);
    return;
end

% the measurement points are coded with 3-character per point, so we have
% to decrease every value with '48' (ascii-code shift), then combine every
% triplet:
measurement_data = measurement_data - 48;
converted_data = zeros(1, length(measurement_data)/3);
for idx=1:3:length(measurement_data)-1
    converted_data((idx+2)/3) =  measurement_data(idx)*2^12 + ...
                                measurement_data(idx+1)*2^6 + ...
                                measurement_data(idx+2);
end
angles = -30:0.3515625:210;
angles = angles(2:end);

% lets plot
figure;
hold on;
for idx=1:length(converted_data)
    plot(converted_data(idx)*cosd(angles(idx)), converted_data(idx)*sind(angles(idx)), 'b.');
end
xlabel('axis x');
ylabel('axis y');
hold off;




% #####
% step5: close the device and the port as well
fprintf(lidar,'QT');
fclose(lidar);



