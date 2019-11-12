function [qamsig] = ofdm_demod_legacy(ofdm_seq,N,L,h,lastBin)
    if nargin < 5
        lastBin = N/2-1;
    end

    % Define P
    P = length(ofdm_seq) / (N + L);
    
    % reshape ofdm_sig
    qamsig = reshape(ofdm_seq, [N+L P]);
    
    % throw away cyclic prefix
    qamsig = qamsig(L+1:end,:);
    
    % fft
    qamsig = fft(qamsig);
    
    % throw away copies
    qamsig = qamsig(2:lastBin+1,:);
    
    % Channel equalisation
    if ~(nargin < 4)
        H = fft(h, N);
        qamsig = diag(H(2:lastBin+1))\qamsig;
    end
    
    % reshape to a line
    qamsig = reshape(qamsig, [lastBin*P 1]);    
end
