SNR = 25;
qam_order_default = 16;
N_default = 1024;
L_default = 320;
load('h_channel.mat')
%%
close all;
M = qam_order_default;
N = N_default;
L = L_default;
fs = 16000;

trainbins = 1:2:511;
data = randi([0,1], 80000,1);

trainblock = randi([0,1],length(trainbins)*log2(M),1);
qam_trainblock = qam_mod(trainblock,M);

qam_stream = qam_mod(data,M);
Tx = ofdm_mod(qam_stream,N,L,qam_trainblock,trainbins);

% Rx = fftfilt(h,Tx);
% Rx = awgn(Rx, SNR, 'measured');
[simin,nbsecs,fs,pulse]=initparams(Tx,fs,L);
sim('recplay');
out = simout.signals.values;
[Rx,~] = alignIO(out,pulse);

[qamRxStream, channelEst] = ofdm_demod(Rx,N,L,qam_trainblock, trainbins);
hEst = ifft([0;channelEst;0;conj(flip(channelEst))],N);
hEst = hEst(1:L);

figure
subplot(2,2,1);
plot(hEst);
title('Estimated Channel (time)')
subplot(2,2,3);
plot(h);
title('Real Channel (time)')
subplot(2,2,2);
plot(abs(channelEst));
title('Estimated Channel (frequency)')
subplot(2,2,4);
tmp = abs(fft(h,N)); plot(tmp(1:511));
title('Real Channel (frequency)')

[~,biterr] = ber(qam_demod(qamRxStream,M),data);
disp("BER: " + num2str(biterr));


figure
subplot(2,1,1); plot(simin);
subplot(2,1,2); plot(out);

figure
subplot(2,1,1); plot(Tx(1:2000));
subplot(2,1,2); plot(Rx(1:2000));