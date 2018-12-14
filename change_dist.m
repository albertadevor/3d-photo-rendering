% This file artificially changes the distance from an object in an image 
% We use the following formula to calculate the new image:
% Object size = 1 / distance 
% orig_dist is how far away the object was when the image was taken
% new_dist is how far away we want the object to be
% This only works with making images smaller / distances farther

function out = change_dist(img, orig_dist, new_dist)
%     scale = orig_dist / new_dist;
%     out = zeros(size(img));
%     small = imresize(img, scale);
%     padding = (size(out) - size(small)) / 2;
%     pceil = ceil(padding);
%     pfloor = floor(padding);
%     out = padarray(small, pfloor, 'post');
%     out = padarray(out, pceil, 'pre');
%     out = imresize(out, 3);
    out = img;
end