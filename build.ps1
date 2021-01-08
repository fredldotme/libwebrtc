function LogBanner($title) {
    Write-Host "************************************"
    Write-Host $title
    Write-Host "************************************"
}

LogBanner "installing dependencies..."
choco install -y git
refreshnv
$env:PATH="$env:PATH;C:\Program Files (x86)\Microsoft Visual Studio\2017\BuildTools\MSBuild\15.0\Bin"
$env:PATH="$env:PATH;C:\Program Files\Git\bin"

git reset --hard origin/dev
git status

LogBanner "running cmake..."
mkdir out
cd out
cmake .. -G "Visual Studio 15 2017"-DTARGET_CPU=x86

LogBanner "running msbuild..."
msbuild libwebrtc.sln /p:Configuration=Release /p:Platform=Win32 /target:ALL_BUILD

LogBanner "Copy file..."
mkdir ..\archive_src
xcopy /s lib ..\archive_src\lib\
cd .\webrtc\
xcopy /s *.h ..\..\archive_src\webrtc\
cd ../..

LogBanner "archiving..."
$BUILD_TIME=Get-Date -Format "yyyy-MM-dd_HH-mm-ss"
$branch=$env:DRONE_SOURCE_BRANCH
$sha = $env:CI_COMMIT_SHA.Substring(0, 8)
$packageName="libwebrtc_win_x86-$branch-$BUILD_TIME-$sha.zip"
7z a -r $packageName .\archive_src\*
dir $packageName

LogBanner "Deploying to Artifactory"
$username = "ci-libwebrtc"
$publishUrl = "https://artifactory.mersive.xyz/artifactory/libwebrtc/$branch/$packageName"
$creds = "{0}:{1}" -f $username,$env:ARTIFACTORY_PASSWORD
$base64 = [System.Convert]::ToBase64String([System.Text.Encoding]::ASCII.GetBytes($creds))
Write-Host "Uploading asset to Artifactory"
$params = @{
    UserAgent       = "WindowsPowerShell/5.1.17134.590"
    UseBasicParsing = $true
    Uri             = $publishUrl
    Method          = "PUT"
    InFile          = $packageName
    Headers         = @{
        ContentType   = "application/zip"
        Authorization = "Basic $base64"
    }
    Verbose         = $true
}
Invoke-WebRequest @params
