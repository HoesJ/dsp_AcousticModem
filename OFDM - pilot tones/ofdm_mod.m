function [ofdm_seq] = ofdm_mod(qamsig,N,L,trainblock,trainbins)
    if (nargin < 4)
        % Pad qamsig to multiple of lastBin (N/2-1)
        qamsig = [qamsig;zeros(ceil(length(qamsig) / (N/2 - 1)) * (N/2 - 1) - length(qamsig),1)];

        % Define P
        P = length(qamsig) / (N/2 - 1);

        %N is the frame size
        frame = reshape(qamsig, [N/2 - 1,P]);
        frame = [zeros(1,P);frame;zeros(1,P);conj(flip(frame))];
        ofdm_seq = ifft(frame);

        % add cyclic prefix
        ofdm_seq = [ofdm_seq(N-L+1:N,:);ofdm_seq];

        % reshape to long sequence
        ofdm_seq = reshape(ofdm_seq, [(N+L)*P 1]);
    else
        if (length(trainblock) ~= length(trainbins))
            error('Number of train symbols should be equal to number of trainbins');
        end
        
        % Pad qamsig to multiple of used data bins
        num_bins = N/2-1 - length(trainbins);
        qamsig = [qamsig;zeros(ceil(length(qamsig) / (num_bins)) * (num_bins) - length(qamsig),1)];

        % Define P
        P = length(qamsig) / (num_bins);

        % Interleave data with training symbols
        databins = 1:(N/2-1);
        databins(trainbins) = 0;
        databins = databins(databins ~= 0);
        
        % N is the frame size
        dataframe = reshape(qamsig, [num_bins,P]);
        trainframe = repmat(trainblock, 1,P);
        frame = zeros(N/2-1,P);
        frame(databins,:) = dataframe;
        frame(trainbins,:) = trainframe;
        frame = [zeros(1,P);frame;zeros(1,P);conj(flip(frame))];
        ofdm_seq = ifft(frame);

        % add cyclic prefix
        ofdm_seq = [ofdm_seq(N-L+1:N,:);ofdm_seq];

        % reshape to long sequence
        ofdm_seq = reshape(ofdm_seq, [(N+L)*P 1]);
    end
end

