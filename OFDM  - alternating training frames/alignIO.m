function [out_aligned, sample_number] = alignIO(out,pulseOrThreshold, safetyMargin)

% align the input "out" using a pulse or a threshold value. The function return the "out" signal with the pulse cut off. ~
% if the input pulseOrThreshold is a vector, it uses the crosscorrelation
% between out and pulseOrThreshold to return out_aligned.
% if input pulseOrThreshold is a 
    if nargin < 3
        safetyMargin = 20; %safetymargin as to not cut of any data.
    end
if length(pulseOrThreshold) > 1
    
    [xcor, lags] = xcorr(out,pulseOrThreshold);
    xcor = xcor/ max(xcor);
    [~, maxCorrIndex] = max(xcor);
    delay = lags(maxCorrIndex);
    
    sample_number = delay+ length(pulseOrThreshold)-safetyMargin;
    out_aligned = out(sample_number:end);
    
%     figure; 
%     subplot(4,1,1);plot(xcor(length(xcor)/2:end));
%     subplot(4,1,2);plot(out);
%     subplot(4,1,3);plot(out_aligned); 
%     subplot(4,1,4);plot(pulseOrThreshold); 
else
    sample_number = find(out> pulseOrThreshold,1)+ IRtime - safetyMargin;
    out_aligned = out(find(out> pulseOrThreshold,1)+ IRtime - safetyMargin:end);
    
end
