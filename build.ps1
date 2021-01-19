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
choco source list
choco source Add -Name artifactory -Source https://artifactory.mersive.xyz/artifactory/api/nuget/chocolatey
choco source enable --name artifactory
choco source disable --name chocolatey

choco install --no-progress -y git
ErrorOnExeFailure
choco install --no-progress -y visualstudio2017community
ErrorOnExeFailure
choco install --no-progress -y visualstudio2017-workload-nativedesktop --execution-timeout 5400 --package-parameters "--add Microsoft.Component.VC.Runtime.UCRTSDK --add Microsoft.VisualStudio.Component.VC.ATLMFC --add Microsoft.VisualStudio.Component.UWP.Support --add Microsoft.VisualStudio.ComponentGroup.UWP.VC"
ErrorOnExeFailure
choco install --no-progress -y windows-sdk-10-version-1803-windbg
ErrorOnExeFailure

$env:PATH="$env:PATH;C:\Program Files\Git\bin;C:\Program Files (x86)\Microsoft Visual Studio\2017\BuildTools\MSBuild\15.0\Bin"

git fetch --tags
ErrorOnExeFailure

LogBanner "running cmake..."
mkdir out
cd out
cmake .. -G "Visual Studio 15 2017" -DTARGET_CPU=x86
ErrorOnExeFailure

LogBanner "running msbuild..."
msbuild libwebrtc.sln /p:Configuration=Release /p:Platform=Win32 /target:ALL_BUILD
ErrorOnExeFailure

LogBanner "Creating conan package from recipe..."
cd ..
conan export-pkg . "libwebrtc/0.1.0" -s os="Windows" -s arch="x86"
ErrorOnExeFailure

LogBanner "Deploying to Artifactory"
# TODO: Sign into the Artifactory respository correctly
conan upload "rsusbipclient/$version@ci/stable" --all -c -r mersive
ErrorOnExeFailure
