SNR = 15;
qam_order_default = 64;
N_default = 1024;
L_default = 120;
gamma = 10;
load('h_channel.mat')
%% Simple transmssion

% Convert BMP image to bitstream
[bitStream, imageData, colorMap, imageSize, bitsPerPixel] = imagetobitstream('image.bmp');

% QAM modulation
qam_order = qam_order_default;
qamStream = qam_mod(bitStream, qam_order);

% OFDM modulation
N = N_default;
L = L_default;
ofdmStream = ofdm_mod(qamStream, N, L);

% Channel
rxOfdmStream = fftfilt(h,ofdmStream);
rxOfdmStreamWithNoise = awgn(rxOfdmStream, SNR, 'measured');

% OFDM demodulation
rxQamStream = ofdm_demod(rxOfdmStreamWithNoise, N, L, h);

% QAM demodulation
rxBitStream = qam_demod(rxQamStream, qam_order);

% Compute BER
[~,berTransmission] = ber(bitStream,rxBitStream);

% Construct image from bitstream
imageRx = bitstreamtoimage(rxBitStream, imageSize, bitsPerPixel);

% Plot images
pics = figure;
subplot(2,2,1); colormap(colorMap); image(imageData); axis image; title('Original image'); drawnow;
subplot(2,2,2); colormap(colorMap); image(imageRx); axis image; title(strcat('Simple transmission -- ',num2str(berTransmission))); drawnow;

%% BER per bin
res = zeros(N,1);
M = log2(qam_order);
for k = 1:length(qamStream)/N
    for i = 1:N
       rx = rxBitStream((i-1)*M+1+(k-1)*N*M:i*M+(k-1)*N*M);
       tx = bitStream((i-1)*M+1+(k-1)*N*M:i*M+(k-1)*N*M);
       [t,~] = ber(rx,tx);
       res(i) = res(i) + t;
    end
end
aid = figure;
subplot(2,1,1);
plot(res)
title('BER per frequency bin');

%% Use On-Off bit loading
lastBin = 450;

% Convert BMP image to bitstream
[bitStream, imageData, colorMap, imageSize, bitsPerPixel] = imagetobitstream('image.bmp');

% QAM modulation
qam_order = qam_order_default;
qamStream = qam_mod(bitStream, qam_order);

% OFDM modulation
N = N_default;
L = L_default;
ofdmStream = ofdm_mod(qamStream, N, L, lastBin);

% Channel
rxOfdmStream = fftfilt(h,ofdmStream);
rxOfdmStreamWithNoise = awgn(rxOfdmStream, SNR, 'measured');

% OFDM demodulation
rxQamStream = ofdm_demod(rxOfdmStreamWithNoise, N, L, h, lastBin);

% QAM demodulation
rxBitStream = qam_demod(rxQamStream, qam_order);

% Compute BER
[~,berTransmission] = ber(bitStream,rxBitStream);

% Construct image from bitstream
imageRx = bitstreamtoimage(rxBitStream, imageSize, bitsPerPixel);

% Plot images
figure(pics);
subplot(2,2,3); colormap(colorMap); image(imageRx); axis image; title(strcat('On-Off bit loading -- ',num2str(berTransmission))); drawnow;

%% Use adaptive bit loading
noiseInTime = rxOfdmStreamWithNoise - rxOfdmStream;
noiseQam = ofdm_demod(noiseInTime, N, L);
noiseQam = reshape(noiseQam, [N/2-1 length(noiseQam)/(N/2-1)]);
Pn = mean(abs(noiseQam).^2,2);

H = fft(h,N-3);
H = H(1:N/2-1);

b = floor(log2(1+(abs(H).^2) ./ (gamma*Pn)));
figure(aid);
subplot(2,1,2);
plot(b);
title('b');

% Convert BMP image to bitstream
[bitStream, imageData, colorMap, imageSize, bitsPerPixel] = imagetobitstream('image.bmp');

% QAM modulation
qam_order = b;
qamStream = qam_mod(bitStream, qam_order);

% OFDM modulation
N = N_default;
L = L_default;
ofdmStream = ofdm_mod(qamStream, N, L);

% Channel
rxOfdmStream = fftfilt(h,ofdmStream);
rxOfdmStreamWithNoise = awgn(rxOfdmStream, SNR, 'measured');

% OFDM demodulation
rxQamStream = ofdm_demod(rxOfdmStreamWithNoise, N, L, h);

% QAM demodulation
rxBitStream = qam_demod(rxQamStream, qam_order);

% Compute BER
[~,berTransmission] = ber(bitStream,rxBitStream);

% Construct image from bitstream
imageRx = bitstreamtoimage(rxBitStream, imageSize, bitsPerPixel);

% Plot images
figure(pics);
subplot(2,2,4); colormap(colorMap); image(imageRx); axis image; title(strcat('Adaptive bit loading -- ',num2str(berTransmission))); drawnow;

