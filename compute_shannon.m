%% Initialize
fs =  16000;
dftsize = 512;
% sig = sin(2*pi*1000*(0:1/fs:2));
sig = wgn(1,fs*2+1,5);

%% Measure channel
N = dftsize / 2;

Capacity = [0,0,0,0,0,0];
for i = 1:6
% Record noise
simin = zeros(fs*2,1);
nbsecs = length(simin)/fs;
sim('recplay');
out = simout.signals.values;
[noise_s,noise_f,noise_t,noise_psd] = spectrogram(out,dftsize,dftsize/2,dftsize,fs);

% Record signal
simin = sig';
if (max(simin) ~= min(simin))
    simin = 2 * (simin - min(simin)) / (max(simin)-min(simin)) - 1;
end
nbsecs = length(simin)/fs;
sim('recplay');
out = simout.signals.values;
[sig_s,sig_f,sig_t,sig_psd] = spectrogram(out,dftsize,dftsize/2,dftsize,fs);

% Take average
noise_psd = mean(noise_psd,2);
sig_psd = mean(sig_psd,2);

% Remove noise from signal
sig_pd = sig_psd - noise_psd;

Capacity(i) = sum(sum(log2(sig_psd ./ noise_psd + 1))) * fs / (2*N);
end

%% Plot noise and signal
figure
title('hi');
subplot(2,2,1);
imagesc('XData',noise_t,'YData',noise_f,'CData',10*log10(abs(noise_s)));
title('noise');
subplot(2,2,2);
plot(noise_f, 10*log10(noise_psd));
title('noise');
subplot(2,2,3);
imagesc('XData',sig_t,'YData',sig_f,'CData',10*log10(abs(sig_s)));
title('signal');
subplot(2,2,4);
plot(sig_f, 10*log10(sig_psd));
title('signal');

a = axes;
t1 = title(['Capacity:' num2str(round(Capacity))]);
t1.Position(2) = t1.Position(2) +0.01;
t1.Color = [1,0,0];
a.Visible = 'off'; % set(a,'Visible','off');
t1.Visible = 'on'; % set(t1,'Visible','on');