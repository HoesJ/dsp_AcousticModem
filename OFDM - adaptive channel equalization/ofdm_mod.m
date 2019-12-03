function [ofdm_seq] = ofdm_mod(qamsig,N,L,trainblock,Lt,usedbins)
        if (nargin < 6)
            usedbins = 1:(N/2-1);
        end
        num_bins = length(usedbins);
        
        % Pad qamsig to multiple of lastBin*Ld (N/2-1)
        mult = num_bins;
        qamsig = [qamsig;zeros(ceil(length(qamsig) / mult) * mult - length(qamsig),1)];

        % Define P
        P = length(qamsig) / num_bins;

        % N is the frame size
        dataframe = zeros(N/2-1, P);
        dataframe(usedbins,:) = reshape(qamsig, [num_bins,P]);
        dataframe = [zeros(1,P);dataframe;zeros(1,P);conj(flip(dataframe))];
        ofdm_data = ifft(dataframe);
        
        % Training frames
        trainingframe = [0;trainblock;0;conj(flip(trainblock))];
        ofdm_training = ifft(trainingframe);

        %sending training packet zith Lt training frames
        training_packet = repmat(ofdm_training,1,Lt);
        ofdm_packet = [training_packet; ofdm_data];
        
        % add cyclic prefix
        ofdm_seq = [ofdm_packet(N-L+1:N,:);ofdm_packet];

        % reshape to long sequence
        ofdm_seq = ofdm_seq(:);
end

