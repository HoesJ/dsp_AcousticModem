fs =16000;
M_default = 16;
N_default = 1024;
L_default = 320;
gamma = 10;
%% Simple transmssion
M = M_default;
N = N_default;
L = L_default;
Lt = 3;
Ld = 5;

% Convert; BMP image to bitstream
[bitStream, imageData, colorMap, imageSize, bitsPerPixel] = imagetobitstream('image.bmp');

%training block generation
trainblock = randi([0,1],1000*log2(M),1);
qam_trainblock = qam_mod(trainblock,M);

% QAM modulation
SNR = 10;
SNRchannel = 10; 
Xk = qam_trainblock;
Nk = wgn(1000*log2(M),1,1);
Hk = ones(1000,1)*5;
% Hk = awgn(Hk, SNRchannel, 'measured');
Yk = Hk.*Xk;
% Yk = awgn(Yk, SNR, 'measured');
delta = 0.1;
Wk = 1/conj(Hk(1))+delta;

%adaptive channel est test
u =transpose(Yk);
D = transpose(Xk);
initialW = Wk;
mu = 0.2;
alpha = 0.1; %klein tov uT*u
[W,filteredOut] = adaptive_channel_filter(u,initialW, mu, alpha,M);
%%
figure
subplot(2,1,1); semilogy(abs(1./conj(W)-transpose([Hk(1);Hk]))); title('Error on channel');
subplot(2,1,2); semilogy(abs(filteredOut - transpose(Xk))); title('Error on expected output');