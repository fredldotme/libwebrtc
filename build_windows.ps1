function ErrorOnExeFailure {
  if (-not $?)
  {
    throw 'Last EXE Call Failed!'
  }
}

Write-Host "Fetching git tags"
git fetch --tags
ErrorOnExeFailure

Write-Host "Configuring with CMake"
mkdir out32
cd out32
cmake .. -G "Visual Studio 15 2017" -DTARGET_CPU=x86 -A Win32 -T host=x64
ErrorOnExeFailure

Write-Host "Performing Build"
msbuild libwebrtc.sln /p:Configuration=Release /p:Platform=Win32 /target:ALL_BUILD
ErrorOnExeFailure

Write-Host "Configuring with CMake"
cd ..
mkdir out64
cd out64
cmake .. -G "Visual Studio 15 2017" -DTARGET_CPU=x64 -A x64 -T host=x64
ErrorOnExeFailure

Write-Host "Performing Build"
msbuild libwebrtc.sln /p:Configuration=Release /p:Platform=x64 /target:ALL_BUILD
ErrorOnExeFailure
