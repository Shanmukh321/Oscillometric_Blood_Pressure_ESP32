Oscillometric Blood pressure Machine.

All the MATLAB related code are included. 

Please refer the datasets and understand how the data is being stored once the processing starts.

Then play with that datasets to your liking.

The processing of the data is pretty simple. load -> bandpass filter -> low pass filter -> peaks -> envelope -> find the MAP -> ratios multiplied -> SBP and DBP.

Schematic is almost accurate to the real hardware.

Note : ADC is ADS1115 because of its high sampling rate and bit length. PSG010s is compatible with this work. just try to calibrate the sensor beforehand. Calibration should be done multiple times regardless of the accuracy.
try Calibrating at different places and heights as well. 
