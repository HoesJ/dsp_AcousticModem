function [qamsig,H] = ofdm_demod(ofdm_seq,N,L,trainblock,Lt,mu,alpha,usedbins)
    if (nargin < 8)
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
    
    [W, filteredOutput] = adaptive_channel_filter(qamsig(:,Lt+1:end),D,conj(1./H), mu, alpha)

    % Channel equalisation and data extraction
    datasig = zeros(N/2-1,num_processing_blocks*Ld);
    for i = 1:num_processing_blocks
        extractrange = ((i-1)*(Lt+Ld)+Lt+1):((i-1)*(Lt+Ld)+Lt+Ld);
        storerange = ((i-1)*Ld+1):(i*Ld);
        datasig(:,storerange) = diag(H(:,i))\qamsig(:,extractrange);
    end
    datasig = datasig(usedbins,:);
    
    % reshape to a line
    qamsig = datasig(:);    
end