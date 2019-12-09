function [pow] = powerEst(sig, N)
    % Padd  signal to buckets
    mult = N;
    sig = [sig;zeros(ceil(length(sig) / mult) * mult - length(sig),1)];
    
    % Define P
    P = length(sig) / N;
    
    % reshape ofdm_sig
    sig = reshape(sig, [N P]);
    
    % fft
    psig = fft(sig);
    
    % throw away copies
    psig = psig(2:N/2,:);
    
    % take mean for power
    pow = mean(abs(psig).^2,2);
end