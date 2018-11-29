
% convert a not-too-big image into a mask. These images should
% have the same width and height
imOne = mask_image('templeSR0007.png');
imTwo = mask_image('templeSR0002.png');
% this will display the masks.
figure, imshow(imOne);
figure, imshow(imTwo);

% combine the two masks to create a 3-D point cloud.
% X, Y, and Z hold the coordinates themselves, while
% pointCloud is the actual grid.
[X, Y, Z, pointCloud] = combine(imOne, imTwo);

% 3D reconstruction of point cloud
scatter3(X, Y, Z);

% This matlab method will give us a 3-D polygon that
% acts sort of like a convex hull, bounding most of
% the point cloud points.
shp = alphaShape(X',Y',Z');
shp.RegionThreshold = 2;
shp.Alpha = 2.5;
plot(shp)

% Creates a mask of the image
function mask = mask_image(filename)
    gray = rgb2gray(im2double(imread(filename)));
    
    % The temple fileset is rotated.
    gray = imrotate(gray, 90);
    [m n] = size(gray);
    for i=1:m
        for j=1:n
            if(gray(i,j) < 0.2)
                gray(i,j) = 0;
            else
                gray(i,j) = 1;
            end
        end
    end
    mask = gray;
end

% Combines the two masks into a 3D point cloud. 
% We create a 3-D cube, and then "remove" the parts of it 
% that are not part of the mask. im1 handles the (x,y) plane
% and im2 handles the (y,z) plane. This means that 
% the cameras currently have to be perpendicular.
function [X, Y, Z, pointCloud] = combine(im1, im2)
    [m1 n1] = size(im1);
    [m2 n2] = size(im2);
    pointCloud = ones(m1, n1, n2);
    counter = 1;
    for i = 1:m1
        for j = 1:n1
            for s=1:n2 
                % "remove" the parts that aren't in
                % a mask.
                if(im1(i,j) == 0 || im2(i,s) == 0)
                    pointCloud(i,j,s) = 0;
                    
                end
            end
        end
    end
    
    % accumulate values into the point cloud
    for i = 1:m1
        for j = 1:n1
            for s=1:n2
                if(pointCloud(i,j,s) == 1)
                    % We flip the height values.
                    Z(counter) = m1 - i;
                    X(counter) = j;
                    Y(counter) = s;
                    counter = counter + 1;   
                end
            end
        end
    end
    
    % This is just for the purposes of displaying the
    % point cloud using surface(). It expands the grid
    % large enough so that we can see our cloud.
    X(counter) = 0;
    Y(counter) = 0;
    Z(counter) = 0;
    counter = counter + 1;
    X(counter) = 100;
    Y(counter) = 100;
    Z(counter) = 100;
    counter = counter + 1;    
end
