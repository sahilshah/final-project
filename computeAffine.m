function Aff = computeAffine(tri1_pts, tri2_pts)
% tri_pts is 3 x 2
n = size(tri1_pts,1);

A = zeros(2*n,6);
b = zeros(2*n,1);
A(1:2:end,3) = 1;
A(2:2:end,6) = 1;
A(1:2:end,1:2) = tri1_pts;
A(2:2:end,4:5) = tri1_pts;
b(1:2:end,1) = tri2_pts(:,1);
b(2:2:end,1) = tri2_pts(:,2);

x = A \ b;

Aff = reshape(x,3,2);
Aff = Aff';

end