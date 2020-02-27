clear all 
close all 

photo1 = imread("src/photo1.jpg");
painting1 = imread("src/monet1.jpg");
photo2 = imread("src/photo2.jpg");
painting2 = imread("src/monet2.jpg");
photo3 = imread("src/photo3.jpg");
painting3 = imread("src/monet3.jpg");
photo4 = imread("src/photo4.jpg");
painting4 = imread("src/monet4.jpg");

FOURIER_SIZE = [2048 2048];

% figure(), imshow(I), title('I');
% figure(), imshow(Image1), title('Image1'); 
% figure(), imshow(painting1), title('painting1'); 
% figure(), imshow(Image2), title('Image2'); 
% figure(), imshow(painting2),title('painting2'); 

% Get the FFT of the images (not centered)
f1 = fft3(photo1, FOURIER_SIZE);
f1_Monet = fft3(painting1, FOURIER_SIZE);
f2_Monet = fft3(painting2, FOURIER_SIZE);
% figure(), imshow(fftshift(f1)), title('Fourier1'); 
% figure(), imshow(fftshift(f1_Monet)), title('Monet 1 '); 
% figure(), imshow(fftshift(f2_Monet)),title('Monet 2'); 


% Obtain the filters
filter1 = getKernel(f1, f1_Monet, FOURIER_SIZE);
filter2 = getKernel(f2, f2_Monet, FOURIER_SIZE);
filter3 = getKernel(f3, f3_Monet, FOURIER_SIZE);
filteravg = (filter1 + filter2 + filter3)./3


% Predict Fourier representation of image 4
outf1 = predictFourier(filter1, f4_Monet); 
outf2 = predictFourier(filter2, f4_Monet); 
outf3 = predictFourier(filter3, f4_Monet); 
outavg = predictFourier(filteravg, f4_Monet); 

% Get the spatial domain representation 
out1 = getSpatialRep(outf1, size(painting4));
out2 = getSpatialRep(outf2, size(painting4));
out3 = getSpatialRep(outf3, size(painting4));
outavg = getSpatialRep(outavg, size(painting4));

% display prediction
figure()
imshow(out1/255)
title('out1')
figure()
imshow(out2/255)
title('out2')
figure()
imshow(out3/255)
title('out3')
figure()
imshow(outavg/255)
title('out3')




% save it
% imwrite(out/255, "out/out.jpg")

% display median-filtered version
% med = getMedianFiltered(out, [5, 5]); 
% figure()
% imshow(med/255)
% title('With median filtering')

%display what we wanted to see
figure()
imshow(photo2)
title('expected')

function F = fft3(I, FOURIER_SIZE)
% I: RGB image 
% Returns F, the Fourier representation of each of the 3 channels of I 
    F = zeros(FOURIER_SIZE);
    F(:,:,1) = fft2(I(:,:,1), FOURIER_SIZE(1), FOURIER_SIZE(2));
    F(:,:,2) = fft2(I(:,:,2), FOURIER_SIZE(1), FOURIER_SIZE(2));
    F(:,:,3) = fft2(I(:,:,3), FOURIER_SIZE(1), FOURIER_SIZE(2));
end

function kernel = getKernel(photo, drawing, FOURIER_SIZE)
% kernel, photo & drawing are in the Fourier domain 
% Returns the Fourier representation of the kernel of the convolution
% that transforms the photo into a drawing
    kernel = zeros(FOURIER_SIZE);
    kernel(:,:,1) = drawing(:,:,1)./photo(:,:,1); 
    kernel(:,:,2) = drawing(:,:,2)./photo(:,:,2);
    kernel(:,:,3) = drawing(:,:,3)./photo(:,:,3);
end

function photo = predictFourier(kernel, drawing)
% photo, kernel & drawing are in the Fourier domain
% Returns the Fourier representation of the predicted photo 
% obtained by deconvolving a drawing with the kernel 
    photo = zeros(size(kernel));
    photo(:,:,1) = drawing(:,:,1)./kernel(:,:,1);
    photo(:,:,2) = drawing(:,:,2)./kernel(:,:,2);
    photo(:,:,3) = drawing(:,:,3)./kernel(:,:,3);
end

function If = getSpatialRep(F, s)
% F: RGB image in the Fourier domain
% Returns I, the corresponding image in the spatial domain

    height = s(1); width = s(2)
    I = zeros(size(F));
    I(:,:,1) = ifft2(F(:,:,1));
    I(:,:,2) = ifft2(F(:,:,2));
    I(:,:,3) = ifft2(F(:,:,3));
    If = I(1:height, 1:width, : )
end

function MFI = getMedianFiltered(I, neighborhood)
% I: RGB image to be filtered
% neighborhood: size of the square neighborhood used in the median filter, 
% a 2-dimensional array
% Returns MFI, the median-filtered version of I 
    MFI = zeros(size(I));
    MFI(:,:,1) = medfilt2(I(:,:,1), neighborhood); 
    MFI(:,:,2) = medfilt2(I(:,:,2), neighborhood); 
    MFI(:,:,3) = medfilt2(I(:,:,3), neighborhood); 
end