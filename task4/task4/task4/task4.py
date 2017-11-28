import cv2 as cv
import matplotlib.pyplot as plt
from numpy import *


def imagePadding(imgArr, size):
    if size == 0:
        return imgArr;
    rows, cols = imgArr.shape;
    imgPad = zeros((rows+2*size, cols+2*size));
    imgPad[size: size+rows, size: size+cols] = imgArr;
    imgPad[0: size, size: -size] = imgArr[0, :];
    imgPad[-size: , size: -size] = imgArr[-1, :];
    imgPad[size: -size, 0: size] = tile(imgArr[:, 0], (size, 1)).transpose();
    imgPad[size: -size, -size: ] = tile(imgArr[:, -1], (size, 1)).transpose();
    imgPad[0: size, 0: size] = imgArr[0, 0];
    imgPad[0: size, -size: ] = imgArr[0, -1];
    imgPad[-size: , 0: size] = imgArr[-1, 0];
    imgPad[-size: , -size: ] = imgArr[-1, -1];
    return imgPad

def compare(imgPad, padSize, step):
    rows,cols = imgPad.shape;
    rows = rows - padSize * 2;
    cols = cols - padSize * 2;
    imgCompare = zeros((rows, cols));

    for currCol in range(cols):
        for currRow in range(rows):
            currPoint = imgPad[currRow+padSize, currCol+padSize];
           
            k = 0;
            tmpSum = 0.0;
            remainder = currCol % step;
            compareCol = int(remainder + 0.5);
            while compareCol < cols:
                compareArea = imgPad[currRow:currRow+2*padSize+1, compareCol: compareCol+2*padSize+1].copy();
                compareArea = compareArea - currPoint;
                compareArea = abs(compareArea);
                tmpMin = compareArea.min();
                tmpSum = tmpSum + tmpMin;

                k = k + 1;
                compareCol = int(k * step + remainder + 0.5);
                
            imgCompare[currRow, currCol] = tmpSum / k;
        if(currCol % 50 == 0):
            print(currCol, '/', cols);

    return imgCompare.astype(uint8);

def getBestStep(img):
    rows,cols = img.shape;
    stepMax = cols // 2;
    stepMin = cols // 30;
    minRecordsNum = (stepMax - stepMin)//40;
    testRows = range(1, rows, 3);

    img = img.astype('int32');

    record = zeros(stepMax - stepMin);
    for step in range(stepMin, stepMax):
        iterMax = cols // step;
        count = (iterMax - 1) * step;
        compareBase = img[testRows, 0:step];
        total = 0;
        for iter in range(1, iterMax):
            total += abs(img[testRows, step * iter: step * iter + step] - compareBase).sum();
        record[step - stepMin] = total / count;

    minRecords = argsort(record)[0: minRecordsNum] + stepMin;
    print(minRecords);
    minRecords.sort();
    print(minRecords);
    diffArr = minRecords[1:]-minRecords[:-1];
    print(diffArr);
    diff = diffArr[diffArr > stepMin].mean();
    step = minRecords.sum() / (minRecords // diff).sum();
    print('step = ', step);
    
    #显示图像
    try:
        '''
        print('close figure 1 to continue....')
        plt.plot(range(stepMin, stepMax), record);
        plt.show();

        stepManual = float(input('Is ok? \nIf your answer is yes, input number 1,\nor input the step value you caculate:\n'));
        if (stepManual > stepMin) & (stepManual < stepMax):
            step = stepManual;
            print('step = ', step);
        else:
            print('\nyes...');
        '''
    finally:
        plt.figure(1);
        plt.plot(range(stepMin, stepMax), record);
        return step;
    
if __name__ == '__main__':
    padSize = 1;
    threshold = 40; # 可改进为自动

    img = cv.imread('img1.png', 0);

    step = getBestStep(img);


    imgPad = imagePadding(img, padSize);
    imgCompare = compare(imgPad, padSize, step);

    imgCompare[imgCompare < threshold] = 0;
    imgCompare[imgCompare >= threshold] = 255;

    imgResult = cv.cvtColor(img, cv.COLOR_GRAY2RGB)
    r, g, b = cv.split(imgResult);
    r[imgCompare >= threshold] = 255;
    g[imgCompare >= threshold] = 0;
    b[imgCompare >= threshold] = 0;
    imgResult = cv.merge((r, g, b));
    # hist_cv = cv.calcHist([imgCompare],[0],None,[256],[0,256]);
    # plt.plot(hist_cv);

    plt.figure(2);
    plt.subplot(131),plt.imshow(img, 'gray');
    plt.subplot(132),plt.imshow(imgCompare,'gray');
    plt.subplot(133),plt.imshow(imgResult);
    plt.show();
