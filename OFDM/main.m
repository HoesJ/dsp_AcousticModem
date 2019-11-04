% Exercise session 4: DMT-OFDM transmission scheme

% Convert BMP image to bitstream
[bitStream, imageData, colorMap, imageSize, bitsPerPixel] = imagetobitstream('image.bmp');

% QAM modulation
qam_order = 256;
qamStream = qam_mod(bitStream, qam_order);

% OFDM modulation
N= 1024;
L = 120; %length impulse response;
ofdmStream = ofdm_mod(qamStream, N, L);

% Channel
SNR = 25;
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
subplot(2,1,1); colormap(colorMap); image(imageData); axis image; title('Original image'); drawnow;
subplot(2,1,2); colormap(colorMap); image(imageRx); axis image; title(['Received image']); drawnow;

%% BER per bin
res = zeros(N,1);
ratio = zeros(N,1);
for k = 1:length(qamStream)/N
    for i = 1:N
       rx = rxBitStream((i-1)*8+1+(k-1)*N*8:i*8+(k-1)*N*8);
       tx = bitStream((i-1)*8+1+(k-1)*N*8:i*8+(k-1)*N*8);
       [t,p] = ber(rx,tx);
       res(i) = res(i) + t;
       ratio(i) = ratio(i) + p;
    end
end
figure
plot(res)

%% Adaptive bit loading
noiseInTime = rxOfdmStreamWithNoise - rxOfdmStream;
noiseQam = ofdm_demod(noiseInTime, N, L);
noiseQam = reshape(noiseQam, [N/2-1 length(noiseQam)/(N/2-1)]);
Pn = mean(abs(noiseQam).^2,2);

H = fft(h,N-3);
H = H(1:N/2-1);

b = floor(log2(1+(abs(H).^2) ./ (10*Pn)));

