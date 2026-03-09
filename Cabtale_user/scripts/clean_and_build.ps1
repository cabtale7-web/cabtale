Write-Output "Done. If the build still fails with PathAccessException, please reboot and re-run this script, or run Sysinternals handle.exe to find which process is locking the file."


# 1) Try to delete the exact locked asset (bg.png)
$deleted = Try-DeleteFile $assetFile

# 1b) If single file deletion failed, attempt to delete the whole flutter assets image folder (safe: generated files)
if (-Not $deleted) {
    Write-Output "Attempting to delete entire flutter assets image directory to avoid PathExists errors: $assetDir"
    $dirDeleted = Try-DeleteDirectory $assetDir
    if ($dirDeleted) { $deleted = $true }
}

# 1c) If still not deleted, attempt to clear the flutter assets folder and flutter build cache with retries
if (-Not $deleted) {
    Write-Output "Attempting to delete flutter_assets directory and flutter_build cache with retries..."
    $r1 = Retry({ Try-DeleteDirectory $flutterAssetsDir }, 3, 2)
    $r2 = Retry({ Try-DeleteDirectory $flutterBuildCache }, 3, 2)
    if ($r1 -or $r2) { $deleted = $true }
}

if (-Not $deleted) {
    Write-Output "The file could not be deleted. Common causes: an editor (VS Code/Android Studio) or Explorer preview pane is holding the file, antivirus is scanning it, or insufficient permissions."
    Write-Output "Actions you can take now (choose one):"
    Write-Output " - Close IDEs (VS Code, Android Studio), stop emulators, and retry this script."
    Write-Output " - Reboot your machine and re-run this script."
    Write-Output " - Use Sysinternals 'handle.exe' to find which process holds the file: https://learn.microsoft.com/en-us/sysinternals/downloads/handle"
    Write-Output "   Example: handle.exe -a bg.png"
    Write-Output "If you want this script to attempt deleting the entire build directory, re-run with -ForceDeleteBuild"
}

param(
    [switch]$ForceDeleteBuild
)

if ($ForceDeleteBuild.IsPresent) {
    Write-Output "Force delete entire build directory requested. Attempting to delete: $buildDir"
    $dirDeleted = Try-DeleteDirectory $buildDir
    if (-Not $dirDeleted) {
        Write-Output "Failed to delete build directory. You may need to reboot or manually close the locking process."
        exit 1
    }
}

if ($deleted -eq $false -and -Not $ForceDeleteBuild.IsPresent) {
    Write-Output "Stopping due to unable to delete locked asset. Resolve the lock and re-run the script or re-run with -ForceDeleteBuild to remove full build directory."
    exit 1
}

# 2) Run flutter clean, pub get and build (user must have flutter on PATH)
Write-Output "Running: flutter clean"
try { flutter clean } catch { Write-Output "flutter clean failed: $($_.Exception.Message)" }

# Remove stale outputs.json in flutter_build cache if present (helps avoid stale copy instructions)
if (Test-Path $flutterBuildCache) {
$deleted = Try-DeleteFile $assetPath
