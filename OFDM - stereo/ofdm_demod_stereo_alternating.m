function [qamsig,H] = ofdm_demod_stereo_alternating(ofdm_seq,N,L,trainblock,Lt,Ld,usedbins)
    if (nargin < 7)
       usedbins = 1:(N/2-1); 
    end

    % Padd  signal to buckets
    mult = (N+L) * (Ld+Lt);
    ofdm_seq = [ofdm_seq;zeros(ceil(length(ofdm_seq) / mult) * mult - length(ofdm_seq),1)];

    % reshape ofdm_sig
    qamsig = reshape(ofdm_seq, N+L, []);
    
    % throw away cyclic prefix
    qamsig = qamsig(L+1:end,:);
    
    % fft
    qamsig = fft(qamsig);
        
    % throw away copies
    qamsig = qamsig(2:N/2,:);
    
    % Channel estimation
    num_processing_blocks = size(qamsig,2)/(Lt+Ld);
    H = zeros(N/2-1, num_processing_blocks);
    for i = 1:num_processing_blocks
        for j = 1:length(trainblock)
            A = transpose(qamsig(j,((i-1)*(Lt+Ld)+1):((i-1)*(Lt+Ld)+Lt) ));
            b = repmat(trainblock(j), size(A,1),1);
            H(j,i) = b\A;
        end
        disp(i);
    end

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

