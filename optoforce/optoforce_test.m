% This is a simple script demonstrating the usage of Optoforce sensors' 
% output from MATLAB.
% Before starting: 
% Windows: please check under Control Panel / System / Device Manager
% that under which serial-port your optoforce device is connected
% Linux: sudo ln -s /dev/ttyACM0 /devttyS100
% 
% After you have opened the serial-object attached to the optoforce sensor,
% it will continuously send you its 14-bytes long packages, according to 
% the following scheme:
% 55 67 [config] [s1H] [s1L] [s2H] [s2L] [s3H] [s3L] [s4H] [s4L] [tempH] [tempL] [checksum]
% computing checksum: config+s1+s2+s3+s4+temp but all of these summations on 8 bit only.
% computing coordinates:
% x = s1 - s3
% y = s2 - s4
% z = (s1 + s2 + s3 + s4) / 4
% 
    
    format long;
   
    optoforce = serial('COM5', 'baudrate', 115200);
    set(optoforce, 'InputBufferSize', 100);
    buffer = [];
    
    figure;
    force_direction = line([0 0], [0 0], [0 0], 'Color', 'r', 'LineWidth', 3);
    xlim([-20 20]);
    ylim([-20 20]);
    zlim([0 20]);
    xlabel('X');
    ylabel('Y');
    zlabel('Z');
    view(15, 35);
    grid on;
    
    fopen(optoforce);
    [data, pieces] = fread(optoforce, 100);
    buffer = data;
    ind_start = find(buffer==55, 1);
    while (buffer(ind_start+1) ~= 67)
        ind_start2 = find(buffer(ind_start+1:end)==55, 1);
        ind_start = ind_start+ind_start2;
    end
    if (ind_start>1)
        buffer(1:ind_start-1) = [];
        ind_start = 1;
    end
    % to set up the offsets:
    s1 = buffer(ind_start+3)*256 + buffer(ind_start+4);
    s2 = buffer(ind_start+5)*256 + buffer(ind_start+6);
    s3 = buffer(ind_start+7)*256 + buffer(ind_start+8);
    s4 = buffer(ind_start+9)*256 + buffer(ind_start+10);
    x_orig = s3-s1;
    y_orig = s2-s4;
    z_orig = s1+s2+s3+s4;
    
    index=0;
    for ind=1:500
        while (ind_start+13<=length(buffer))
            
            index=index+1;
            s1 = buffer(ind_start+3)*256 + buffer(ind_start+4);
            s2 = buffer(ind_start+5)*256 + buffer(ind_start+6);
            s3 = buffer(ind_start+7)*256 + buffer(ind_start+8);
            s4 = buffer(ind_start+9)*256 + buffer(ind_start+10);
            xc = (s3-s1-x_orig)/60; %in theory the denom. should be 100, and the nomin. s1-s3 ...
            yc = (s2-s4-y_orig)/60; %same
            zc = (s1+s2+s3+s4-z_orig)/400;
            
            set(force_direction, 'XData', [0 xc], 'YData', [0 yc], 'ZData', [0 zc]);
            drawnow;
            pause(0.01);
            ind_start = ind_start+14;
        end
        [data, pieces] = fread(optoforce, 100); % this read is just to empty the receiver buffer
        [data, pieces] = fread(optoforce, 100);
        buffer = data;
        ind_start = find(buffer==55, 1);
        while (buffer(ind_start+1) ~= 67)
            ind_start2 = find(buffer(ind_start+1:end)==55, 1);
            ind_start = ind_start+ind_start2;
        end
        if (ind_start>1)
            buffer(1:ind_start-1) = [];
            ind_start = 1;
        end
    end
   
    
    fclose(optoforce);
    
