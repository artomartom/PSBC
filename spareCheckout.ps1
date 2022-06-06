git   init
git remote add -f origin https://github.com/NVIDIA/cuda-samples; #/tree/master/Samples/0_Introduction/matrixMulDynlinkJIT
git sparse-checkout init
 

#echo "some/dir/" >> .git/info/sparse-checkout;
Set-Content -Path .\.git\info\sparse-checkout -Value /tree/master/Samples/0_Introduction/matrixMulDynlinkJIT/

git sparse-checkout list
git pull origin master