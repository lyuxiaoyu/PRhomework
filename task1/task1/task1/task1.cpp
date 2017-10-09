// task1.cpp: 定义控制台应用程序的入口点。
//

#include <iostream>
#include <opencv2\opencv.hpp>

#include "stdafx.h"

using namespace cv;


int main()
{
	Mat img = imread("source/test.jpg");
	namedWindow("test");
	imshow("test",img);
    return 0;
}

