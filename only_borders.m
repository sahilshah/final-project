function im_to_blend = only_borders(im1,im2, im1_pts, im2_pts)


im_mean_pts = (im1_pts + im2_pts) ./ 2;
tri = delaunay(im2_pts);

% figure; imshow(im1);hold on;triplot(tri,im1_pts(:,1),im1_pts(:,2));
% figure; imshow(im2);hold on;triplot(tri,im2_pts(:,1),im2_pts(:,2));

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

aff2to1 = computeAffine(im2_pts,im1_pts); %warp

mask = t ~= 0;
indices = find(t ~= 0); % mask of points that are within ith triangle
[y x] = ind2sub([h w], indices);
pnts = ceil(aff2to1 * [x';y';ones(1,length(y))]);  % TODO: tentaively floor, remove later
for j = 1:numel(indices)  
    im_to_blend(y(j),x(j),:) = im1(pnts(2,j),pnts(1,j),:);
end


% BLEND

[imh, imw, nc] = size(im1); 
im2var = zeros(imh, imw); 
im2var(1:imh*imw) = 1:imh*imw;
fin_img = zeros(size(im2),'uint8');

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
                        b(ec) = im1(y,x,c) - im1(y,x+k,c);                 
                    else
                        A(ec, im2var(y,x)) = 1; 
                        b(ec) = im1(y,x,c) - im1(y,x+k,c) + im2(y,x+k,c);  
                    end
                    ec = ec + 1;
                    if(mask(y+k,x) == 1)
                        A(ec, im2var(y+k,x)) = -1; 
                        A(ec, im2var(y,x))   =  1; 
                        b(ec) = im1(y,x,c) - im1(y+k,x,c);                   
                    else
                        A(ec, im2var(y,x)) = 1; 
                        b(ec) = im1(y,x,c) - im1(y,x+k,c) + im2(y+k,x,c);  
                    end
                end
            end
        end
    end
    sol = A\b;
    out_img = reshape(uint8(sol),imh,imw);
    fin_img(:,:,c) = (uint8(mask) .* out_img) + (uint8(~mask) .* im2(:,:,c));
    clear A;
    clear b;
end

end