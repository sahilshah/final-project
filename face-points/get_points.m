im_name = '~/Desktop/cmu/courses/cv-apps/speakup-project/test-data/image1.jpg';

[a out] = system(['./get_landmarks shape_predictor_68_face_landmarks.dat ' im_name]);

A = char(strsplit(out));
points = reshape(str2num(A), 2, [])';

I = imread(im_name);
close all; imshow(I);hold on; plot(points(49:68,1),points(49:68,2),'r.','MarkerSize',10);
