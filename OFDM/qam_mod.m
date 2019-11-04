function [qam] = qam_mod(inputSig,order)
    if (length(order) == 1)
        qam = qammod(inputSig,order,'InputType','bit','UnitAveragePower',true);
    else
        % Group bits per bin
        nbCols = sum(order);
        nbRows = ceil(length(inputSig) / nbCols);
        % Pad inputSig
        inputSig = [inputSig;zeros(nbRows * nbCols - length(inputSig),1)];
        inputSig = transpose(reshape(inputSig, [nbCols nbRows]));
        qam = zeros(nbRows, length(order));
        for i = 1:length(order)
            if (order(i) == 0)
                qam(:,i) = zeros(nbRows,1);
                continue;
            end
            start = sum(order(1:i)) - order(i)+1;
            stop = start + order(i) -1;
            fBin = inputSig(:,start:stop)';
            fBin = fBin(:);
            qamForBin = qammod(fBin,2^order(i),'InputType','bit','UnitAveragePower',true);
            qam(:,i) = qamForBin;
        end
        qam = transpose(qam);
        qam = qam(:);
    end
end