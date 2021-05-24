function [demodSig] = qam_demod(qamSig,order)
    if (length(order) == 1)
        demodSig = qamdemod(qamSig,order,'outputtype','bit','UnitAveragePower',true);
    else
        qamSig = transpose(reshape(qamSig, [length(order) length(qamSig)/length(order)]));
        demodSig = zeros(size(qamSig,1), sum(order));
        for i = 1:length(order)
            if (order(i) == 0)
                continue;
            end
            fBin = qamSig(:,i);
            demodfBin = qamdemod(fBin,2^order(i),'outputtype','bit','UnitAveragePower',true);
            demodfBin = reshape(demodfBin, [order(i) length(demodfBin)/order(i)]);
            start = sum(order(1:i)) - order(i)+1;
            stop = start + order(i) -1;
            demodSig(:,start:stop) = demodfBin';
        end
        demodSig = demodSig';
        demodSig = demodSig(:);
    end
end