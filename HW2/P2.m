clear all 
close all 

% Creating an empty 1024x1024 image
SIZE = [10, 10];
I = initializeImage(SIZE, 3);
imshow(I)

N_particles = 1; 
max_speed = 1; 
SN_ratio = 1; 

function I = initializeImage(size, N)
% image: the image to which we want to add particles 
    I = 255*ones(size);
    positions = randi([1, size(1)], 2, N)
    % starts top left, first axis goes down and second goes left 
    for i = 1:N
        I(positions(1,i), positions(2,i)) = 0;
    end
end