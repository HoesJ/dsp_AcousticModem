function [ofdm_seq] = ofdm_mod(qamsig,N,L,trainblock,Lt,Ld)
        % Pad qamsig to multiple of lastBin*Ld (N/2-1)
        mult = (N/2-1) * Ld;
        qamsig = [qamsig;zeros(ceil(length(qamsig) / mult) * mult - length(qamsig),1)];

        % Define P
        P = length(qamsig) / (N/2 - 1);

        %N is the frame size
        dataframe = reshape(qamsig, [N/2 - 1,P]);
        dataframe = [zeros(1,P);dataframe;zeros(1,P);conj(flip(dataframe))];
        ofdm_data = ifft(dataframe);
        
        %training frames
        trainingframe = [0;trainblock;0;conj(flip(trainblock))];
        ofdm_training = ifft(trainingframe);
        
        %interleaving of data and training
        num_processing_blocks = P/Ld;
        prototype = [ones(1,Lt), zeros(1,Ld)];
        indices = repmat(prototype, 1, num_processing_blocks);
        
        ofdm_packet = zeros(N, num_processing_blocks * (Lt+Ld));
        data_counter = 1;
        for i = 1:length(indices)
           if (indices(i))
                ofdm_packet(:,i) = ofdm_training;
           else
               ofdm_packet(:,i) = ofdm_data(:,data_counter);
               data_counter = data_counter + 1;
           end
        end
        
        % add cyclic prefix
        ofdm_seq = [ofdm_packet(N-L+1:N,:);ofdm_packet];

        % reshape to long sequence
        ofdm_seq = ofdm_seq(:);
end

