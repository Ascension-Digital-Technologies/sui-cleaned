$ErrorActionPreference = "Stop"

function Get-DefaultMsysRoot {
  if (![string]::IsNullOrWhiteSpace($env:MSYS2_ROOT)) { return $env:MSYS2_ROOT }
  if (Test-Path "C:\msys64") { return "C:\msys64" }
  return "C:\msys64"
}

function Get-CandidateToolDirs {
  $msysRoot = Get-DefaultMsysRoot
  $dirs = New-Object System.Collections.Generic.List[string]

  if (![string]::IsNullOrWhiteSpace($env:LIBCLANG_PATH)) { $dirs.Add($env:LIBCLANG_PATH) }
  if (![string]::IsNullOrWhiteSpace($env:MINGW_PREFIX)) { $dirs.Add((Join-Path $env:MINGW_PREFIX "bin")) }

  foreach ($sub in @("mingw64\bin", "ucrt64\bin", "clang64\bin", "usr\bin")) {
    $dirs.Add((Join-Path $msysRoot $sub))
  }
  $dirs.Add("C:\Program Files\LLVM\bin")

  $seen = @{}
  foreach ($dir in $dirs) {
    if ([string]::IsNullOrWhiteSpace($dir)) { continue }
    $full = [System.IO.Path]::GetFullPath($dir)
    if (!$seen.ContainsKey($full) -and (Test-Path $full)) {
      $seen[$full] = $true
      $full
    }
  }
}

function Enable-LoadLibraryProbe {
  if ("Win32.NativeMethods" -as [type]) { return }
  Add-Type -Namespace Win32 -Name NativeMethods -MemberDefinition @"
[System.Runtime.InteropServices.DllImport("kernel32.dll", SetLastError=true, CharSet=System.Runtime.InteropServices.CharSet.Unicode)]
public static extern System.IntPtr LoadLibrary(string lpFileName);
[System.Runtime.InteropServices.DllImport("kernel32.dll", SetLastError=true)]
public static extern bool FreeLibrary(System.IntPtr hModule);
"@
}

function Test-DllLoadable($dll, $prependDirs) {
  if ($IsLinux -or $IsMacOS) { return $true }
  Enable-LoadLibraryProbe
  $oldPath = $env:Path
  try {
    $prefix = ($prependDirs | Where-Object { $_ -and (Test-Path $_) } | Select-Object -Unique) -join ';'
    if (![string]::IsNullOrWhiteSpace($prefix)) { $env:Path = "$prefix;$oldPath" }
    $handle = [Win32.NativeMethods]::LoadLibrary($dll)
    if ($handle -eq [System.IntPtr]::Zero) { return $false }
    [void][Win32.NativeMethods]::FreeLibrary($handle)
    return $true
  } finally {
    $env:Path = $oldPath
  }
}

$env:MSYS2_ROOT = Get-DefaultMsysRoot
$usrBin = Join-Path $env:MSYS2_ROOT "usr\bin"
$candidateDirs = @(Get-CandidateToolDirs)

if ($candidateDirs.Count -eq 0) {
  throw "No MSYS2/LLVM tool directories found. Install MSYS2 or set MSYS2_ROOT."
}

Write-Host "Windows tool search directories:"
$candidateDirs | ForEach-Object { Write-Host "  $_" }

$libclang = $null
foreach ($dir in $candidateDirs) {
  $hits = Get-ChildItem -Path $dir -Filter "libclang*.dll" -ErrorAction SilentlyContinue | Sort-Object Name
  foreach ($hit in $hits) {
    if (Test-DllLoadable $hit.FullName @($dir, $usrBin)) {
      $libclang = $hit.FullName
      break
    }
    Write-Host "Skipping unloadable libclang candidate: $($hit.FullName)"
  }
  if ($libclang) { break }
}

if (-not $libclang) {
  $pacman = Join-Path $env:MSYS2_ROOT "usr\bin\pacman.exe"
  if (Test-Path $pacman) {
    Write-Host "Installed clang-related MSYS2 packages:"
    & $pacman -Qs clang | Out-String | Write-Host
  }
  throw "Unable to find a loadable libclang*.dll. Run scripts\setup-windows.bat, or set MSYS2_ROOT to the MSYS2 install that contains clang/libclang."
}

$clang = $null
foreach ($dir in $candidateDirs) {
  $hit = Get-ChildItem -Path $dir -Filter "clang*.exe" -ErrorAction SilentlyContinue |
    Where-Object { $_.Name -match '^clang(-[0-9]+)?\.exe$' } |
    Sort-Object Name |
    Select-Object -First 1
  if ($hit) { $clang = $hit.FullName; break }
}

$libclangDir = Split-Path $libclang -Parent
$env:LIBCLANG_PATH = $libclangDir
if ($clang) { $env:CLANG_PATH = $clang }
$env:CXXFLAGS_x86_64_pc_windows_gnu = "-include cstdint"
Set-Item -Path Env:"CXXFLAGS_x86_64-pc-windows-gnu" -Value "-include cstdint"
$env:BINDGEN_EXTRA_CLANG_ARGS_x86_64_pc_windows_gnu = "--target=x86_64-w64-windows-gnu"
Set-Item -Path Env:"BINDGEN_EXTRA_CLANG_ARGS_x86_64-pc-windows-gnu" -Value "--target=x86_64-w64-windows-gnu"

$parts = $env:Path -split ';'
$prepend = @($libclangDir, $usrBin) | Where-Object { $_ -and (Test-Path $_) -and ($parts -notcontains $_) }
if ($prepend.Count -gt 0) {
  $env:Path = (($prepend -join ';') + ';' + $env:Path)
}

Write-Host "Windows Cargo environment loaded."
Write-Host "LIBCLANG_PATH=$env:LIBCLANG_PATH"
if ($env:CLANG_PATH) { Write-Host "CLANG_PATH=$env:CLANG_PATH" }
