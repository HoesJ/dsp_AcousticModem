fs =16000;
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
% %%
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
[out_aligned] = alignIO(simin, threshold);
%%
figure
subplot(4,1,1)
plot(pulse);
subplot(4,1,2)
plot(simin);
subplot(4,1,3)
plot(xcor);
subplot(4,1,4)
plot(aligned_out);
