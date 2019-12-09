function [qamsig,H] = ofdm_demod_stereo(ofdm_seq,N,L,trainblock,Lt,mu,alpha,qam_order,usedbins)
    if (nargin < 9)
       usedbins = 1:(N/2-1); 
    end

    % Padd  signal to buckets
    mult = (N+L);
    ofdm_seq = [ofdm_seq;zeros(ceil(length(ofdm_seq) / mult) * mult - length(ofdm_seq),1)];

    % reshape ofdm_sig
    qamsig = reshape(ofdm_seq, N+L, []);
    
    % throw away cyclic prefix
    qamsig = qamsig(L+1:end,:);
    
    % fft
    qamsig = fft(qamsig);
        
    % throw away copies
    qamsig = qamsig(2:N/2,:);
    
    % Initial Channel estimation
    H = zeros(N/2-1,1);
    for j = 1:length(trainblock)
        A = transpose(qamsig(j,1:Lt));
        b = repmat(trainblock(j), size(A,1),1);
        H(j) = b\A;
    end
%     H = awgn(H, 10, 'measured');
    
    % Adaptive filtering
    [W, filteredOutput] = adaptive_channel_filter(qamsig(:,Lt+1:end),conj(1./H),mu,alpha,qam_order);
%     H = [H,1./conj(W)];
    H = [1./conj(W)];
    
    % data extraction
    datasig = filteredOutput(usedbins,:);
    
    % reshape to a line
    qamsig = datasig(:);    
end