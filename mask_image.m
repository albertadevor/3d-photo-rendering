% Creates a mask of the image
function mask = mask_image(filename)
    gray = rgb2gray(im2double(imread(filename)));
    scaleBy = size(gray, 1) / 100;
    gray = imresize(gray, 1/scaleBy);
    % The temple fileset is rotated.
    %gray = imrotate(gray, 90);
    [m n] = size(gray);
    for i=1:m
        for j=1:n
            if(gray(i,j) < 0.1)
                gray(i,j) = 0;
            else
                gray(i,j) = 1;
            end
        end
    end
    mask = gray;
end