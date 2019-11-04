function [qamsig] = ofdm_demod(ofdm_seq,N,L,h)
    % Define P
    P = length(ofdm_seq) / (N + L);
    
    % reshape ofdm_sig
    qamsig = reshape(ofdm_seq, [N+L P]);
    
    % throw away cyclic prefix
    qamsig = qamsig(L+1:end,:);
    
    % fft
    qamsig = fft(qamsig);
    
    % throw away copies
    qamsig = qamsig(2:N/2,:);
    
    % Channel equalisation
    if nargin >= 4
        H = fft(h, N);
        qamsig = diag(H(2:N/2))\qamsig;
    end
%     qamsig = qamsig./H(2:N/2);
    
    % reshape to a line
    qamsig = reshape(qamsig, [(N/2 - 1) * P 1]);    
end
