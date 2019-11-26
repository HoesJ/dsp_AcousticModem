SNR = 1000;
qam_order_default = 256;
N_default = 1024;
L_default = 120;
gamma = 10;
load('h_channel.mat')
%% Training sequence
M = qam_order_default;
N = N_default;
L = L_default;

trainblock = randi([0,1],(N/2-1)*log2(M),1);
qam_trainblock = qam_mod(trainblock,M);
Tx = ofdm_mod(repmat(qam_trainblock, 100, 1),N,L);

Rx = fftfilt(h,Tx);
Rx = awgn(Rx, SNR, 'measured');

[qamRxStream, channelEst] = ofdm_demod(Rx,N,L,qam_trainblock);
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
plot(abs(fft(h,N)));
title('Real Channel (frequency)')

[~,biterr] = ber(qam_demod(qamRxStream,M),repmat(trainblock, 100, 1));
disp("BER: " + num2str(biterr));
%% Real acoustic channel
M = qam_order_default;
N = N_default;
L = L_default;
fs = 16000;

trainblock = randi([0,1],(N/2-1)*log2(M),1);
qam_trainblock = qam_mod(trainblock,M);
Tx = ofdm_mod(repmat(qam_trainblock, 100, 1),N,L);

[simin,nbsecs,fs,pulse]=initparams(Tx,fs);
sim('recplay');
out = simout.signals.values;
[Rx,~] = alignIO(out,pulse);

[qamRxStream, channelEst] = ofdm_demod(Rx,N,L,qam_trainblock);
hEst = ifft([0;channelEst;0;conj(flip(channelEst))],N);
hEst = hEst(1:L);
figure
subplot(2,1,1);
plot(hEst);
title('Estimated Channel (time)')
subplot(2,1,2);
plot(abs(channelEst));
title('Estimated Channel (frequency)')

[~,biterr] = ber(qam_demod(qamRxStream,M),repmat(trainblock, 100, 1));
disp("BER: " + num2str(biterr));

figure
subplot(2,1,1); plot(simin);
subplot(2,1,2); plot(out);

figure
subplot(2,1,1); plot(Tx(1:2000));
subplot(2,1,2); plot(Rx(1:2000));