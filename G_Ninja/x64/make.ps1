$ProjectName=  $args[0]
$C="F:/Dev/LLVM/bin/clang.exe";
$CXX="F:/Dev/LLVM/bin/clang++.exe";
cmake -S F:/Dev/Projects/$ProjectName/source -B F:/Dev/Projects/$ProjectName/build/x64  -D CMAKE_C_COMPILER=$C -D CMAKE_CXX_COMPILER=$CXX -DCMAKE_CXX_COMPILER_WORKS=1 -DCMAKE_C_COMPILER_WORKS=1 -G Ninja

if( $LASTEXITCODE -ne 0)
{
  F:/Dev/other/Play_Sound.exe
} 
  