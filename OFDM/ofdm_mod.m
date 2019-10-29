function [ofdm_seq] = ofdm_mod(qamsig,N,P)
   %N is the frame size
   qamstep = N/2-1;
   disp(qamstep)
   ofdm_seq = zeros(N,1);
   
for i = 1:N/2-1:P*(N/2-1)
    frame_i = ifft([0;qamsig(i:i+N/2-2);0;flip(conj(qamsig(i:i+N/2-2)))]); %workhorse of the function
    ofdm_seq = horzcat(ofdm_seq ,frame_i);
    
end
   ofdm_seq(:,1)=[];
end
