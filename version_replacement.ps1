if ( $env:DRONE_TAG )
{
  Write-Host "Setting version"
  $VERSION = $env:DRONE_TAG
  Write-Host "Version set: [$VERSION]"

  Write-Host "Updating conan version..."
  ((Get-Content -Path 'conanfile.py') -Replace 'version = .*', "version = `"$VERSION`"") | Set-Content -Path 'conanfile.py'
}