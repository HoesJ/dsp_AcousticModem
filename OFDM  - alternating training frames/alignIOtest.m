fs = 16000;
N = 1024;
L = 120;
M = 64;

pulseLength = 0.1 *fs;
simin = zeros(fs*2,1);
pulse = transpose(sinc(-2:4/pulseLength:2).^2);
trainblock = randi([0,1],(N/2-1)*log2(M),1);
qam_trainblock = qam_mod(trainblock,M);
Tx = ofdm_mod(repmat(qam_trainblock, 100, 1),N,L);
simin = [simin; pulse ;zeros(150,1);Tx];
%%
out = fftfilt(h,simin);
[out_aligned] = alignIO(out, pulse);
% [xcor, lags] = xcorr(simin,pulse);
% xcor = xcor/ max(xcor);
% [maxCorr, maxCorrIndex] = max(xcor);
% delay = lags(maxCorrIndex);
% %%
% 
% [maxSimin, maxSiminIndex] = max(simin);
% lag = maxCorrIndex / maxSiminIndex;
% a = maxCorrIndex/fs;
% %%
% safetyMargin = 20;
% IRtime = 150;
% aligned_out = simin(delay+ length(pulse)+ IRtime - safetyMargin:end);
%%
threshold = 0.9;
[out_aligned, sample] = alignIO(simin, 0.1*pulse);
%%
figure
subplot(4,1,1)
plot(pulse);
subplot(4,1,2)
plot(simin);
subplot(4,1,3)
plot(out(32000:34000));
title(sample-32000);
subplot(4,1,4)
plot(out_aligned(1:1000));
