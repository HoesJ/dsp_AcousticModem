function [qamsig] = ofdm_demod(ofdm_seq,N,P)
   %N is the frame size
   qamstep = N/2-1;
   disp(qamstep)
   qamsig = [];
   
for i = 1:P
    disp(i)

    a = fft(ofdm_seq(:,i));
    disp(a)
%     frame_i = ifft([0;ofdm_seq(i:i+N/2-2);0;flip(conj(ofdm_seq(i:i+N/2-2)))]); %workhorse of the function
%     disp(frame_i')
    qamsig = [qamsig a'];
    
end
    
end
