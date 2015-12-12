im1 = imread('sahils.jpg');
im2 = imread('yizhizha.jpg');
load('points2.mat');

im_mean_pts = (im1_pts + im2_pts) ./ 2;
tri = delaunay(im_mean_pts);
% figure; imshow(im1);hold on;triplot(tri,im1_pts(:,1),im1_pts(:,2));
% figure; imshow(im2);hold on;triplot(tri,im2_pts(:,1),im2_pts(:,2));

frms = zeros(size(im1,1),size(im1,2),size(im1,3),61,'uint8');
frms(:,:,:,1)  = im1;
frms(:,:,:,61) = im2;
%     DEBUG
%     f = 0.5;
%     frm = morph(im1,im2,im1_pts,im2_pts,tri,f,f);
% imshow(frm);
tic;
for i=2:60
    fprintf('Making frame %d\n',i);
    f = ((i-1)/60);
    frms(:,:,:,i) = morph(im1,im2,im1_pts,im2_pts,tri,1.0-f,1.0-f);
end
toc;
% Play the morphing
for i=1:61 
    imshow(frms(:,:,:,i)); 
    imwrite(frms(:,:,:,i),sprintf('frame%d.jpg',i));
    pause(0.05); 
end

