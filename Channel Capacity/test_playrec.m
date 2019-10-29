fs = 16000;
f = 1500;
Amp = 1;
T = 2;
ts = 1/fs;
t=0:ts:T;
sinewave = Amp*sin(2*pi*f*t);
[simin,nbsecs,fs]=initparams(sinewave,fs);
sim('recplay');
out = simout.signals.values;
soundsc(out,fs)