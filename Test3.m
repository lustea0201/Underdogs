clear all 
close all 

left_band = 7; top_band = 70; band1_w = 52; band1_h = 28; width = 300; height = 200;

I = imread("src/index.jpg");
Image1 = imcrop(I, [left_band,top_band ,width,height]);
Image1_Monet = imcrop(I, [left_band+band1_w + width,top_band,width,height]);
Image2 = imcrop(I, [left_band,top_band + band1_h + height,width,height]);
Image2_Monet = imcrop(I, [left_band+band1_w + width,top_band + band1_h + height,width,height]);


% figure(), imshow(I), title('I');
% figure(), imshow(Image1), title('Image1'); 
% figure(), imshow(Image1_Monet), title('Image1_Monet'); 
% figure(), imshow(Image2), title('Image2'); 
% figure(), imshow(Image2_Monet),title('Image2_Monet'); 


f1 = fft3(Image1);
f1_Monet = fft3(Image1_Monet);
f2_Monet = fft3(Image2_Monet);

filter = zeros(size(f1));
filter(:,:,1) = f1_Monet(:,:,1)./f1(:,:,1); 
filter(:,:,2) = f1_Monet(:,:,2)./f1(:,:,2);
filter(:,:,3) = f1_Monet(:,:,3)./f1(:,:,3);

outf = zeros(size(filter));
outf(:,:,1) = f2_Monet(:,:,1)./filter(:,:,1);
outf(:,:,2) = f2_Monet(:,:,2)./filter(:,:,2);
outf(:,:,3) = f2_Monet(:,:,3)./filter(:,:,3);

out = zeros(size(filter));
out(:,:,1) = ifft2(outf(:,:,1));
out(:,:,2) = ifft2(outf(:,:,2));
out(:,:,3) = ifft2(outf(:,:,3));



figure()
imshow(out/255)
title('out')


i = zeros(201,301,3);
neigh = [5,5];
i(:,:,1) = medfilt2(out(:,:,1), neigh); 
i(:,:,2) = medfilt2(out(:,:,2), neigh); 
i(:,:,3) = medfilt2(out(:,:,3), neigh); 
figure()
imshow(i/255)
title('With median filtering')


figure()
imshow(Image2)
title('expected')

function f = fft3(I)
    f = zeros(size(I));
    f(:,:,1) = fft2(I(:,:,1));
    f(:,:,2) = fft2(I(:,:,2));
    f(:,:,3) = fft2(I(:,:,3));
end

