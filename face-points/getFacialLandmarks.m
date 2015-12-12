function pts = getFacialLandmarks(im_name)

[status o] = system(['./get_landmarks shape_predictor_68_face_landmarks.dat ' im_name]);

t = char(strsplit(o));
pts = reshape(str2num(t), 2, [])';

end