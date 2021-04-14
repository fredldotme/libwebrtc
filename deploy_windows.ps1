function ErrorOnExeFailure {
  if (-not $?)
  {
    throw 'Last EXE Call Failed!'
  }
}

if ( $env:DRONE_TAG )
{
  $TARGET_REPOSITORY = "mersive-production"
}
else
{
  $TARGET_REPOSITORY = "mersive-test"
}

Write-Host "Creating conan package from recipe"
conan export-pkg . -s arch=x86
conan export-pkg . -s arch=x86_64
ErrorOnExeFailure

Write-Host "Deploying to Artifactory"
conan user -r $TARGET_REPOSITORY -p
ErrorOnExeFailure

Write-Host "Performing conan upload"
conan upload "libwebrtc/*" --all -c -r $TARGET_REPOSITORY
ErrorOnExeFailure
