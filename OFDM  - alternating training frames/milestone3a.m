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
trainblock = randi([0,1],(N/2-1)*log2(M),1);
qam_trainblock = qam_mod(trainblock,M);

% QAM modulation
qamStream = qam_mod(bitStream, M);

% OFDM modulation
ofdmStream = ofdm_mod(qamStream, N, L, qam_trainblock, Lt, Ld);

% Channel
[simin,nbsecs,fs,pulse]=initparams(ofdmStream,fs, L);
sim('recplay');
out = simout.signals.values;
[rxOfdmStream,~] = alignIO(out,pulse);
% rxOfdmStream = fftfilt(h,ofdmStream);

% OFDM demodulation
[rxQamStream, H] = ofdm_demod(rxOfdmStream, N, L, qam_trainblock, Lt, Ld);

% QAM demodulation
rxBitStream = qam_demod(rxQamStream, M);

% Compute BER
[~,berTransmission] = ber(bitStream,rxBitStream);

% Construct image from bitstream
imageRx = bitstreamtoimage(rxBitStream, imageSize, bitsPerPixel);

% Plot images
pics = figure;
subplot(2,2,1); colormap(colorMap); image(imageData); axis image; title('Original image'); drawnow;
subplot(2,2,2); colormap(colorMap); image(imageRx); axis image; title(strcat('Simple transmission -- ',num2str(berTransmission))); drawnow;

refreshRate = (N/2-1) * Ld / fs; % (samples / channel estimate) / (samples / s) = s / channel estimate
visualize_demod(rxBitStream, H, refreshRate, Ld, N, M);
%%
pause
%% On - Off bit loading
M = M_default;
N = N_default;
L = L_default;
Lt = 3;
Ld = 5;
BWusage = 0.5;

% Probe channel
trainblock = randi([0,1],(N/2-1)*log2(M),1);
qam_trainblock = qam_mod(trainblock,M);
num = floor(fs/N/1.5);
ofdmStream = ofdm_mod(qam_trainblock, N, L, qam_trainblock, num, 1);
simin = 0.25 * simin;
[simin,nbsecs,fs,pulse]=initparams(ofdmStream,fs, L,0.1);
sim('recplay');
out = simout.signals.values;
[rxOfdmStream,~] = alignIO(out,pulse);
[rxQamStream, H] = ofdm_demod(rxOfdmStream, N, L, qam_trainblock, Lt, Ld);

[~,usedbins] = sort(abs(H), 'descend');
usedbins = usedbins(1:floor(BWusage*(N/2-1)));

% Convert; BMP image to bitstream
[bitStream, imageData, colorMap, imageSize, bitsPerPixel] = imagetobitstream('image.bmp');

%training block generation
trainblock = randi([0,1],(N/2-1)*log2(M),1);
qam_trainblock = qam_mod(trainblock,M);

% QAM modulation
qamStream = qam_mod(bitStream, M);

% OFDM modulation
ofdmStream = ofdm_mod(qamStream, N, L, qam_trainblock, Lt, Ld,usedbins);

% Channel
[simin,nbsecs,fs,pulse]=initparams(ofdmStream,fs, L);
sim('recplay');
out = simout.signals.values;
[rxOfdmStream,~] = alignIO(out,pulse);

% OFDM demodulation
[rxQamStream, H] = ofdm_demod(rxOfdmStream, N, L, qam_trainblock, Lt, Ld,usedbins);

% QAM demodulation
rxBitStream = qam_demod(rxQamStream, M);

% Compute BER
[~,berTransmission] = ber(bitStream,rxBitStream);

% Construct image from bitstream
imageRx = bitstreamtoimage(rxBitStream, imageSize, bitsPerPixel);

% Plot images
figure(pics);
subplot(2,2,3); colormap(colorMap); image(imageRx); axis image; title(strcat('On-Off bit loading -- ',num2str(berTransmission))); drawnow;

refreshRate = length(usedbins) * Ld / fs; % (samples / channel estimate) / (samples / s) = s / channel estimate
visualize_demod(rxBitStream, H, refreshRate, Ld, 2*length(usedbins)+2, M);
%%
pause;
%% Adaptive bit loading
M = M_default;
N = N_default;
L = L_default;
Lt = 3;
Ld = 5;
 
% Probe channel
trainblock = randi([0,1],(N/2-1)*log2(M),1);
qam_trainblock = qam_mod(trainblock,M);
num = floor(fs/N);
ofdmStream = ofdm_mod(qam_trainblock, N, L, qam_trainblock, num, 1);
ofdmStream = [ofdmStream;zeros(1*fs,1)];

[simin,nbsecs,fs,pulse]=initparams(ofdmStream,fs, L);
simin = 0.25 * simin;
sim('recplay');
out = simout.signals.values;
[rxOfdmStream,~] = alignIO(out,pulse);

[rxQamStream, H] = ofdm_demod(rxOfdmStream, N, L, qam_trainblock, num, 1);
H = mean(H,2);

psd_noise = powerEst(rxOfdmStream((end-1.5*fs):end), N);
figure; subplot(2,1,1); plot(abs(H)); subplot(2,1,2); plot(psd_noise);
% psd_in = powerEst(ofdmStream, N);
% psd_out = powerEst(rxOfdmStream, N);
% psd_noise = abs(psd_out - psd_in .* abs(H(:,1)).^2);
% figure; subplot(2,2,1); plot(psd_in); subplot(2,2,2); plot(psd_out); subplot(2,2,3); plot(abs(H(:,1))); subplot(2,2,4); plot(psd_noise);

b = floor(log2(1+(abs(H(:,1)).^2) ./ (gamma*psd_noise)));
b(b>6) = 6;
figure; plot(b);

% Convert; BMP image to bitstream
[bitStream, imageData, colorMap, imageSize, bitsPerPixel] = imagetobitstream('image.bmp');

% QAM modulation
qamStream = qam_mod(bitStream, b);

% OFDM modulation
ofdmStream = ofdm_mod(qamStream, N, L, qam_trainblock, Lt, Ld);

% Channel
[simin,nbsecs,fs,pulse]=initparams(ofdmStream,fs, L);
sim('recplay');
out = simout.signals.values;
[rxOfdmStream,~] = alignIO(out,pulse);

% OFDM demodulation
[rxQamStream, H] = ofdm_demod(rxOfdmStream, N, L, qam_trainblock, Lt, Ld);

% QAM demodulation
rxBitStream = qam_demod(rxQamStream, b);

% Compute BER
[~,berTransmission] = ber(bitStream,rxBitStream);

% Construct image from bitstream
imageRx = bitstreamtoimage(rxBitStream, imageSize, bitsPerPixel);

% Plot images

figure(pics);
subplot(2,2,4); colormap(colorMap); image(imageRx); axis image; title(strcat('Adaptive bit loading -- ',num2str(berTransmission))); drawnow;

refreshRate = (N/2-1) * Ld / fs; % (samples / channel estimate) / (samples / s) = s / channel estimate
pixPerPacket = Ld * sum(b);
visualize_demod(rxBitStream, H, refreshRate, Ld, N, M, pixPerPacket);
