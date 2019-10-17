%% play sine wave

sig = sin(2*pi*1000*(0:1/fs:2));

[simin,nbsecs,fs] = initparams(sig', fs);
sim('recplay')
out = simout.signals.values;

%% makes a onesided fft
P2 = abs(fft(out)/length(out));
P1 = 2*P2(1:length(out)/2+1);

%% see if code above works
figure
subplot(2,1,1)
plot(abs(fft(out)));
subplot(2,1,2)
plot(P1);