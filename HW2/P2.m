clear all 
close all 

SIZE = [1024,1024]; % Defining the size of the images
N_images = 5; % The number of images created for each movie
if exist('out', 'dir')
    rmdir out s % Remove all previous files if there are some
end

% N_particles = [32, 128, 256, 512]; % The number of particles in the
% videos
% max_speed = [4, 8, 32]; % The maximum number of pixels (radial distance)
% a particle can move in 1 frame
% SNratio = [20, 5, 2]; % Signal to noise ratio in the video 
N_particles = [128];
max_speed = [32];
SNratio = [20];


total = size(N_particles, 2)*size(max_speed, 2)*size(SNratio, 2)*N_images;
% Number of images to generate & save. Used to estimate the advancement of
% generation. 

cmap = gray(256); % The color map used to make video frames from images. 

N_expansions = 20; % The number of expansions from map to image. 

for n = 1:size(N_particles, 2) % Looping over the possible numbers of particles
    for s = 1:size(max_speed, 2) % Looping over the possible speeds
        for r = 1:size(SNratio, 2) % Looping over the possible SN ratios
            
            [MAP, current_positions] = initializeMap(SIZE, N_particles(n)); %Initialize the map and the list of the positions of the particles. 
            
            I = map2im(MAP, N_expansions); % Create an image from this map. 

            % Create the paths for the output. 
            out_directory = strcat('out/', num2str(N_particles(n)), 'particles/', num2str(max_speed(s)), 'pixels_frame/', num2str(SNratio(r)), '_1SN/');
            images_directory = strcat(out_directory,'images/');
            positions_directory = strcat(out_directory,'positions/');
            
            % Create the directories corresponding to these paths. 
            mkdir(out_directory)
            mkdir(images_directory)
            mkdir(positions_directory)
            
            % Initialize the writer object: this is where the images will
            % be assembled to from a video.
            writerObj = VideoWriter(strcat(out_directory, 'Video.avi'));
            writerObj.FrameRate = 10;
            open(writerObj);
            
            % Save the first image. 
            imwrite(I, strcat(images_directory, 'Image1.jpg'));
            
            % Open the first saved image and its associated color map. 
            I = imread(strcat(images_directory, 'Image1.jpg'));
            
            % Convert the image to a frame and add it to the video
            frame = im2frame(I, cmap);
            writeVideo(writerObj, frame);
            
            % Save the current positions of the particles in a csv file.
            csvwrite(strcat(positions_directory, 'positions1.csv'), current_positions');


            for f = 2:N_images
                % Determine the number of images generated so far.
                gen = (n-1)*size(max_speed, 2)*size(SNratio, 2)*N_images + (s-1)*size(SNratio, 2)*N_images + (r-1)*N_images + f;
                
                % Determine the percentage of the total number to generate.
                percentage_done = (100*gen/total);
                
                % Display that percentage if it's an integer. 
                if (mod(percentage_done, 1) == 0)
                    disp(percentage_done+ "% done")
                end
                
                % Update the map and current positions after moving all
                % particles. 
                [MAP, current_positions] = move(SIZE, current_positions, max_speed(s)); 
                
                % Update the corresponding image
                I = map2im(MAP, N_expansions); 
                
                % Save the image with its frame number. 
                filename = strcat(images_directory, 'Image', num2str(f), '.jpg');
                imwrite(I, filename)
                
                % Load the last image and add the corresponding frame to
                % the video. 
                I = imread(filename);
                frame = im2frame(I, cmap);
                writeVideo(writerObj, frame);
                
                % Save the particle positions to a csv file for this frame.
                csvwrite(strcat(positions_directory, 'positions', num2str(f),'.csv'), current_positions')
            end
            % Close the writer object to finish the video.
            close(writerObj);
        end
    end
end


function [M, positions] = initializeMap(SIZE, N)
% Creates a map of size SIZE filled with N particles. 
% Conventions: 
% - 255 means no particle, 0 means there is a particle at the given pixel. 
% - position: starts top left, first axis (x) goes down and second (y) goes right 

    M = 255*ones(SIZE); % Initializing to an empty map. 
    positions = zeros(2, N); % Initializing the positions of the particles.
    
    % Handling incorrect input to the function: 
    % N null nor negative:
    if (N < 1)
        error("We want at least one particle.")
    end
    % N too large
    if (N > SIZE(1)*SIZE(2))
        error("More particles than pixels in the map.")
    end
    
    % Get random coordinates for the first particle
    [x, y] = getRandomXY(SIZE);
    
    % Save that position to the list of postitions
    positions(1,1) = x;
    positions(2,1) = y;

    
    for i = 2:N % Loop over the remaining N-1 particles to create.
        [x, y] = getRandomXY(SIZE); % Obtain a random position.
        while alreadyExists(positions,x,y) % Repeat obtention process until 
            % you find a new position not in the list.
            
            % If there is already a point there, find another position
            [x, y] = getRandomXY(SIZE);
        end
        positions(1:2, i) = [x,y]; % Add the new position to the list. 
        
    end
    
    % Now set the map to 0 where there is a particle.
    for i = 1:N
        M(positions(1,i), positions(2,i)) = 0;
    end
end

function [x, y] = getRandomXY(SIZE)
% Returns a random position in a grid of size SIZE. 
    x = randi([1, SIZE(1)], 1, 1);
    y = randi([1, SIZE(2)], 1, 1);
end



function b = alreadyExists(positions, x,y)
% Determines whether the list of positions already contains the tuple [x;y]
    b = false;
    for i = 1:size(positions, 2)
        if (positions(:,i) == [x;y])
            b = true;
        end
    end
end

function I = expandPoints(M)
% Extend the 0 values to the left, right, bottom and up (where possible). 

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
% Takes a precise map of particle position, M, and converts it into a
% blurred image I by "expanding" it k times. See expandPoints to understand
% the expansion process. 

I = M;
for i = 1:k
    I = expandPoints(I);
end
I = imnoise(I, 'gaussian'); % Add gaussian noise to the resulting image. 
end

function [M2, new] = move(SIZE, positions, speed)
% Return the updated map and list of positions after the particles have
% moved.

new = positions;
for i = 1:size(positions,2)
    r = randi([0, speed], 1, 1); % The moving distance is at most speed.
    theta = 2*pi*randn(1,1); % The direction is random.
    
    % Assign the new positions, making sure they are within the possible
    % range, i.e. the map size. 
    new(1,i) = max(min(new(1,i) + floor(r*cos(theta)), SIZE(1)), 1);
    new(2,i) = max(min(new(2,i) + floor(r*sin(theta)), SIZE(2)), 1);
end

M2 = 255*ones(SIZE); % Initialize the new empty map. 

% Add the particles with their new positions. 
for i = 1:size(new, 2)
    M2(new(1,i), new(2,i)) = 0;
end

end
