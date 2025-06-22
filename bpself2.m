% Load the data
%                               - 0.5/0.85 - 4 percent deviation in the MAP calculation
%s.no-ref(SBP/DBP)-ref(MAP)-est(MAP)-est(SBP/DBP)
%bp8 - 146/98  - 114    - 116   - 145/101
%bp9 - 139/92  - 107.6  - 109   - 145/93
%bp10 - 140/98 - 112    - 107   - 141/98
%bp12 - 141/99 - 113    - 110   - 138/99
%bp13 - 141/97 - 111    - 105   - 145/94
%bp11 - 138/94 - 108    - 94    - 136/87
%bp21 - 127/88 - 101    - 96    - 128/90

%bp30 - 128/80  -  96   - 89    - 135/72 - hemanth 
%bp31 - 119/73  - 88    - 84    - 118/73 - sai tej
%bp32 - 142/102 - 115   - 114   - 151/103 - shanmukh
%bp33 - 142/101 - 114   - 130   - 148/105 - 45% of the signal
%bp35 - 130/88  -  100  - 95    - 128/86 - vinay
%bp36 - 115/78  -  87   - 91    - 110/82 - harsha
%bp37 - 112/78  -  89   - 83    - 110/74
%bp38 - 106/70  -  82   - 79    - 103/71  - prasath
%bp39 - 133/86  -  101  - 109   - 127/91 - gopal

%bp40 - 115/84  - 94    - 94    - 122/85 - harsha
%bp40 - 116/77  - 90    - 93    - 120/77 - harsha
%bp42 - 128/82  - 97    - 99    - 130/81 - mahesh

%bp43 - 112/73  - 86    - 86    - 121/75 - harish
%bp44 - 147/90  - 109   - 108   - 154/88 - jagannadh
%bp40 - 101/72  - 82    - 86    - 108/74 - harsha
%bp40 - 122/76  - 91    - 95    - 126/73 - gopal
%bp55 - 119/75  - 89    - 89    - 121/79 - RamaKrishna 

load('bp11.mat'); %change with the mat file obtained from the serial plotter 
data = log;
x = data(:, 1);
y = data(:, 2);

fs = 200;

%for extracting the oscillation included signal
[b_trend, a_trend] = butter(2, 0.7/(fs/2), 'low');
trend_full = filtfilt(b_trend, a_trend, y);

[~, peakIdx_raw] = max(trend_full);
offset = round(1.3 * fs);  % Adjust this value (in samples), e.g., 0.5 seconds after peak
peakIdx = min(peakIdx_raw + offset, length(y));  % Ensure we don't go beyond bounds

falloff_threshold = max(trend_full) * 0.4;
endIdx = find(trend_full(peakIdx:end) < falloff_threshold, 1, 'first');

if isempty(endIdx)
    endIdx = length(y);
else
    endIdx = endIdx + peakIdx - 1;
end

%the points where the signal start and ends
x = x(peakIdx:endIdx);
y = y(peakIdx:endIdx);

%to get the oscillations from the decay curve
low_cutoff = 0.6;
[b_trend, a_trend] = butter(2, low_cutoff / (fs/2), 'low');
trend = filtfilt(b_trend, a_trend, y);
detrended = y - trend;

%bandpass to clean the oscilations and get better peaks
[b_bp, a_bp] = butter(2, [0.8 3.5]/(fs/2), 'bandpass');
oscillations = filtfilt(b_bp, a_bp, detrended);

% detecting peaks
minPeakDist = round(4.35 * fs); % for detecting the minimum peaks of the signal
peakProminence = 0.1 * std(oscillations); % for the strength of the signal

%filters weak, noisy peaks (uses standard deviation prominence threshold)
[peakVals, peakLocs] = findpeaks(oscillations,'MinPeakDistance', minPeakDist,'MinPeakProminence', peakProminence);
%creating envelope - enough peaks - interpline - not enough - movmax
if length(peakLocs) >= 4
    envelope_smooth = interp1(x(peakLocs), peakVals, x, 'spline');
else
    envelope_smooth = movmax(oscillations, round(2.25 * fs));
end

%smoothening the envelope
envelope_smooth = smooth(envelope_smooth, round(0.2 * length(envelope_smooth)));

%MAP
[maxEnv, idxMAP] = max(envelope_smooth);
MAP = trend(idxMAP); 

%thresholding wrto MAP
SBP_threshold = 0.5 * maxEnv;
DBP_threshold = 0.85 * maxEnv;

idxSBP = find(envelope_smooth(1:idxMAP) >= SBP_threshold, 1, 'first');
SBP = trend(idxSBP);

idxDBP = find(envelope_smooth(idxMAP:end) <= DBP_threshold, 1, 'first');
idxDBP = idxDBP + idxMAP - 1;
DBP = trend(idxDBP);

fprintf('SBP: %d mmHg\n', round(SBP));
fprintf('MAP: %d mmHg\n', round(MAP));
fprintf('DBP: %d mmHg\n', round(DBP));

plot(x, trend, 'r', 'LineWidth', 1.2); hold on;
plot(x(idxSBP), SBP, 'go', 'MarkerSize', 8, 'LineWidth', 1.5);
plot(x(idxMAP), MAP, 'ro', 'MarkerSize', 8, 'LineWidth', 1.5);
plot(x(idxDBP), DBP, 'bo', 'MarkerSize', 8, 'LineWidth', 1.5);
legend('Cuff Pressure', 'SBP', 'MAP', 'DBP');
title('Cuff Pressure with Detected BP Points');
xlabel('Time (s) or Sample Index');
ylabel('Pressure (mmHg)');
grid on;

figure;

subplot(3,1,1);
plot(x, y, 'k'); hold on;
title('Cuff Pressure');
xlabel('Time');
ylabel('Pressure (mmHg)');
grid on;


subplot(3,1,2);
plot(x, oscillations, 'b'); hold on;
title('Oscillations');
xlabel('Time');
ylabel('Amplitude');
grid on;
legend('|Oscillations|');

subplot(3,1,3);
plot(x, oscillations, 'b'); hold on;
plot(x, envelope_smooth, 'k', 'LineWidth', 1.5);
plot(x(idxMAP), maxEnv, 'ro', 'MarkerSize', 8);
plot(x(idxSBP), envelope_smooth(idxSBP), 'go', 'MarkerSize', 8);
plot(x(idxDBP), envelope_smooth(idxDBP), 'bo', 'MarkerSize', 8);
legend('Oscillations', 'Envelope', 'MAP', 'SBP', 'DBP');
title('Oscillometric Signal & Envelope');
xlabel('Time');
ylabel('Amplitude');
grid on;


