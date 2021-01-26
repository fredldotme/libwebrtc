function ErrorOnExeFailure {
  if (-not $?)
  {
    throw 'Last EXE Call Failed!'
  }
}

Write-Host "Fetching git tags"
git fetch --tags
ErrorOnExeFailure

$commitHash = git rev-parse HEAD
ErrorOnExeFailure
Write-Host "commitHash=[$commitHash]"

$libwebrtcVersion = (Get-Content -Path version.txt).TrimEnd()
Write-Host "libwebrtcVersion=[$libwebrtcVersion]"

Write-Host "Creating conan package from recipe"
((Get-Content -Path conandata.yml) -Replace 'replace_with_commit_hash', $commitHash) | Set-Content -Path conandata.yml
conan export-pkg . "libwebrtc/${libwebrtcVersion}@" -s arch=x86
ErrorOnExeFailure

Write-Host "Deploying to Artifactory"
conan user -p
ErrorOnExeFailure

Write-Host "Performing conan upload"
conan upload "libwebrtc/${libwebrtcVersion}@" --all -c -r mersive-production
ErrorOnExeFailure
