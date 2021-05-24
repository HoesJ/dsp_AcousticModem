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
    if nargin < 5
        trainbins = 1:(N/2-1);
    end
    H = zeros(N/2-1,1);
    count = 1;
    for i = trainbins
        A = transpose(qamsig(i,:));
        b = repmat(trainblock(count), length(A),1);
        H(i) = b\A;
        count = count + 1;
    end
    if nargin > 4 % perform interpolation        
        h = ifft([0;H;0;conj(H)]);
        h(L+1:end) = 0;
        H = fft(h);
        H = 2*H(2:512); %% *2 omdat we vermogen hebben weggeknipt en de schaal moet terug gaan
    end

    % Channel equalisation
    qamsig = diag(H)\qamsig;
    
    % Extract data signal
    if nargin > 4
        databins = 1:(N/2-1);
        databins(trainbins) = 0;
        databins = databins(databins ~= 0);
        qamsig = qamsig(databins,:);
    end
    
    % reshape to a line
    qamsig = qamsig(:);    
end