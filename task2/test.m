
%% parameters to change according to your requests
fn_im='./source.jpg';
fn_mask='./mask.bmp';
fn_bg='./bg.jpg';

%% configuration
addpath(genpath('./learningBasedMatting/code'));

%% read image and mask
imdata=imread(fn_im);
mask=getMask_onlineEvaluation(fn_mask);

%% compute alpha matte
[alpha]=learningBasedMatting(imdata,mask);

%% merge with new background
imbg = imread(fn_bg);
[rows, cols, chans] = size(imdata);
imbg = imresize(imbg, [rows cols]);

a = repmat(alpha,[1 1 3]);
imresult = double(imdata) .* a + double(imbg) .* (1 - a);
imresult = uint8(imresult);

%% show and save results
imshow(imresult);
imwrite(imresult, 'result.jpg');