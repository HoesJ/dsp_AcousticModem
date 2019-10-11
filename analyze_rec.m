%plays a sine wave and records it.

%% som van sinusen
fs = 16000;
frequencies = [100,200,500,1000,1500,2000,4000,6000];
% frequencies = 100:200:10000;
sig = zeros(1,fs*2+1);
for i = 1:length(frequencies)
   sig = sig+sin(2*pi*frequencies(i)*(0:1/fs:2));
end

%% white noise
fs = 16000;
sig = wgn(1,fs*2+1,5);

%% Play sig
[simin,nbsecs,fs]=initparams(sig',fs);
sim('recplay');
out = simout.signals.values;

%% Analyse
dftsize = 512;
f = dftsize;

figure
subplot(2,1,1);
[s_in,f_in,t_in,ps_in] = spectrogram(simin,dftsize,dftsize/2,f,fs);
imagesc('XData',t_in,'YData',f_in,'CData',10*log10(abs(s_in)))
title('input');

subplot(2,1,2);
[s_out,f_out,t_out,ps_out] = spectrogram(out,dftsize,dftsize/2,f,fs);
imagesc('XData',t_out,'YData',f_out,'CData',10*log10(abs(s_out)))
title('output');

figure
subplot(2,1,1);
plot(f_in, 10*log10(mean(ps_in,2)));
title('input');

subplot(2,1,2);
plot(f_out, 10*log10(mean(ps_out,2)));
title('output');