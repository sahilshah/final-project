function im_to_blend = transfer_position(im1,im2, im1_pts, im2_pts)


im_mean_pts = (im1_pts + im2_pts) ./ 2;
tri = delaunay(im_mean_pts);

figure; imshow(im1);hold on;triplot(tri,im1_pts(:,1),im1_pts(:,2));
figure; imshow(im2);hold on;triplot(tri,im2_pts(:,1),im2_pts(:,2));


[h w ~] = size(im1);

% im_to_blend = zeros(size(im2),'uint8');
im_to_blend = im2;

% get the meshgrid 
[xx,yy] = meshgrid(1:size(im1,2),1:size(im1,1));

% get points within the triangulation of the destination image
t = mytsearch(im2_pts(:,1),im2_pts(:,2),tri,xx,yy);
t(isnan(t)) = 0;

% display to check
% i2  = im1 .* uint8(repmat(~isnan(t),[1,1,3]));imshow(i2);

for i = 1:size(tri,1)
    indices = find(t == i); % mask of points that are within ith triangle
    aff2to1 = computeAffine(im1_pts(tri(i,:),:),im2_pts(tri(i,:),:)); %warp
    [y x] = ind2sub([h w], indices);
    pnts = ceil(aff2to1 * [x';y';ones(1,length(y))]);  % TODO: tentaively floor, remove later
    for j = 1:numel(indices)  
        im_to_blend(y(j),x(j),:) = im1(pnts(2,j),pnts(1,j),:);
    end
end

end