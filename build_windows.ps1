function ErrorOnExeFailure {
  if (-not $?)
  {
    throw 'Last EXE Call Failed!'
  }
}

Write-Host "Configuring with CMake"
mkdir out
cd out
cmake .. -G "Visual Studio 15 2017" -DTARGET_CPU=x86
ErrorOnExeFailure

Write-Host "Performing Build"
msbuild libwebrtc.sln /p:Configuration=Release /p:Platform=Win32 /target:ALL_BUILD
ErrorOnExeFailure
