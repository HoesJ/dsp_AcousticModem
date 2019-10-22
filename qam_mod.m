function [qam] = qam_mod(inputSig,order)

%  inputSig = round(rescale(inputSig, 0, order-1));
 qam = qammod(inputSig,order,'InputType','bit','UnitAveragePower',false);
end