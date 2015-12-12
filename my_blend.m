function [im_cp,im_t] = my_blend(im_s, mask, im_t)
% im_s2 = alignSource(im_s, mask, im_t)
% Asks user for bottom-center position and outputs an aligned source image.

figure(1), hold off, imagesc(im_s), axis image
figure(2), hold off, imagesc(im_t), axis image
% returns row and col indices where mask = 1
[y, x] = find(mask);
y1 = min(y)-1; y2 = max(y)+1; x1 = min(x)-1; x2 = max(x)+1;
disp('choose target bottom-center location')
[tx, ty] = ginput(1);

yind = (y1:y2);
yind2 = yind - max(y) + round(ty);
xind = (x1:x2);
xind2 = xind - round(mean(x)) + round(tx);

% create mask such that it is aligned with the target
y = y - max(y) + round(ty);
x = x - round(mean(x)) + round(tx);
ind = y + (x-1)*size(im_t, 1);
mask2 = false(size(im_t, 1), size(im_t, 2));
mask2(ind) = true;

% CUT PASTE
im_s2 = zeros(size(im_t));
im_s2(yind2, xind2, :) = im_s(yind, xind, :);
im_t(repmat(mask2, [1 1 3])) = im_s2(repmat(mask2, [1 1 3]));
im_cp = im_t;

% BLEND
im_s2 = zeros(size(im_t));
im_s2(yind2, xind2, :) = im_s(yind, xind, :);

% BUILD im_s2 with the optimized values
[imh, imw, nc] = size(im_s2); 
im2var = zeros(imh, imw); 
im2var(1:imh*imw) = 1:imh*imw;
% var2imy = im2var ./ imw;
% var2imx = mod(im2var,imw);
fin_img = zeros(size(im_t),'uint8');

for c = 1:nc
    fprintf('Solving for channel %d',c);
    ec = 0; % this represents which equation we are encoding in the matrix
    A = sparse([], [], [], 4*imh*imw, imh*imw, 4*sum(sum(mask2)));
    b = zeros(4*imw*imh,1);
    for y = 1:imh
        for x = 1:imw
            if(mask2(y,x) == 1) 
                for k = [-1 1]
                    ec = ec + 1;
                    if(mask2(y,x+k) == 1)
                        A(ec, im2var(y,x+k)) = -1; 
                        A(ec, im2var(y,x))   =  1; 
                        b(ec) = im_s2(y,x,c) - im_s2(y,x+k,c);                 
                    else
                        A(ec, im2var(y,x)) = 1; 
                        b(ec) = im_s2(y,x,c) - im_s2(y,x+k,c) + im_t(y,x+k,c);  
                    end
                    ec = ec + 1;
                    if(mask2(y+k,x) == 1)
                        A(ec, im2var(y+k,x)) = -1; 
                        A(ec, im2var(y,x))   =  1; 
                        b(ec) = im_s2(y,x,c) - im_s2(y+k,x,c);                   
                    else
                        A(ec, im2var(y,x)) = 1; 
                        b(ec) = im_s2(y,x,c) - im_s2(y,x+k,c) + im_t(y+k,x,c);  
                    end
                end
            end
        end
    end
    sol = A\b;
%     sol = [sol;ones(imh*imw-size(sol,1),1)];
    out_img = reshape(uint8(sol),imh,imw);
    fin_img(:,:,c) = (uint8(mask2) .* out_img) + (uint8(~mask2) .* im_t(:,:,c));
    clear A;
    clear b;
end
im_t  = fin_img;
figure(2), hold off, imshow(im_t), axis image;
drawnow;
% END MOD

