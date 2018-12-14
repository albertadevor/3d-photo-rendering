
% Modify distances so that all images can work togehter
% files = ['dif_dists/temple_SR0006_07m.png'; 'dif_dists/temple_SR0011_12m.png'; 'dif_dists/temple_SR0009_05m.png'];
% files = ['templeSR0006.png'; 'templeSR0011.png'; 'templeSR0009.png'];
% distances = [7 12 5]; %how far away camera is from each object
% angles = [ pi/2, 0, pi/4];
read = csvread('ARTags/webcam_ar_track/scripts/extracted_frames/extracted_data.csv');

% angles = wrapTo2Pi(deg2rad(read(1:end,2)));
angles = (pi *read(1:end,2) / 180) + pi;
distances = read(1:end,3);
picture_numbers = read(1:end,1);
files = cell(size(angles,1), 1);
for i=1:size(picture_numbers)
    real_num = picture_numbers(i); %offset for duck data
    extra_text = '';
    if(real_num < 10)
        extra_text = '00';
    elseif(real_num < 100)
        extra_text = '0';
    end
    text = strcat('ARTags/webcam_ar_track/scripts/extracted_frames/frame00', extra_text, num2str(real_num), '.png');
    files{i} = text;
end
files = cell2mat(files);


furthest = max(distances);
images = cell(size(files, 1));
masked_images = cell(size(files,1), 1);
for idx=1:size(distances,1)
    im = imread(files(idx, :));
    
%     images{idx} = change_dist(im, distances(idx), furthest);
    images{idx} = im;
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
% allIms = compileIms(images, height, width);

% allIms(:,:,1);
% allIms(:,:,2));
% figure, imshow(allIms(:,:,3));


[X, Y, Z, pointCloud] = combine(masked_images{1}, masked_images, angles');

% 3D reconstruction of point cloud
figure, scatter3(X, Y, Z);

% This matlab method will give us a 3-D polygon that
% acts sort of like a convex hull, bounding most of
% the point cloud points.
shp = alphaShape(X',Y',Z');
shp.RegionThreshold = 1;
shp.Alpha = 1.5;
h = plot(shp);

tri = delaunayTriangulation(shp.Points);
stlwrite1('stlfile.stl', h.Faces, h.Vertices);
% stlwrite('stlfile.stl', h.Faces, h.Vertices);

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
    
    for imageNumber = 1:6:18
        im = masks{imageNumber};
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
