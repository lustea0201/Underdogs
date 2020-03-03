clear all 
close all 

painter = "monet";

%Load all the necessary images of paintings and photos
photo1 = imread("src/photo1.jpg");
painting1 = imread(strcat("src/", painter, "1.jpg"));
photo2 = imread("src/photo2.jpg");
painting2 = imread(strcat("src/", painter, "2.jpg"));
photo3 = imread("src/photo3.jpg");
painting3 = imread(strcat("src/", painter, "3.jpg"));
photo4 = imread("src/photo4.jpg");
painting4 = imread(strcat("src/", painter, "4.jpg"));

to_predict = painting2; % This is the painting we want to create a photo from
expected = photo2; % Expected result

painting5 = imread("src/MONET.jpg"); % This is an extra painting from Monet that we are curious about

FOURIER_SIZE = [2048 2048]; % All operations in the Fourier domain will be done with this size 
% Caution: the program only works if all images have both dimension smaller
% than this


% Get the FFT of the images (not centered)
fphoto1 = fft3(photo1, FOURIER_SIZE);
fphoto2 = fft3(photo2, FOURIER_SIZE);
fphoto3 = fft3(photo3, FOURIER_SIZE);
fphoto4 = fft3(photo4, FOURIER_SIZE);
fpainting1 = fft3(painting1, FOURIER_SIZE);
fpainting2 = fft3(painting2, FOURIER_SIZE);
fpainting3 = fft3(painting3, FOURIER_SIZE);
fpainting4 = fft3(painting4, FOURIER_SIZE);
fpredict = fft3(to_predict, FOURIER_SIZE);
fpainting5 = fft3(painting5, FOURIER_SIZE);

% Obtain the filters
filter1 = getKernel(fphoto1, fpainting1, FOURIER_SIZE); 
filter3 = getKernel(fphoto3, fpainting3, FOURIER_SIZE);
filter4 = getKernel(fphoto4, fpainting4, FOURIER_SIZE);

% We want to take the average of those 4 filters to get a filter more
% representative of Monet's painting style
filteravg = (filter1+ filter3 + filter4)./3; 

% Predict Fourier representation of the paintings
fout4 = predictFourier(filteravg, fpredict); 
fout5 = predictFourier(filteravg, fpainting5); 

% Get the spatial domain representation 
out4 = getSpatialRep(fout4, size(to_predict));
out5 = getSpatialRep(fout5, size(painting5));

% Filter the output predictions
filtered4 = applyGaussianFilter(out4, 1.5); 
filtered5 = applyGaussianFilter(out5, 1.5); 

% Convert the images to uint8 (integers from 0 to 255)
out4 = uint8(out4); out5 = uint8(out5); 
filtered4 = uint8(filtered4); filtered5 = uint8(filtered5); 

% Save the images in the folder named "out" in jpg format 
imwrite(filtered4, "out/filtered4.jpg")
imwrite(out4, "out/raw4.jpg")
imwrite(out5, "out/raw5.jpg")

imwrite(filtered5, "out/filtered5.jpg")


% Display a comparison of the original painting, ground truth picture and
% predicted picture
figure('position', [200, 400, 1200, 300]) 
subplot(1,4,1), imshow(to_predict), title("Painting")
subplot(1,4,2), imshow(out4), title("Predicted photo (raw)")
subplot(1,4,3), imshow(filtered4), title("Predicted photo (processed)")
subplot(1,4,4), imshow(expected), title("Expected photo")

figure('position', [400, 0, 1200, 300]), imshow(painting5), title("Painting")
figure('position', [800, 0, 1200, 300]), imshow(filtered5), title("Predicted photo (processed)")


function F = fft3(I, FOURIER_SIZE)
% I: RGB image 
% Returns F, the Fourier representation of each of the 3 channels of I 
% In size given by FOURIER_SIZE
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
% Caution: s must be smaller than FOURIER_SIZE along both dimensions
    height = s(1); width = s(2);
    I = zeros(size(F));
    I(:,:,1) = ifft2(F(:,:,1));
    I(:,:,2) = ifft2(F(:,:,2));
    I(:,:,3) = ifft2(F(:,:,3));
    If = I(1:height, 1:width, : );
end

function GFI = applyGaussianFilter(I, sigma)
% I: RGB image to be filtered
% neighborhood: size of the square neighborhood used in the median filter, 
% a 2-dimensional array
% Returns MFI, the median-filtered version of I 
    GFI = zeros(size(I));
    GFI(:,:,1) = imgaussfilt(I(:,:,1), sigma); 
    GFI(:,:,2) = imgaussfilt(I(:,:,2), sigma); 
    GFI(:,:,3) = imgaussfilt(I(:,:,3), sigma); 
end