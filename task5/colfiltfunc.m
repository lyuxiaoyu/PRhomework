function re = colfiltfunc(A)
    rows = size(A, 1);
    aMean = mean(A);
    rows = floor(rows/2 +1);
    re = uint8(double(A(rows, :))  + 128 - double(aMean));
end