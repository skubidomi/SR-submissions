% Phidget 1053 2axis accelerometer test function
% The usage of this sensor is based on outer library calls (dll/so).
% After every call please wait a bit (eg. 0.1 sec) to let the call to take
% effect.
% 
% Please read pages 10-13 of accelerometer_2axis___Phidget_1053.pdf
% The output of axis 0 is correct, in standstill it should be 
% between +/- 1g; but the output of axis 1 has some problems, so it should
% be scaled with the calibrator function (see at the end of this file).
% 
% This function will return you a vector with two elements: the tilt angles
% of axis 0 and axis 1.
function tilt_angles = phidget_accelerometer_test()
    format long;
    
    % select one of the following, depending on your OS:
    if ~libisloaded('phidget21')
        % loadlibrary('phidget21', 'phidget21Matlab_Windows_x86.h');
        loadlibrary('phidget21', './phidget21Matlab_Windows_x64.h');
    end
    % loadlibrary('/usr/lib/libphidget21.so', 'phidget21matlab_unix.h', 'alias', 'phidget21');
    pause(0.1);
    
    % the device itself, and the return-values of the individual functions
    % can be accessed through pointers (of type either int32 or double)
    
    % create and open the sensor:
    phidget_sensor = libpointer('int32Ptr', 0);
    calllib('phidget21', 'CPhidgetAccelerometer_create', phidget_sensor);
    pause(0.1);
    calllib('phidget21', 'CPhidget_open', phidget_sensor, -1);
    pause(0.1);
    
    % to know the serial number of the device: (irrelevant, later you can comment it out)
    phidget_serialnumber = libpointer('int32Ptr', 0);
    calllib('phidget21', 'CPhidget_getSerialNumber', phidget_sensor, phidget_serialnumber);
    pause(0.1);
    fprintf('serial number of the sensor: %i\n', phidget_serialnumber.Value);
    
    % to know the status of the device: (irrelevant, later you can commnet it out)
    phidget_status = libpointer('int32Ptr', 0);
    calllib('phidget21', 'CPhidget_getDeviceStatus', phidget_sensor, phidget_status);
    pause(0.1);
    fprintf('status of the sensor: %i\n', phidget_status.Value);
    
    % to know the number of axes:
    phidget_axescount = libpointer('int32Ptr', 0);
    calllib('phidget21', 'CPhidgetAccelerometer_getAxisCount', phidget_sensor, phidget_axescount);
    pause(0.1);
    fprintf('number of axes: %i\n', phidget_axescount.Value);
    
    % to reach the acceleration-value along the individual axes
    phidget_acceleration = libpointer('doublePtr', 0);
    tilt_angles=zeros(1, phidget_axescount.Value);
    for idx=0:phidget_axescount.Value-1
        calllib('phidget21', 'CPhidgetAccelerometer_getAcceleration', phidget_sensor, idx, phidget_acceleration);
        pause(0.1);
        % normally (in standstill state) this value should be between +/-1 g
        % we can easily convert it to degrees:
        %tilt_angles(idx+1) = asind(phidget_acceleration.Value);
        tilt_angles(idx+1) = asind(calibrator(phidget_acceleration.Value, idx));
    end
    
    % to close the sensor
    calllib('phidget21', 'CPhidget_close', phidget_sensor);
    pause(0.1);
    
    % to delete the sensor
    calllib('phidget21', 'CPhidget_delete', phidget_sensor);
    pause(0.1);
    
end




function converted = calibrator(raw_value, axis)
    if axis==0
        % axis0 does not need calibration:
        converted = raw_value;
    else
        % axis1 should be scaled from [-0.967, +0.937] to [-1, +1]
        converted = (raw_value+0.967)/(0.967+0.937)*2 - 1;
    end
end



%{
% #####
% available function in the library:

typedef int *CPhidgetAccelerometerHandle;
int CPhidgetAccelerometer_create (CPhidgetAccelerometerHandle * phid);

/**
 * Gets the number of acceleration axes supported by this accelerometer.
 * @param phid An attached phidget accelerometer handle.
 * @param count The axis count.
 */
int CPhidgetAccelerometer_getAxisCount (CPhidgetAccelerometerHandle phid, int *count);

/**
 * Gets the current acceleration of an axis.
 * @param phid An attached phidget accelerometer handle.
 * @param index The acceleration index.
 * @param acceleration The acceleration.
 */
int CPhidgetAccelerometer_getAcceleration (CPhidgetAccelerometerHandle phid, int index, double *acceleration);

/**
 * Gets the attached status of a Phidget.
 * @param phid A phidget handle.
 * @param deviceStatus An int pointer for returning the device status. Possible codes are \ref PHIDGET_ATTACHED and \ref PHIDGET_NOTATTACHED.
 */
int CPhidget_getDeviceStatus (CPhidgetHandle phid, int *deviceStatus);

/**
 * Gets the serial number of a Phidget.
 * @param phid An attached phidget handle.
 * @param serialNumber An int pointer for returning the serial number.
 */
int CPhidget_getSerialNumber (CPhidgetHandle phid, int *serialNumber);


%}
