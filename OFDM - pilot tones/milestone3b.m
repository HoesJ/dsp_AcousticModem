fs =16000;
M_default = 16;
N_default = 1024;
L_default = 320;
safetyMargin = 45;
gamma = 10;
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
pixPerPacket = (N/2 - 1-length(trainbins)) * log2(M);
visualize_demod(rxBitStream, H, refreshRate, 1, N, M, pixPerPacket);