// task1.cpp: 定义控制台应用程序的入口点。
//

#include "stdafx.h"

#include <iostream>
#include <opencv2\opencv.hpp>



using namespace cv;


int main()
{
	Mat img = imread("source/test.jpg");
	namedWindow("test");
	imshow("test",img);
	waitKey(6000);
    return 0;
}

