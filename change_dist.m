% This file artificially changes the distance from an object in an image 
% We use the following formula to calculate the new image:
% Object size = 1 / distance 
% orig_dist is how far away the object was when the image was taken
% new_dist is how far away we want the object to be

masked = mask_image('templeSR0006.png');
imshow(change(masked, 5, 10))

function im = change(masked_image, orig_dist, new_dist)
    scale = orig_dist / new_dist;
    im = zeros(size(masked_image));
    

end