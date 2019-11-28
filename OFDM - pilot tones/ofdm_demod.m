function [qamsig,H] = ofdm_demod(ofdm_seq,N,L,trainblock,trainbins)
    % Padd  signal
    ofdm_seq = [ofdm_seq;zeros(ceil(length(ofdm_seq) / (N+L)) * (N+L) - length(ofdm_seq),1)];

    % reshape ofdm_sig
    qamsig = reshape(ofdm_seq, N+L, []);
    
    % throw away cyclic prefix
    qamsig = qamsig(L+1:end,:);
    
    % fft
    qamsig = fft(qamsig);
        
    % throw away copies
    qamsig = qamsig(2:N/2,:);
    
    % Channel estimation
    H = zeros(N/2-1,size(qamsig,2));
    for j = 1:size(qamsig,2)
        H(trainbins,j) = qamsig(trainbins,j) ./ trainblock;
        h = ifft([0;H(:,j);0;conj(H(:,j))]);
        h(L+1:end) = 0;
        tmp = fft(h);
        H(:,j) = 2*tmp(2:512); %% *2 omdat we vermogen hebben weggeknipt en de schaal moet terug gaan
        qamsig(:,j) = qamsig(:,j) ./ H(:,j);
    end
    
    % Extract data signal
    databins = 1:(N/2-1);
    databins(trainbins) = 0;
    databins = databins(databins ~= 0);
    qamsig = qamsig(databins,:);
    
    % reshape to a line
    qamsig = qamsig(:);    
end
