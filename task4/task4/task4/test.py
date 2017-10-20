
from PIL import Image
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
        print(currCol);

    return imgCompare;
    

if __name__ == '__main__':
    img = Image.open('img1.png').convert('L');
    rows, cols = img.size;

    imgArr = array(img);
    padSize = 1;
    step = 83.4;
    imgPad = imagePadding(imgArr, padSize);
    imgCompare = compare(imgPad, padSize, step);


    img.show();
    Image.fromarray(imgCompare).show();