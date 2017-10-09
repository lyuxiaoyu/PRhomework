// task1.cpp: 定义控制台应用程序的入口点。
//

#include "stdafx.h"

#include <iostream>
#include <opencv2\opencv.hpp>
#include <fstream>
#include <iomanip>

using namespace cv;

const int backgroundConnectedArea = 1000;
const int clusterConnectedArea = 1000;


void loadDataAsImg(Mat &img, char* fileName) 
{
	int row, col;
	int rowMax = 0, colMax = 0;
	std::ifstream fr(fileName);
	while (!fr.eof())
	{
		fr >> row;
		if (row > rowMax) rowMax = row;
		fr >> col;
		if (col > colMax) colMax = col;
	}

	fr.clear();
	fr.seekg(0, std::ios::beg);

	img.create(rowMax+1, colMax+1, CV_8UC1);
	img.setTo(Scalar(0));

	while (!fr.eof())
	{
		fr >> row;
		fr >> col;
		img.at<uchar>(row, col) = 255;
	}
}


void fillLittleBackground(Mat &img, Mat &imgDst)
{
	int i, j;

	img.copyTo(imgDst);

	// 寻找白色部分的连通区域，
	// 背景白色
	Mat imgLabels, imgStats, imgCentriods;
	connectedComponentsWithStats(imgDst, imgLabels, imgStats, imgCentriods);

	// 将较小的联通区域背景连通区域化为前景
	for (i = 0; i < imgDst.rows; i++)
	{
		uchar *imgData = imgDst.ptr<uchar>(i);
		int *imgLabelsData = imgLabels.ptr<int>(i);
		for (j = 0; j < imgDst.cols; j++)
		{
			if (imgStats.at<int>(imgLabelsData[j], CC_STAT_AREA) < backgroundConnectedArea)
			{
				imgData[j] = 0;
			}
		}
	}
}



void markClusterArea(Mat &imgTmp, Mat &imgLabels)
{
	Mat imgStats, imgCentriods;
	connectedComponentsWithStats(imgTmp, imgLabels, imgStats, imgCentriods);

	for (int i = 0; i < imgLabels.rows; i++)
	{
		int *imgLabelsData = imgLabels.ptr<int>(i);
		for (int j = 0; j < imgLabels.cols; j++)
		{
			if (imgStats.at<int>(imgLabelsData[j], CC_STAT_AREA) < clusterConnectedArea)
			{
				imgLabelsData[j] = 0;
			}
		}
	}
}


int nearestLabel(int row, int col, Mat &imgLabels)
{
	int maxIter = imgLabels.rows > imgLabels.cols ? imgLabels.rows : imgLabels.cols;
	int i, h, nCol, nRow;

	for (i = 0; i < maxIter; i++)
	{
		h = int(i * 1.41);
		nCol = col + h;
		nRow = row;
		if (0 <= nCol && nCol < imgLabels.cols && 0 <= nRow && nRow < imgLabels.rows
			&& imgLabels.at<int>(nRow, nCol) != 0)
			return imgLabels.at<int>(nRow, nCol);

		nCol = col - h;
		nRow = row;
		if (0 <= nCol && nCol < imgLabels.cols && 0 <= nRow && nRow < imgLabels.rows
			&& imgLabels.at<int>(nRow, nCol) != 0)
			return imgLabels.at<int>(nRow, nCol);

		nCol = col;
		nRow = row - h;
		if (0 <= nCol && nCol < imgLabels.cols && 0 <= nRow && nRow < imgLabels.rows
			&& imgLabels.at<int>(nRow, nCol) != 0)
			return imgLabels.at<int>(nRow, nCol);

		nCol = col;
		nRow = row + h;
		if (0 <= nCol && nCol < imgLabels.cols && 0 <= nRow && nRow < imgLabels.rows
			&& imgLabels.at<int>(nRow, nCol) != 0)
			return imgLabels.at<int>(nRow, nCol);

		nCol = col + i;
		nRow = row + i;
		if (0 <= nCol && nCol < imgLabels.cols && 0 <= nRow && nRow < imgLabels.rows
			&& imgLabels.at<int>(nRow, nCol) != 0)
			return imgLabels.at<int>(nRow, nCol);

		nCol = col - i;
		nRow = row + i;
		if (0 <= nCol && nCol < imgLabels.cols && 0 <= nRow && nRow < imgLabels.rows
			&& imgLabels.at<int>(nRow, nCol) != 0)
			return imgLabels.at<int>(nRow, nCol);

		nCol = col + i;
		nRow = row - i;
		if (0 <= nCol && nCol < imgLabels.cols && 0 <= nRow && nRow < imgLabels.rows
			&& imgLabels.at<int>(nRow, nCol) != 0)
			return imgLabels.at<int>(nRow, nCol);

		nCol = col - i;
		nRow = row - i;
		if (0 <= nCol && nCol < imgLabels.cols && 0 <= nRow && nRow < imgLabels.rows
			&& imgLabels.at<int>(nRow, nCol) != 0)
			return imgLabels.at<int>(nRow, nCol);
	}
	return 0;
}

void markCluster(Mat &imgSrc, Mat &imgDst, Mat &imgLabels)
{
	int i, j;
	imgSrc.copyTo(imgDst);

	for (i = 0; i < imgDst.rows; i++)
	{
		uchar *imgData = imgDst.ptr<uchar>(i);
		int *imgLabelsData = imgLabels.ptr<int>(i);
		for (j = 0; j < imgDst.cols; j++)
		{
			if (255 == imgData[j])
			{
				if (0 != imgLabelsData[j] ) imgData[j] = uchar(imgLabelsData[j]);
				else imgData[j] = uchar(nearestLabel(i, j, imgLabels));
			}
		}
	}
}


int main()
{
	Mat imgSrc, imgTmp, imgDst;
	int elementSize;
	Mat element;//自定义核

	// 读取数据，转化为图片
	loadDataAsImg(imgSrc, "source/julei2.txt");
	int rows = imgSrc.rows;
	int cols = imgSrc.cols;

	// 背景为白色
	imgTmp = 255 - imgSrc;

	// 腐蚀背景
	elementSize = 1;
	element = getStructuringElement(MORPH_RECT, Size(2 * elementSize + 1, 2 * elementSize + 1), Point(elementSize, elementSize));
	erode(imgTmp, imgTmp, element);

	// 填充小块背景
	fillLittleBackground(imgTmp, imgTmp);

	// 膨胀背景
	elementSize = 4;
	element = getStructuringElement(MORPH_RECT, Size(2 * elementSize + 1, 2 * elementSize + 1), Point(elementSize, elementSize));
	dilate(imgTmp, imgTmp, element);

	// 标记点为白色
	imgTmp = 255 - imgTmp;

	// 形成大致的聚类区域
	Mat imgLabels;
	markClusterArea(imgTmp, imgLabels);

	// 生成最终图像
	markCluster(imgSrc, imgDst,imgLabels);

	// 生成最终图像显示版本


	// 显示
	namedWindow("soucre");
	imshow("soucre", imgSrc);

	namedWindow("test");
	imshow("test", imgLabels * 5000);

	namedWindow("dst");
	imshow("dst", imgDst * 20);

	waitKey(0);

    return 0;
}

