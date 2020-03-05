clear all 
close all 

% Creating an empty 1024x1024 image
SIZE = [102,102];
N_images = 100;
if exist('out', 'dir')
    rmdir out s % remove all previous files
end
N_particles = [32, 128, 256, 512];
max_speed = [4, 8, 32];
SNratio = [20, 5, 2];
total = size(N_particles, 2)*size(max_speed, 2)*size(SNratio, 2)*N_images;
% Number of images to generate & save

for n = 1:size(N_particles, 2)
    for s = 1:size(max_speed, 2)
        for r = 1:size(SNratio, 2)
            [MAP, current_positions] = initializeMap(SIZE, N_particles(n));
            I = map2im(MAP, 20); 

            out_directory = strcat('out/', num2str(N_particles(n)), 'particles/', num2str(max_speed(s)), 'pixels_frame/', num2str(SNratio(r)), '_1SN/');
            images_directory = strcat(out_directory,'images/');
            positions_directory = strcat(out_directory,'positions/');
            mkdir(out_directory)
            mkdir(images_directory)
            mkdir(positions_directory)
            

            writerObj = VideoWriter(strcat(out_directory, 'Video.avi'));
            writerObj.FrameRate = 10;
            open(writerObj);
            imwrite(I, strcat(images_directory, 'Image1.jpg'));
            [I, map ] = imread(strcat(images_directory, 'Image1.jpg'));

            frame = im2frame(I, gray(256));
            writeVideo(writerObj, frame);
            csvwrite(strcat(positions_directory, 'positions1.csv'), current_positions')


            for f = 2:N_images
                current = (n-1)*size(max_speed, 2)*size(SNratio, 2)*N_images + (s-1)*size(SNratio, 2)*N_images + (r-1)*N_images + f;
                percentage_done = (100*current/total);
                if (mod(percentage_done, 1) == 0)
                    disp(percentage_done+ "% done")
                end
                [MAP, current_positions] = move(SIZE, current_positions, max_speed(s)); 
                I = map2im(MAP, 20); 
                filename = strcat(images_directory, 'Image', num2str(f), '.jpg');
                imwrite(I, filename)
                [I, map ] = imread(filename);
                frame = im2frame(I, gray(256));
                writeVideo(writerObj, frame);
                csvwrite(strcat(positions_directory, 'positions', num2str(f),'.csv'), current_positions')
            end


            close(writerObj);
        end
    end
end


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
    new(1,i) = max(min(new(1,i) + floor(r*cos(theta)), SIZE(1)), 1);
    new(2,i) = max(min(new(2,i) + floor(r*sin(theta)), SIZE(2)), 1);
end
M2 = 255*ones(SIZE);
for i = 1:size(new, 2)
    M2(new(1,i), new(2,i)) = 0;
end

end
