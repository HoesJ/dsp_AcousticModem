fs =16000;
M_default = 16;
N_default = 1024;
L_default = 320;
gamma = 10;
%% Stereo transmssion
M = M_default;
N = N_default;
L = L_default;
Lt = 3;

% Convert; BMP image to bitstream
[bitStream, imageData, colorMap, imageSize, bitsPerPixel] = imagetobitstream('image.bmp');

%training block generation
trainblock = randi([0,1],(N/2-1)*log2(M),1);
qam_trainblock = qam_mod(trainblock,M);

% QAM modulation
qamStream = qam_mod(zeros(length(bitStream),1), M);

% OFDM modulation
[ofdmStream1,ofdmStream2] = ofdm_mod_stereo(0,0, N, L, qam_trainblock, Lt,a,b);

%generating two training blocks that get played after eachother.

ofdmStreamRight = [zeros(length(ofdmStream1),1); ofdmStream2];
ofdmStreamLeft = [ofdmStream1; zeros(length(ofdmStream2),1)];

% transmit
[simin,nbsecs,fs,pulse]=initparams_stereo(ofdmStreamLeft,ofdmStreamRight, fs, L);
sim('recplay');
out = simout.signals.values;
[rxOfdmStream,~] = alignIO(out,pulse);

% OFDM demodulation
mu = 0.3;
alphaOverride = 0;
if (alphaOverride == 0)
    alpha = 10^(floor(log10(rxOfdmStream(length(rxOfdmStream)/3)) * 2 - 1));
else
    alpha = alphaOverride;
end
h1and2 = ifft(H1and2);
[rxQamStream,H] = ofdm_demod(rxOfdmStream,N,L,trainblock,Lt,mu,alpha,M);