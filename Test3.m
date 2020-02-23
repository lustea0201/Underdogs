clear all 
close all 


Image1 = imread("src/photo1.jpg");
Image1_Monet = imread("src/monet1.jpg");
Image2 = imread("src/photo2.jpg");
Image2_Monet = imread("src/monet2.jpg");


% figure(), imshow(I), title('I');
% figure(), imshow(Image1), title('Image1'); 
% figure(), imshow(Image1_Monet), title('Image1_Monet'); 
% figure(), imshow(Image2), title('Image2'); 
% figure(), imshow(Image2_Monet),title('Image2_Monet'); 

% Get the FFT of the images (not centered)
f1 = fft3(Image1);
f1_Monet = fft3(Image1_Monet);
f2_Monet = fft3(Image2_Monet);

% Obtain the filter
filter = zeros(size(f1));
filter(:,:,1) = f1_Monet(:,:,1)./f1(:,:,1); 
filter(:,:,2) = f1_Monet(:,:,2)./f1(:,:,2);
filter(:,:,3) = f1_Monet(:,:,3)./f1(:,:,3);

% Predict the real image from painting 2
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
imwrite(out/255, "out/out.jpg")


med = zeros(size(out));
neigh = [5,5];
med(:,:,1) = medfilt2(out(:,:,1), neigh); 
med(:,:,2) = medfilt2(out(:,:,2), neigh); 
med(:,:,3) = medfilt2(out(:,:,3), neigh); 
figure()
imshow(med/255)
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

