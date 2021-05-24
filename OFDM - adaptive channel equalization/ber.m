function [ber,ratio] = ber(x,y)
% Compute number of bit errors and bit error rate (BER)
% Up until minimum length
    
    l = min(length(x), length(y));
    [ber,ratio] = biterr(x(1:l),y(1:l));
end

