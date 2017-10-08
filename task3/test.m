clc
clear

imgSource = imread('inconspicuousFlaw.png');
imgSource = imgSource(40:788, 12:648, :);
img = imgSource;
[rows, cols, channels] = size(img);

%%���Ծ��⻯
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

% �ֲ��˲����û������˲�
pw = 31;
imgTmp = padarray(imgGray, [pw, pw], 'replicate');
imgTmp = colfilt(imgTmp, [pw+1, pw+1], 'sliding', @colfiltfunc);
imgGray = imgTmp(1+pw: rows+pw, 1+pw: cols+pw);

% %% ��ʴ����
% % B = ones(10,10);
% % imgGray = imdilate(imgGray, B);
% % imgGray = imerode(imgGray, B);

imgGray = histeq(imgGray);

% %��λֵ�˲�
% imgGray = ordfilt2(imgGray,41,ones(9,9));

sigma = 1;%��׼���С  
window=double(uint8(3*sigma)*2+1);            %���ڴ�Сһ��Ϊ3*sigma  
h = fspecial('gaussian', window, sigma);      %��˹�˲������������˲�
imgGray = imfilter(imgGray,h,'replicate'); 

imgGray((imgGray < 210) & (imgGray > 40)) = 128;

h = fspecial('average', [3, 3]);      %��˹�˲������������˲�
imgGray = imfilter(imgGray,h,'replicate'); 


%% �����ʾ
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
