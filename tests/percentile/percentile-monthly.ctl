dset ^percentile-test.dat
title monthly percentile regression data
undef -9999
xdef 3 linear 0 1
ydef 1 linear 0 1
zdef 1 linear 1 1
tdef 5 linear 00z01jan2000 1mo
edef 3 names e1 e2 e3
vars 1
v 0 99 test value
endvars
