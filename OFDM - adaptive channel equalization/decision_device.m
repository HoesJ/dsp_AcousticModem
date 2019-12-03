function [closestQamPoint] = decision_device(qam_with_noise,M)
    
    bits =  qamdemod(qam_with_noise,M,'outputtype','bit','UnitAveragePower',true);
    closestQamPoint = qammod(bits,M,'InputType','bit','UnitAveragePower',true);
end

