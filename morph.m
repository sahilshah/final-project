function morphed_im = morph(im1,im2, im1_pts, im2_pts, tri, warp_frac, dissolve_frac)
% DEBUG
% warp_frac = 0;
% dissolve_frac = 0;
% DEBUG ENDS

[h w ~] = size(im1);

% space for dest image
morphed_im = zeros(size(im1),'uint8');
% morphed_im = dissolve_frac .* im1 + (1-dissolve_frac) .* im2;

% get intermediate shape
is_pts = warp_frac .* im1_pts + (1-warp_frac) .* im2_pts;

% get the meshgrid 
[xx,yy] = meshgrid(1:size(im1,2),1:size(im1,1));

% get points within the triangulation of the intermediate shape points
t = mytsearch(is_pts(:,1),is_pts(:,2),tri,xx,yy);
t(isnan(t)) = 0;

% display to check
% i2  = im1 .* uint8(repmat(~isnan(t),[1,1,3]));imshow(i2);

% find warps for each triangle from imgs to intermediate shape
% for each point within the triangle apply the warp to points
% of both images
% take the intensities at these points and cross dissolve them
% and set the warped point to that value

for i = 1:size(tri,1)
    indices = find(t==i); % mask of points that are within ith triangle
    aff1tois = computeAffine(is_pts(tri(i,:),:),im1_pts(tri(i,:),:)); %warp
    aff2tois = computeAffine(is_pts(tri(i,:),:),im2_pts(tri(i,:),:)); %warp
    k = 0;
    [y x] = ind2sub([h w], indices);
    pnts1 = ceil(aff1tois * [x';y';ones(1,length(y))]);  % TODO: tentaively floor, remove later
    pnts2 = ceil(aff2tois * [x';y';ones(1,length(y))]);
    for j = 1:numel(indices)
        
        op1 = pnts1(:,j);
        op2 = pnts2(:,j);

        op1(1) = min(op1(1),w);
        op1(1) = max(op1(1),0);
        
        op1(2) = min(op1(2),h);
        op1(2) = max(op1(2),0);
        
        op2(1) = min(op2(1),w);
        op2(1) = max(op2(1),0);
        
        op2(2) = min(op2(2),h);
        op2(2) = max(op2(2),0);
        
        morphed_im(y(j),x(j),:) = dissolve_frac * im1(op1(2),op1(1),:) + ...
            (1-dissolve_frac) * im2(op2(2),op2(1),:);
    end
end

end