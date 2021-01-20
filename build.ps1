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
choco install --no-progress -y conan
ErrorOnExeFailure
$env:PATH="$env:PATH;C:\Program Files\Conan\conan"

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
conan remote add mersive https://artifactory.mersive.xyz/artifactory/api/conan/conan-mersive
conan user "ci-libwebrtc" -r mersive -p "$env:ARTIFACTORY_PASSWORD"
conan upload "libwebrtc/0.1.0@ci/stable" --all -c -r mersive
ErrorOnExeFailure
