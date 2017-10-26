clc
clear

imgSource = imread('inconspicuousFlaw.png');
imgSource = imgSource(40:788, 12:648, :);
img = imgSource;
[rows, cols, channels] = size(img);

figure(1);
subplot(2, 5, 1);
imshow(img);
title('原图像');

%%线性变换
for c = 1: channels
    imgTmp = img(:, :, c);
    vMax = max(max(imgTmp));
    vMin = min(min(imgTmp));
    img(:, :, c) = (imgTmp - vMin) * (255 / (vMax - vMin));
end

subplot(2, 5, 2)
imshow(img);
title('线性变换');

% 转化为灰度图
img = rgb2gray(img);

subplot(2, 5, 3)
imshow(img);
title('灰度图');

% 局部滤波，除去光线影响，用户定义滤波
pw = 30;
imgTmp = padarray(img, [pw, pw], 'replicate');
imgTmp = colfilt(imgTmp, [pw+1, pw+1], 'sliding', @colfiltfunc);
img = imgTmp(1+pw: rows+pw, 1+pw: cols+pw);

subplot(2, 5, 4)
imshow(img);
title('局部滤波');

% 直方图均衡化
img = histeq(img);

subplot(2, 5, 5)
imshow(img);
title('直方图均衡化');

% 高斯滤波
sigma = 1;%标准差大小  
window=double(uint8(3*sigma)*2+1);            %窗口大小一半为3*sigma  
h = fspecial('gaussian', window, sigma);      %各类线性滤波
img = imfilter(img,h,'replicate'); 

subplot(2, 5, 6)
imshow(img);
title('高斯滤波');



% 只保留极端信息
img((img < 220) & (img > 35)) = 128;

subplot(2, 5, 7)
imshow(img);
title('只保留极端信息');


% 膨胀腐蚀，进一步去除杂质
img1 = imerode(img, ones([5,5]));
img1 = imdilate(img1, ones([5,5]));
img1 = imdilate(img1, ones([3,3]));
img1 = imerode(img1, ones([3,3]));

img2 = imdilate(img, ones([5,5]));
img2 = imerode(img2, ones([5,5]));
img2 = imerode(img2, ones([3,3]));
img2 = imdilate(img2, ones([3,3]));

area = img1 > 100 &  img2 > 150;
img1(area) = img2(area);
img = img1;
subplot(2, 5, 8)
imshow(img);
title('膨胀腐蚀');

% 最终结果
subplot(2, 5, 9)
imshow(gray2rgb(img));
title('伪彩色显示');

figure(2);
imshow(gray2rgb(img));


