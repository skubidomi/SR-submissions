% The intention behind this script is to close those serial ports, which
% left accidentally without reference.
% 2017. 02. 16.

devices = instrfind;
for idx = 1:length(devices)
    fclose(devices(idx));
end

clear('devices', 'idx');

