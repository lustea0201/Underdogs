clear all 
close all 

% Creating an empty 1024x1024 image
SIZE = [1024, 1024];
N_particles = 32; 
max_speed = 32; 
N_images = 10;
SNratio = 100;

[MAP, current_positions] = initializeMap(SIZE, N_particles);
I = map2im(MAP, 20); 

out_directory = strcat('out/', num2str(N_particles), 'particles/', num2str(max_speed), 'pixels_frame/', num2str(SNratio), '_1SN/');
images_directory = strcat(out_directory,'/images')
if ~exist(out_directory, 'dir')
    mkdir(out_directory)
end

if ~exist(images_directory, 'dir')
    mkdir(images_directory)
end



writerObj = VideoWriter(strcat(out_directory, '/Video.avi'));
writerObj.FrameRate = 10;
open(writerObj);

imwrite(I, strcat(images_directory, '/Image1.jpg'));
[I, map ] = imread(strcat(images_directory, '/Image1.jpg'));

frame = im2frame(I, gray(256))
writeVideo(writerObj, frame);

for frame = 2:N_images
    disp((100*frame/N_images)+ "% done")
    [MAP, current_positions] = move(SIZE, current_positions, max_speed); 
    I = map2im(MAP, 20); 
    filename = strcat(images_directory, '/Image', num2str(frame), '.jpg');
    imwrite(I, filename)
    [I, map ] = imread(filename);
    frame = im2frame(I, gray(256));
    writeVideo(writerObj, frame);
end


close(writerObj);



function [M, positions] = initializeMap(SIZE, N)
% image: the image to which we want to add particles 
    M = 255*ones(SIZE);
    if (N < 1)
        error("We want at least one particle.")
    end
    [x, y] = getRandomXY(SIZE);
    positions(1,1) = x;
    positions(2,1) = y;
    for i = 2:N
        [x, y] = getRandomXY(SIZE);
        while alreadyExists(positions,x,y)
            % If there is already a point there, find another position
            [x, y] = getRandomXY(SIZE);
        end
        positions(1:2, end+1) = [x,y];
        % starts top left, first axis (x) goes down and second (y) goes right 
    end
    for i = 1:size(positions, 2)
        M(positions(1,i), positions(2,i)) = 0;
    end
end

function [x, y] = getRandomXY(SIZE)
    x = randi([1, SIZE(1)], 1, 1);
    y = randi([1, SIZE(2)], 1, 1);
end



function b = alreadyExists(positions, x,y)
    b = false;
    for i = 1:size(positions, 2)
        if (positions(:,i) == [x;y])
            b = true;
        end
    end
end

function I = expandPoints(M)
I = M;
for i = 1:size(M,1)
    for j = 1:size(M,2)
        if (M(i,j) == 0)
            if (j < size(M,2))
                I(i,j+1) = 0; 
            end
            if (j>1)
                I(i,j-1) = 0; 
            end
            if (i<size(M,1))
                I(i+1,j) = 0; 
            end
            if (i>1)
                I(i-1,j) = 0;
            end
        end
    end
end
end

function I = map2im(M, k)
I = M;
for i = 1:k
    I = expandPoints(I);
end
end

function [M2, new] = move(SIZE, positions, speed)
new = positions;
for i = 1:size(positions,2)
    r = randi([0, speed], 1, 1);
    theta = 2*pi*randn(1,1);
    new(1,i) = max(min(new(1,i) + floor(r*cos(theta)), 1024), 1);
    new(2,i) = max(min(new(2,i) + floor(r*sin(theta)), 1024), 1);
end
M2 = 255*ones(SIZE);
for i = 1:size(new, 2)
    M2(new(1,i), new(2,i)) = 0;
end

end
