% clear
sig = ones(1,1);

fs = 16000;

[simin,nbsecs,fs] = initparams(sig', fs);
sim('recplay')
out = simout.signals.values;
%% plot response
threshold = 0.002;
y = out(find(out> threshold,1):(find(out> threshold,1)+150));

figure
subplot(4,1,1)
plot(simin);
subplot(4,1,2);
plot(out);
subplot(4,1,3);
plot(y)
subplot(4,1,4);
plot(abs(fft(y)))
%%


%out = out(35000:38000);
%[s,f,t,psd] = spectrogram(,dftsize,dftsize/2,dftsize,fs);
% psd = psd(1:end,(pause_length*fs*2/dftsize):(end-pause_length*fs*2/dftsize)); % remove silence
%subplot(2,1,2);
%plot(f, 10*log10(mean(psd,2)));