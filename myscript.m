im1_name = 'images/avpatel.jpg';
im2_name = 'images/obama.jpg';
im1 = imread(im1_name);
im2 = imread(im2_name);
pts1 = getFacialLandmarks(im1_name);
pts2 = getFacialLandmarks(im2_name);
im1_pts = pts1(49:68,:);
im2_pts = pts2(49:68,:);

mim = only_borders(im1,im2,im1_pts,im2_pts);