clear; close all;

dm = 1;
tgt_img = imread('yizhizha.jpg');
src_img = imread('sahils.jpg');

tgt_img = imresize(tgt_img,0.2);
src_img = imresize(src_img,0.2);

[m,p] = getMask(src_img);

if( dm == 1)
    % Verfiy
    imshow(m);
    pause;
end
tic
% im_t = alignSource(src_img, m, tgt_img);
[im_cp,im_t] = my_blend(src_img, m, tgt_img);
imwrite(im_cp,'cut-paste.jpg');
imwrite(im_t,'blended.jpg');

toc

