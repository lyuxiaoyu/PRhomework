clc
clear

imgSource = imread('inconspicuousFlaw.png');
imgSource = imgSource(40:788, 12:648, :);
img = imgSource;
[rows, cols, channels] = size(img);

figure(1);
subplot(2, 5, 1);
imshow(img);
title('ԭͼ��');

%%���Ա任
for c = 1: channels
    imgTmp = img(:, :, c);
    vMax = max(max(imgTmp));
    vMin = min(min(imgTmp));
    img(:, :, c) = (imgTmp - vMin) * (255 / (vMax - vMin));
end

subplot(2, 5, 2)
imshow(img);
title('���Ա任');

% ת��Ϊ�Ҷ�ͼ
img = rgb2gray(img);

subplot(2, 5, 3)
imshow(img);
title('�Ҷ�ͼ');

% �ֲ��˲�����ȥ����Ӱ�죬�û������˲�
pw = 30;
imgTmp = padarray(img, [pw, pw], 'replicate');
imgTmp = colfilt(imgTmp, [pw+1, pw+1], 'sliding', @colfiltfunc);
img = imgTmp(1+pw: rows+pw, 1+pw: cols+pw);

subplot(2, 5, 4)
imshow(img);
title('�ֲ��˲�');

% ֱ��ͼ���⻯
img = histeq(img);

subplot(2, 5, 5)
imshow(img);
title('ֱ��ͼ���⻯');

% ��˹�˲�
sigma = 1;%��׼���С  
window=double(uint8(3*sigma)*2+1);            %���ڴ�Сһ��Ϊ3*sigma  
h = fspecial('gaussian', window, sigma);      %���������˲�
img = imfilter(img,h,'replicate'); 

subplot(2, 5, 6)
imshow(img);
title('��˹�˲�');



% ֻ����������Ϣ
img((img < 220) & (img > 35)) = 128;

subplot(2, 5, 7)
imshow(img);
title('ֻ����������Ϣ');


% ���͸�ʴ����һ��ȥ������
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
title('���͸�ʴ');

% ���ս��
subplot(2, 5, 9)
imshow(gray2rgb(img));
title('α��ɫ��ʾ');

figure(2);
imshow(gray2rgb(img));


