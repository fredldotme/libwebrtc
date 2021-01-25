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

LogBanner "installing dependencies..."
choco source Add -Name artifactory -Source https://artifactory.mersive.xyz/artifactory/api/nuget/chocolatey
ErrorOnExeFailure
choco source enable --name artifactory
ErrorOnExeFailure
choco source disable --name chocolatey
ErrorOnExeFailure

choco install --no-progress -y git
ErrorOnExeFailure
choco install --no-progress -y visualstudio2017community
ErrorOnExeFailure
choco install --no-progress -y visualstudio2017-workload-nativedesktop --execution-timeout 5400 --package-parameters "--add Microsoft.Component.VC.Runtime.UCRTSDK --add Microsoft.VisualStudio.Component.VC.ATLMFC --add Microsoft.VisualStudio.Component.UWP.Support --add Microsoft.VisualStudio.ComponentGroup.UWP.VC"
ErrorOnExeFailure
choco install --no-progress -y windows-sdk-10-version-1803-windbg
ErrorOnExeFailure
choco install --no-progress -y conan
ErrorOnExeFailure

$env:PATH="$env:PATH;C:\Program Files\Git\bin"
$env:PATH="$env:PATH;C:\Program Files (x86)\Microsoft Visual Studio\2017\BuildTools\MSBuild\15.0\Bin"
$env:PATH="$env:PATH;C:\Program Files\Conan\conan"

git fetch --tags
ErrorOnExeFailure

$commitHash = git rev-parse HEAD
ErrorOnExeFailure

$libwebrtcVersion = Get-Content -Path version.txt

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
Write-Host "Configuring Conan: Adding Mersive Artifactory"
conan remote add mersive https://artifactory.mersive.xyz/artifactory/api/conan/conan-mersive
ErrorOnExeFailure
Write-Host "Configuring Conan: Removing conan-center"
conan remote remove conan-center
ErrorOnExeFailure
Write-Host "Configuring Conan: Logging into Mersive Artifactory"
conan user -p
ErrorOnExeFailure
Write-Host "Performing conan upload"
conan upload "libwebrtc/${libwebrtcVersion}@" --all -c -r mersive
ErrorOnExeFailure
