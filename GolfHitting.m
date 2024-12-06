clear all
close all
% {'FaceTime HD Camera (Built-in)'}
% {'USB Camera' }
delete(instrfind({'Port'}, {'COM3'}));
% Release all opened serial port objects
if ~isempty(instrfind)
    fclose(instrfind);
    delete(instrfind);
end
clear('cam'); % Clear the cam object to make a new one
cam = webcam('NexiGo N60 FHD Webcam'); % Open the camera
p1 = serial('COM3', 'BaudRate', 115200);
fopen(p1);           % Open the serial port
pause(2);           % Wait 2 seconds to ensure the connection is established

% Define stability detection parameters
stable_threshold = 0.5; % Stability threshold (in pixels)
stable_frames = 10; % Number of stable frames
centroid_history = []; % Record history of centroids

% Target coordinates
xgoal = 0.337; % Target x-coordinate (in meters)
ygoal = -0.09; % Target y-coordinate (in meters)
xcon = xgoal * 10;
ycon = ygoal * 10;

while true
    RGB = snapshot(cam); % Capture one frame
    I = rgb2hsv(RGB); % Convert to HSV color space

    % Threshold segmentation
    channel1Min = 0.0;
    channel1Max = 1.0;
    channel2Min = 0.0;
    channel2Max = 0.2;
    channel3Min = 0.8;
    channel3Max = 1.0;

    sliderBW = ((I(:, :, 1) >= channel1Min) | (I(:, :, 1) <= channel1Max)) & ...
               (I(:, :, 2) >= channel2Min) & (I(:, :, 2) <= channel2Max) & ...
               (I(:, :, 3) >= channel3Min) & (I(:, :, 3) <= channel3Max);

    CC = bwconncomp(sliderBW); % Find connected regions
    s = regionprops(CC, 'Centroid', 'Area');
    centroids = cat(1, s.Centroid); % Get centroids
    areas = cat(1, s.Area);

    if isempty(areas)
        disp('No target detected!');
        continue;
    end

    % Find the largest connected region
    [~, ind] = max(areas);
    current_centroid = centroids(ind, :);

    % Convert pixel coordinates to real-world coordinates
    x_ball = (716 - current_centroid(2)) * 0.16 / 300; % Ball's x-coordinate (in meters)
    y_ball = (935 - current_centroid(1)) * 0.15 / 280; % Ball's y-coordinate (in meters)

    % Save centroid history
    centroid_history = [centroid_history; current_centroid];
    if size(centroid_history, 1) > stable_frames
        centroid_history(1, :) = []; % Keep history length consistent
    end

    % Check if stable
    if size(centroid_history, 1) == stable_frames
        diffs = vecnorm(diff(centroid_history), 2, 2); % Compute centroid changes
        if all(diffs < stable_threshold)
            % Compute direction vector
            direction = [xgoal - x_ball, ygoal - y_ball]; % Direction vector from ball to target
            direction = direction / norm(direction); % Normalize the direction vector
            fprintf('Vector: x = %f, y = %f\n', direction(1), direction(2));
            fprintf('Ball coordinates: x = %f, y = %f\n', x_ball, y_ball);

            % Calculate position 2 cm behind the ball
            x_back = (x_ball - 0.04 * direction(1)) * 100;
            y_back = (y_ball - 0.04 * direction(2)) * 100;
            theta_back = round(inverse_kin_3DOF(x_back, y_back, 3));
            fprintf('Back position: x = %f, y = %f\n', x_back, y_back);
            dataToSend = sprintf('%d,%d,%d,%d\n', theta_back(1), theta_back(2), theta_back(3), 0);
            fprintf(p1, dataToSend);
            pause(5); 

            theta_back = round(inverse_kin_3DOF(x_back, y_back, -1));
            fprintf('Back position (2 cm): x = %f, y = %f\n', x_back, y_back);
            dataToSend = sprintf('%d,%d,%d,%d\n', theta_back(1), theta_back(2), theta_back(3), 0);
            fprintf(p1, dataToSend);

            pause(5); 

            % Calculate position 5 cm forward
            x_forward = (x_ball + 0.03 * direction(1)) * 100;   
            y_forward = (y_ball + 0.04 * direction(2)) * 100;
            theta_forward = round(inverse_kin_3DOF(x_forward, y_forward, -1));
            fprintf('Forward position (5 cm): x = %f, y = %f\n', x_forward, y_forward);
            dataToSend = sprintf('%d,%d,%d,%d\n', theta_forward(1), theta_forward(2), theta_forward(3), 0);
            fprintf(p1, dataToSend);
            pause(5); 

            theta_forward = round(inverse_kin_3DOF(x_forward, y_forward, 3));
            fprintf('Forward position (up): x = %f, y = %f\n', x_forward, y_forward);
            dataToSend = sprintf('%d,%d,%d,%d\n', theta_forward(1), theta_forward(2), theta_forward(3), 0);
            fprintf(p1, dataToSend);

            pause(5); 
            centroid_history = []; % Clear history for new detection
        end
    end

    % Real-time centroid display
    if ~exist('hFig', 'var') || ~isvalid(hFig)
        hFig = figure('Name', 'Real-time Detection', ...
                      'Position', [100, 100, 800, 600], ...
                      'NumberTitle', 'off');
    end

    figure(hFig);
    imshow(double(sliderBW));
    hold on;
    plot(current_centroid(1), current_centroid(2), 'm*', 'markersize', 32);
    hold off;
end
