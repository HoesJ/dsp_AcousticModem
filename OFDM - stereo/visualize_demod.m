function visualize_demod(rxBitStream, H, refreshRate, Ld, N, M, pixPerPacket)
    [originalBitStream, imageData, colorMap, imageSize, bitsPerPixel] = imagetobitstream('image.bmp');
    
    if nargin < 7    
        pixPerPacket = Ld*log2(M)*(N/2-1);
    end
    
    figure;
    for i = 1:size(H,2)
        subplot(2,2,1); plot(abs(ifft(H(:,i))));
        subplot(2,2,2); colormap(colorMap); image(imageData); axis image; title('Original image'); drawnow;
        subplot(2,2,3); plot(abs(H(:,i)));
        if (i*pixPerPacket > length(rxBitStream))
            break
        end
        rximage = bitstreamtoimage(rxBitStream(1:i*pixPerPacket), imageSize, bitsPerPixel);
        subplot(2,2,4); image(rximage);
       
        pause(refreshRate);
    end
end

