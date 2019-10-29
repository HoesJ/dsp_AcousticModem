%% Create a filter
fs = 16000;
lower = 700 /  fs;
upper = 3000 / fs;

order = 100;
filter1 = fir1(order, [lower upper], 'stop');
fvtool(filter1,1);

%% Do IR2 experiment
fs = 16000;
%sig = conv(wgn(1,fs*2+1,10), filter);
%a = [1,1];
sig = filter(filter1,1,wgn(1,fs*2+1,10))
[simin,nbsecs,fs] = initparams(sig', fs);
sim('recplay')
out = simout.signals.values;

figure
subplot(3,1,1)
plot(simin);
subplot(3,1,2)
plot(out); 
subplot(3,1,3)
threshold = max(out)*0.5;
index = find(out(fs*2:end) > threshold,1) + 2 * fs;
y = out(index:index+fs*2);
plot(y);

delay = 300;
L = 700;
K = 3000;
delayed_y = [zeros(delay,1);y];
u = sig;
A = toeplitz(u(L:K),fliplr(u(1:L)));
h = A \ delayed_y(L:K);
figure
subplot(2,1,1)
plot(h);
subplot(2,1,2)
plot(mag2db(abs(fft(h))))

%%
dftsize = 512;
f = dftsize/2;
figure
[s_out,f_out,t_out,ps_out] = spectrogram(out,dftsize,dftsize/2,f,fs);

plot(f_out, 10*log10(mean(ps_out,2)));

%%



