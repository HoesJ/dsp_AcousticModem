function visualize_demod(qamSig, H, refreshRate, Ld, N, qamOrder)
    
    
    [~, imageData, colorMap, imageSize, bitsPerPixel] = imagetobitstream('image.bmp');
    rxBitStream = qam_demod(qamSig,qamOrder);
%     Ld*(N/2-1)*log1;
    sizeRx =size(rxBitStream);
    zerostream = zeros(1, sizeRx(2));
    sizeH = size(H);
    
    for i = 1:sizeH(2)
        
        subplot(2,2,1); plot(abs(ifft(H(:,i))));
        subplot(2,2,2); colormap(colorMap); image(imageData); axis image; title('Original image'); drawnow;
        subplot(2,2,3); plot(abs(H(:,i)));
        
        subplot(2,2,4); plot(bitstreamtoimage(zerostream + rxBitStream(1:i*Ld*(N/2-1)), imageSize, bitsPerPixel));
       
        pause(refreshRate);
    end
end

