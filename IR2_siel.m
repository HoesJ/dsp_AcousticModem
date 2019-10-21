fs = 16000;
duration = 2;
t = transpose(linspace(0,duration,duration*fs));
sig = wgn(length(t),1,1);

[simin, nbsecs, fs] = initparams(sig,fs);
sim('recplay')
out = simout.signals.values;

max_signal = max(out);
threshold = 0.2*max_signal;
indices = find(out > threshold);
begin_sample = indices(1) - 30;

L = 200;
K = length(sig) - L - 1;
A = toeplitz(sig(L+1:K+L+1),flip(sig(1:L+1)));

y = out(begin_sample+L:begin_sample+L+K);
h = A\y;

spectrum = fft(h);
spectrum = spectrum(1:round(length(spectrum)/2+1));

t = transpose(linspace(0,numel(h)-1,numel(h)));
f = transpose(linspace(0,numel(spectrum)-1,numel(spectrum)));

figure;
subplot(2,1,1);
plot(t, h);
subplot(2,1,2);
semilogy(f, abs(spectrum));

%%
figure;
subplot(2,1,1);
spectrogram(sig,dftsize,round(0.9*dftsize),dftsize,fs,'yaxis');
subplot(2,1,2);
spectrogram(out,dftsize,round(0.9*dftsize),dftsize,fs,'yaxis');

figure;
subplot(2,1,1);
pwelch(sig,dftsize,round(0.9*dftsize),dftsize,fs);
subplot(2,1,2);
pwelch(out,dftsize,round(0.9*dftsize),dftsize,fs);
