clc
clear

filename = 'julei2.txt';
format = '%d%d';
[x, y] = textread(filename, format);

dataSet = [x y];
% 
% plot(x, y,'.','MarkerSize',1);

imgArr = zeros(200, 500);

for i = 1: length(x)
    imgArr(x(i), y(i)) = 255;
end

imshow(imgArr);

imwrite(imgArr, 'cluster1.jpg');