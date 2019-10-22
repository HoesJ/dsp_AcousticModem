function [ber,ratio] = ber(x,y)
% Compute number of bit errors and bit error rate (BER)
[ber,ratio] = biterr(x,y);
end

