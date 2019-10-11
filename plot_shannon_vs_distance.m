%% Configure
nb_distances = 15;
nb_tests = 7;
pause_length = 1;       % in s
signal_length = 2;      % in s
distance_interval = 5;  % in cm
conf_interval_perc = 0.1;

Capacity = zeros(nb_distances, nb_tests);

fs = 16000;
dftsize = 512;
sig = wgn(1,fs*signal_length+1,5);


%% Measure
N = dftsize / 2;
for i = 15:nb_distances
    for j = 4:nb_tests
        % Record noise
        simin = zeros(fs*signal_length,1);
        nbsecs = length(simin)/fs;
        sim('recplay');
        out = simout.signals.values;
        [noise_s,noise_f,noise_t,noise_psd] = spectrogram(out,dftsize,dftsize/2,dftsize,fs);

        % Record signal
        simin = [zeros(pause_length*fs,1);sig';zeros(pause_length*fs,1)];
        if (max(simin) ~= min(simin))
            simin = 2 * (simin - min(simin)) / (max(simin)-min(simin)) - 1;
        end
        nbsecs = length(simin)/fs;
        sim('recplay');
        out = simout.signals.values;
        [sig_s,sig_f,sig_t,sig_psd] = spectrogram(out,dftsize,dftsize/2,dftsize,fs);
        sig_psd = sig_psd(1:end,(pause_length*fs*2/dftsize):(end-pause_length*fs*2/dftsize)); % remove silence

        % Take average
        noise_psd = mean(noise_psd,2);
        sig_psd = mean(sig_psd,2);

        % Remove noise from signal
        sig_pd = sig_psd - noise_psd;

        Capacity(i,j) = sum(sum(log2(sig_psd ./ noise_psd + 1))) * fs / (2*N);
    end
    disp("Move to next distance and continue");
    pause
end

%% Plot
X = 0:distance_interval:distance_interval*(nb_distances-1);
Y = mean(Capacity,2);
err = tinv(1-conf_interval_perc/2,nb_tests-1) * std(Capacity,0,2) / sqrt(nb_tests);

errorbar(X,Y,err);