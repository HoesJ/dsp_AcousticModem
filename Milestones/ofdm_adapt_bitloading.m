SNR = 25;
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
%% Use adaptive bit loading
noiseInTime = rxOfdmStreamWithNoise - rxOfdmStream;
noiseQam = ofdm_demod(noiseInTime, N, L);
noiseQam = reshape(noiseQam, [N/2-1 length(noiseQam)/(N/2-1)]);
Pn = mean(abs(noiseQam).^2,2);

H = fft(h,N-3);
H = H(1:N/2-1);

b = floor(log2(1+(abs(H).^2) ./ (gamma*Pn)));
figure
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
subplot(2,2,3); colormap(colorMap); image(imageRx); axis image; title(strcat('Adaptive bit loading -- ',num2str(berTransmission))); drawnow;

