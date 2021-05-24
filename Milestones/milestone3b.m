pauseTime = 5;

fs =16000;
M_default = 16;
N_default = 1024;
L_default = 320;
safetyMargin = 45;
%% Pilot
M = M_default;
N = N_default;
L = L_default;
trainbins = 1:2:511;

% Convert; BMP image to bitstream
[bitStream, imageData, colorMap, imageSize, bitsPerPixel] = imagetobitstream('image.bmp');

% Training block generation
trainblock = randi([0,1],length(trainbins)*log2(M),1);
qam_trainblock = qam_mod(trainblock,M);

% QAM modulation
qamStream = qam_mod(bitStream, M);

% OFDM modulation
ofdmStream = ofdm_mod(qamStream,N,L,qam_trainblock,trainbins);

% Channel
[simin,nbsecs,fs,pulse]=initparams(ofdmStream,fs, L);
sim('recplay');
out = simout.signals.values;
[rxOfdmStream,~] = alignIO(out,pulse, safetyMargin);

% OFDM demodulation
[rxQamStream, H] = ofdm_demod(rxOfdmStream,N,L,qam_trainblock, trainbins);

% QAM demodulation
rxBitStream = qam_demod(rxQamStream, M);

% Compute BER
[~,berTransmission] = ber(bitStream,rxBitStream);

% Construct image from bitstream
imageRx = bitstreamtoimage(rxBitStream, imageSize, bitsPerPixel);

% Plot images
pics = figure;
subplot(2,1,1); colormap(colorMap); image(imageData); axis image; title('Original image'); drawnow;
subplot(2,1,2); colormap(colorMap); image(imageRx); axis image; title(strcat('Simple transmission -- ',num2str(berTransmission))); drawnow;

refreshRate = (N/2-1) / fs; % (samples / channel estimate) / (samples / s) = s / channel estimate
pixPerPacket = (N/2 - 1) / 2;
visualize_demod(rxBitStream, H, refreshRate, Ld, N, M, pixPerPacket);

pause(pauseTime);
%% Pilot with adaptive bit loading
M = M_default;
N = N_default;
L = L_default;
Lt = 3;
Ld = 5;
trainbins = 1:2:511;

% Probe channel
trainblock = randi([0,1],(N/2-1)*log2(M),1);
qam_trainblock = qam_mod(trainblock,M);
num = floor(1*fs/N);
ofdmStream = ofdm_mod(repmat(qam_trainblock, num, 1), N, L);
ofdmStream = [ofdmStream;zeros(fs,1)];

[simin,nbsecs,fs,pulse]=initparams(ofdmStream,fs,L);
sim('recplay');
out = simout.signals.values;
[rxOfdmStream,~] = alignIO(out,pulse);
[rxQamStream, H] = ofdm_demod(rxOfdmStream, N, L, qam_trainblock);
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

% Training block generation
trainblock = randi([0,1],sum(b),1);
qam_trainblock = qam_mod(trainblock,b);
qam_trainblock = qam_trainblock(trainbins);
qam_trainblock(qam_trainblock == 0) = 1; % Otherwise gives problem with trainblock values of 0

% QAM modulation
qamStream = qam_mod(bitStream, b);

% OFDM modulation
ofdmStream = ofdm_mod(qamStream,N,L,qam_trainblock,trainbins);

% Channel
[simin,nbsecs,fs,pulse]=initparams(ofdmStream,fs, L);
sim('recplay');
out = simout.signals.values;
[rxOfdmStream,~] = alignIO(out,pulse, safetyMargin);

% OFDM demodulation
[rxQamStream, H] = ofdm_demod(rxOfdmStream,N,L,qam_trainblock, trainbins);
rxQamStream = rxQamStream(~isnan(rxQamStream));

% QAM demodulation
rxBitStream = qam_demod(rxQamStream, b);

% Compute BER
[~,berTransmission] = ber(bitStream,rxBitStream);

% Construct image from bitstream
imageRx = bitstreamtoimage(rxBitStream, imageSize, bitsPerPixel);

% Plot images
pics = figure;
subplot(2,1,1); colormap(colorMap); image(imageData); axis image; title('Original image'); drawnow;
subplot(2,1,2); colormap(colorMap); image(imageRx); axis image; title(strcat('Simple transmission -- ',num2str(berTransmission))); drawnow;

