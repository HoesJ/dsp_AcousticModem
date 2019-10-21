%% Configuration
fs = 16000;
L = 300;
K = 3000;
delay = 150;

%% IR1 play impulse
sig1 = ones(1,1);

[simin,nbsecs,fs] = initparams(sig1', fs);
simin1 = simin;
sim('recplay')
out1 = simout.signals.values;

%% IR1
threshold = max(out1)*0.5;
index = find(out1(fs*2:end) > threshold,1) + 2*fs
IR1 = out1(index:index+L);

% Makes a onesided fft
P2 = abs(fft(IR1)/length(IR1));
P1 = 2*P2(1:length(IR1)/2+1);

%% IR2 play noise
sig2 = wgn(1,fs*2+1,5);

[simin,nbsecs,fs] = initparams(sig2', fs);
simin2 = simin;
sim('recplay')
out2 = simout.signals.values;

%% IR2 estimate
threshold = max(out2)*0.5;
index = find(out2(fs*2:end) > threshold,1) + 2 * fs
y = out2(index:index+fs*2);
delayed_y = [zeros(delay,1);y];
u = sig2;
A = toeplitz(u(L:K),fliplr(u(1:L)));
h = A \ delayed_y(L:K);

% Makes a onesided fft
P3 = abs(fft(h)/length(h));
H = 2*P3(1:length(h)/2+1);

%% spectrograms of the transmitted and recorded white noise

dftsize = 512;
f = dftsize/2;

figure
subplot(2,1,1);
[s_in,f_in,t_in,ps_in] = spectrogram(simin2(1:end,1),dftsize,dftsize/2,f,fs);
imagesc('XData',t_in,'YData',f_in,'CData',10*log10(abs(s_in)))
title('spectrogram transmitted noise');
xlabel('t (s)')
ylabel('f (Hz)')

subplot(2,1,2);
[s_out,f_out,t_out,ps_out] = spectrogram(out2,dftsize,dftsize/2,f,fs);
imagesc('XData',t_out,'YData',f_out,'CData',10*log10(abs(s_out)))
title('spectrogram recorded noise');
xlabel('t (s)')
ylabel('f (Hz)')

%% PSD of the transmitted and recorded white noise

figure
subplot(2,1,1)
plot(f_in, 10*log10(mean(ps_in,2)));
title('PSD transmitted noise');
xlabel('f (Hz)');
ylabel('amplitude (dB)');
% ylim([-80 -40]);

subplot(2,1,2);
plot(f_out, 10*log10(mean(ps_out,2)));
title('PSD recorded noise');
xlabel('f (Hz)');
ylabel('amplitude (dB)');
% ylim([-80 -40]);

%% Channel time and frequency response plots, based on IR1.m

figure
subplot(4,1,1);
plot(simin1);
title('transmitted impulse');
xlabel('t (s)');
ylabel('amplitude');
% ylim([-1 1]);

subplot(4,1,2);
plot(out1);
title('recorded signal');
xlabel('t (s)');
ylabel('amplitude');
% ylim([-0.5 0.5]);

subplot(4,1,3);
plot(IR1);
title('Time response');
xlabel('sample');
ylabel('amplitude');
ylim([-1e-3 1e-3]);


subplot(4,1,4);
plot(linspace(0,fs/2,length(P1)),10*log10(P1));
title('one sided frequency response');
xlabel('f (Hz)');
ylabel('amplitude (dB)');
ylim([-80 -40]);

%% Channel time and frequency response plots, based on IR2.m

figure
subplot(4,1,1);
plot(simin2);
title('transmitted noise');
xlabel('t (s)');
ylabel('amplitude');
% ylim([-1 1]);

subplot(4,1,2);
plot(out2);
title('recorded noise');
xlabel('t (s)');
ylabel('amplitude');
% ylim([-0.5 0.5]);

subplot(4,1,3);
plot(h);
title('Time response');
xlabel('sample');
ylabel('amplitude');
ylim([-1e-3 1e-3]);

subplot(4,1,4);
plot(linspace(0,fs/2,length(H)),10*log10(H));
title('one sided frequency response');
xlabel('f (Hz)');
ylabel('amplitude (dB)');
ylim([-80 -40]);