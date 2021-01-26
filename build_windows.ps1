function LogBanner($title) {
  Write-Host "************************************"
  Write-Host $title
  Write-Host "************************************"
}

function ErrorOnExeFailure {
  if (-not $?)
  {
    throw 'Last EXE Call Failed!'
  }
}

git fetch --tags
ErrorOnExeFailure

$commitHash = git rev-parse HEAD
ErrorOnExeFailure

$libwebrtcVersion = (Get-Content -Path version.txt).TrimEnd()

LogBanner "Configuring with CMake"
mkdir out
cd out
cmake .. -G "Visual Studio 15 2017" -DTARGET_CPU=x86
ErrorOnExeFailure

LogBanner "Performing Build"
msbuild libwebrtc.sln /p:Configuration=Release /p:Platform=Win32 /target:ALL_BUILD
ErrorOnExeFailure

LogBanner "Creating conan package from recipe..."
cd ..
((Get-Content -Path conandata.yml) -Replace 'replace_with_commit_hash', $commitHash) | Set-Content -Path conandata.yml
conan export-pkg . "libwebrtc/${libwebrtcVersion}@" -s arch=x86
ErrorOnExeFailure

LogBanner "Deploying to Artifactory"
Write-Host "Configuring Conan: Logging into Mersive Artifactory"
conan user -p
ErrorOnExeFailure
Write-Host "Performing conan upload"
conan upload "libwebrtc/${libwebrtcVersion}@" --all -c -r mersive
ErrorOnExeFailure
