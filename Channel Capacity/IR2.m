clear

fs = 16000;
sig = wgn(1,fs*2+1,5);

fs = 16000;

[simin,nbsecs,fs] = initparams(sig', fs);
sim('recplay')
out = simout.signals.values;

%%
figure
subplot(3,1,1)
plot(simin);
subplot(3,1,2)
plot(out); 
subplot(3,1,3)
threshold = 0.004;
plot(out(find(out> threshold,1):find(out> threshold,1)+fs*2));

%%
delay = 150;
L = 300;
K = 3000;
y = out(find(out> threshold,1):(find(out> threshold,1)+fs*2));
delayed_y = [zeros(delay,1);y];
u = sig;
A = toeplitz(u(L:K),fliplr(u(1:L)));
h = A \ delayed_y(L:K);
figure
subplot(2,1,1)
plot(h);
subplot(2,1,2)
plot(abs(fft(h)))

%%
dftsize = 512;
f = dftsize/2;
figure
[s_out,f_out,t_out,ps_out] = spectrogram(out,dftsize,dftsize/2,f,fs);

plot(f_out, 10*log10(mean(ps_out,2)));

%%



