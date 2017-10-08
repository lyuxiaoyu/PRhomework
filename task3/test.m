clc
clear

imgSource = imread('inconspicuousFlaw.png');
imgSource = imgSource(40:788, 12:648, :);
img = imgSource;
[rows, cols, channels] = size(img);

%%线性均衡化
for c = 1: channels
    imgTmp = img(:, :, c);
    vMax = max(max(imgTmp));
    vMin = min(min(imgTmp));
    img(:, :, c) = (imgTmp - vMin) * (255 / (vMax - vMin));
end
% imgR = img(:, :, 1);
% imgG = img(:, :, 2);
% imgB = img(:, :, 3);

figure(11);
imshow(img);

imgGray = rgb2gray(img);

h = fspecial('average', [5, 5]); 
img = imfilter(img,h,'replicate'); 

% 局部滤波，用户定义滤波
pw = 31;
imgTmp = padarray(imgGray, [pw, pw], 'replicate');
imgTmp = colfilt(imgTmp, [pw+1, pw+1], 'sliding', @colfiltfunc);
imgGray = imgTmp(1+pw: rows+pw, 1+pw: cols+pw);

% %% 腐蚀膨胀
% % B = ones(10,10);
% % imgGray = imdilate(imgGray, B);
% % imgGray = imerode(imgGray, B);

imgGray = histeq(imgGray);

% %中位值滤波
% imgGray = ordfilt2(imgGray,41,ones(9,9));

sigma = 1;%标准差大小  
window=double(uint8(3*sigma)*2+1);            %窗口大小一半为3*sigma  
h = fspecial('gaussian', window, sigma);      %高斯滤波，各类线性滤波
imgGray = imfilter(imgGray,h,'replicate'); 

imgGray((imgGray < 210) & (imgGray > 40)) = 128;

h = fspecial('average', [3, 3]);      %高斯滤波，各类线性滤波
imgGray = imfilter(imgGray,h,'replicate'); 


%% 结果显示
figure(1);
imshow(gray2rgb(imgGray));
figure(3);
histogram(imgGray);
% figure(2);
% subplot(1,3,1);
% imshow(gray2rgb(imgR));
% subplot(1,3,2);
% imshow(gray2rgb(imgG));
% subplot(1,3,3);
% imshow(gray2rgb(imgB));
