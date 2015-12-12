clear; close all;

% load images and corresponding points for expression transfer 
im_s = imread('sahils.jpg');
im_t = imread('yizhizha.jpg');
load('points.mat');
% im1_pts = im2_pts;
[imh, imw, nc] = size(im_s); 

%  get triangulation
im_mean_pts = (im1_pts + im2_pts) ./ 2;
tri = delaunay(im_mean_pts);

% get the meshgrid 
[xx,yy] = meshgrid(1:size(im_s,2),1:size(im_s,1));

% get points within the triangulation of the intermediate shape points
t = mytsearch(im2_pts(:,1),im2_pts(:,2),tri,xx,yy);
t(isnan(t)) = 0;
mask = (t~=0);

% TODO: 
% for every point in the source, find its target point
% after affine warp and set it in a temp image with value from source
% then loop over all points which are set and optimize for them

% GET CORRECT WARPS FOR POINTS
im_s2 = zeros(size(im_s),'uint8');
for i = 1:size(tri,1)
    tgt_ind = find(t == i); % mask of points that are within ith triangle
    aff2to1 = computeAffine(im2_pts(tri(i,:),:),im1_pts(tri(i,:),:)); %warp
    [y x] = ind2sub([imh imw], tgt_ind);
    pnts = ceil(aff2to1 * [x';y';ones(1,length(y))]);
    for k = 1:numel(x)
        im_s2(y(k),x(k),:) = im_s(pnts(2,k),pnts(1,k),:);
    end
end

% COPY
im_t(repmat(mask, [1 1 3])) = im_s2(repmat(mask, [1 1 3]));
im_cp = im_t;

% BLEND
im2var = zeros(imh, imw); 
im2var(1:imh*imw) = 1:imh*imw;
fin_img = zeros(size(im_t),'uint8');

% OPTIMIZE
for c = 1:nc
    fprintf('Solving for channel %d',c);
    ec = 0; % this represents which equation we are encoding in the matrix
    A = sparse([], [], [], 4*imh*imw, imh*imw, 4*sum(sum(mask)));
    b = zeros(4*imw*imh,1);
    for y = 1:imh
        for x = 1:imw
            if(mask(y,x) == 1) 
                for k = [-1 1]
                    ec = ec + 1;
                    if(mask(y,x+k) == 1)
                        A(ec, im2var(y,x+k)) = -1; 
                        A(ec, im2var(y,x))   =  1; 
                        b(ec) = im_s2(y,x,c) - im_s2(y,x+k,c);                 
                    else
                        A(ec, im2var(y,x)) = 1; 
                        b(ec) = im_s2(y,x,c) - im_s2(y,x+k,c) + im_t(y,x+k,c);  
                    end
                    ec = ec + 1;
                    if(mask(y+k,x) == 1)
                        A(ec, im2var(y+k,x)) = -1; 
                        A(ec, im2var(y,x))   =  1; 
                        b(ec) = im_s2(y,x,c) - im_s2(y+k,x,c);                   
                    else
                        A(ec, im2var(y,x)) = 1; 
                        b(ec) = im_s2(y,x,c) - im_s2(y,x+k,c) + im_t(y+k,x,c);  
                    end
                end
%                 for k = [-1 1]
%                     ec = ec + 1;
%                     A(ec, im2var(y,x)) = 1; 
%                     if abs(im_s2(y,x,c) - im_s2(y,x+k,c)) > abs(im_t(y,x,c) - im_t(y,x+k,c))
%                         t = im_s2(y,x,c) - im_s2(y,x+k,c); 
%                     else
%                         t = im_t(y,x,c) - im_t(y,x+k,c);
%                     end
%                     if(mask(y,x+k) == 1)
%                         A(ec, im2var(y,x+k)) = -1; 
%                         b(ec) = t;                 
%                     else
%                         b(ec) = t + im_t(y,x+k,c);  
%                     end
%                     
%                     ec = ec + 1;
%                     A(ec, im2var(y,x)) = 1; 
%                     if abs(im_s2(y,x,c) - im_s2(y+k,x,c)) > abs(im_t(y,x,c) - im_t(y+k,x,c))
%                         t = im_s2(y,x,c) - im_s2(y+k,x,c); 
%                     else
%                         t = im_t(y,x,c) - im_t(y+k,x,c);
%                     end
%                     if(mask(y+k,x) == 1)
%                         A(ec, im2var(y+k,x)) = -1; 
%                         b(ec) = t;                 
%                     else
%                         b(ec) = t + im_t(y+k,x,c);  
%                     end
%                 end
            end
        end
    end
    sol = A\b;
    out_img = reshape(uint8(sol),imh,imw);
    fin_img(:,:,c) = (uint8(mask) .* out_img) + (uint8(~mask) .* im_t(:,:,c));
    clear A;
    clear b;
end
imshow(fin_img);
% THE END