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
filter = getKernel(f1, f1_Monet);

% Predict Fourier representation of image 2
outf = predictFourier(filter, f2_Monet); 

% Get the spatial domain representation 
out = getSpatialRep(outf);

% display prediction
figure()
imshow(out/255)
title('out')
% save it
imwrite(out/255, "out/out.jpg")

% display median-filtered version
med = getMedianFiltered(out, [5, 5]); 
figure()
imshow(med/255)
title('With median filtering')

%display what we wanted to see
figure()
imshow(Image2)
title('expected')

function F = fft3(I)
% I: RGB image 
% Returns F, the Fourier representation of each of the 3 channels of I 
    F = zeros(size(I));
    F(:,:,1) = fft2(I(:,:,1));
    F(:,:,2) = fft2(I(:,:,2));
    F(:,:,3) = fft2(I(:,:,3));
end

function kernel = getKernel(photo, drawing)
% kernel, photo & drawing are in the Fourier domain 
% Returns the Fourier representation of the kernel of the convolution
% that transforms the photo into a drawing
    kernel = zeros(size(photo));
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

function I = getSpatialRep(F)
% F: RGB image in the Fourier domain
% Returns I, the corresponding image in the spatial domain
    I = zeros(size(F));
    I(:,:,1) = ifft2(F(:,:,1));
    I(:,:,2) = ifft2(F(:,:,2));
    I(:,:,3) = ifft2(F(:,:,3));
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


