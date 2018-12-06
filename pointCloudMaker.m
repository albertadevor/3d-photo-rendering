
% Modify distances so that all images can work togehter
files = ['dif_dists/temple_SR0006_07m.png'; 'dif_dists/temple_SR0011_12m.png'; 'dif_dists/temple_SR0009_05m.png'];
distances = [7 12 5]; %how far away camera is from each object
furthest = max(distances);
images = cell(size(files));
masked_images = cell(size(files));
for idx=1:size(distances,2)
    im = imread(files(idx, :));
    thing = change_dist(im, distances(idx), furthest);
    images{idx} = thing;
    masked_images{idx} = mask_image(im);
end

% convert a not-too-big image into a mask. These images should
% have the same width and height

% imOne = mask_image('dinoSparseRing/dinoSR0001.png');
% imTwo = mask_image('dinoSparseRing/dinoSR0005.png');
% imThree = mask_image('dinoSparseRing/dinoSR0003.png');
% this will display the masks.

% combine the two masks to create a 3-D point cloud.
% X, Y, and Z hold the coordinates themselves, while
% pointCloud is the actual grid.
[height width] = size(masked_images{1});
% files = ['templeSR0006.png'; 'templeSR0011.png'; 'templeSR0009.png'];
%files = [ 'dinoSparseRing/dinoSR0001.png'; 'dinoSparseRing/dinoSR0005.png'; 'dinoSparseRing/dinoSR0003.png']
allIms = compileIms(images, height, width);

figure, imshow(allIms(:,:,1));
figure, imshow(allIms(:,:,2));
figure, imshow(allIms(:,:,3));
angles = [ pi/2, 0, pi/4];

[X, Y, Z, pointCloud] = combine(masked_images{1}, allIms, angles);

% 3D reconstruction of point cloud
figure, scatter3(X, Y, Z);

% This matlab method will give us a 3-D polygon that
% acts sort of like a convex hull, bounding most of
% the point cloud points.
shp = alphaShape(X',Y',Z');
shp.RegionThreshold = 1;
shp.Alpha = 1.5;
figure, plot(shp)

[triangulation, P] = alphaTriangulation(shp);
stlFile = stlwrite(triangulation, 'stlfile.stl', 'text');

function [allIms] = compileIms(file, height, width)
    numberOfImages = size(file,1);
    allIms = zeros(height, width, numberOfImages);
    for i=1:numberOfImages
        loadImageMask = mask_image(file{i});
        allIms(:,:,i) = loadImageMask;
    end
end

% Combines the two masks into a 3D point cloud. 
% We create a 3-D cube, and then "remove" the parts of it 
% that are not part of the mask. im1 handles the (x,y) plane
% and im2 handles the (y,z) plane. This means that 
% the cameras currently have to be perpendicular.
function [X, Y, Z, pointCloud] = combine(im1, masks, thetas)
    [m1 n1] = size(im1);
    [m2 n2] = size(im1);
    pointCloud = ones(m1, n1, n2);
    counter = 1;
    
    for imageNumber = 1:3
        im = masks(:,:,imageNumber);
        theta = thetas(imageNumber);

        multiplier = cos(theta) / sin(theta);
        if(multiplier < 0.1)
           multiplier = 0; 
        end
        edgeCase = 0;
        if(sin(theta) == 0)
            edgeCase = 1;
        end
        
        for i = 1:m1
            for j = 1:n1
                for s=1:n2 

                    if(edgeCase == 0)
                        if(multiplier == 0)
                            shiftBy = floor(j +  (s - 1) * multiplier);
                        else
                            shiftBy = floor(j +  (s - 1) * multiplier) - floor(n1/2);
                        end
                    else
                        shiftBy = s;
                    end

                    if((shiftBy < 1) || (shiftBy > n1) )
                         pointCloud(i,j,s) = 0;
                         continue;
                    end

                    if(im(i, shiftBy) == 0)
                       pointCloud(i, j, s) = 0;
                       continue;
                    end
                    
                end
            end
        end
    end
    % accumulate values into the point cloud
    for i = 1:m1
        for j = 1:n1
            for s=1:n2
                if(pointCloud(i,j,s) == 1)
                    % We flip the y and z values values.
                    Z(counter) = m1 - i;
                    X(counter) = j;
                    Y(counter) = n1 - s;
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
