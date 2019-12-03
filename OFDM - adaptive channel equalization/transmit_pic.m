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

% Convert; BMP image to bitstream
[bitStream, imageData, colorMap, imageSize, bitsPerPixel] = imagetobitstream('image.bmp');

%training block generation
trainblock = randi([0,1],1000*log2(M),1);
qam_trainblock = qam_mod(trainblock,M);

% QAM modulation
qamStream= qam_mod(bitStream, M);

% OFDM modulation
ofdmStream = ofdm_mod(qamStream, N, L, qam_trainblock, Lt);

% transmit
[simin,nbsecs,fs,pulse]=initparams(ofdmStream,fs, L);
sim('recplay');
out = simout.signals.values;
[rxOfdmStream,~] = alignIO(out,pulse);
