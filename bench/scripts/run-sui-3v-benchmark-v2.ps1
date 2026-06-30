<# 
.SYNOPSIS
  Runs a fresh local 3-validator Sui devnet and benchmarks TPS with stress.exe.

.DESCRIPTION
  This script automates the local benchmark loop:
    - Loads the repo's Windows Cargo environment if present
    - Builds sui.exe and stress.exe when missing, or when -Build is used
    - Kills stale sui/stress processes by default to avoid Windows port locks
    - Creates a fresh timestamped devnet folder for every run
    - Runs 3-validator genesis with benchmark keys
    - Derives the real benchmark gas owner from benchmark.keystore
    - Starts the local devnet on the chosen RPC port
    - Waits for the RPC port to open
    - Runs the stress benchmark
    - Saves logs and benchmark JSON under .bench-runs\
    - Stops local sui/stress processes at the end unless -KeepRunning is used

.EXAMPLE
  .\run-sui-3v-benchmark.ps1 -TargetQps 1000

.EXAMPLE
  .\run-sui-3v-benchmark.ps1 -TargetQps 2000 -RpcPort 9100

.EXAMPLE
  .\run-sui-3v-benchmark.ps1 -TargetQps 5000 -RpcPort 9200 -DurationSeconds 120

.NOTES
  Run from the repository root:
    C:\Users\mario\Desktop\sui-cleaned-main

  If PowerShell blocks scripts:
    Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass -Force
#>

[CmdletBinding()]
param(
    [int]$TargetQps = 1000,
    [int]$RpcPort = 9100,
    [int]$DurationSeconds = 60,
    [string]$RepoRoot = (Get-Location).Path,
    [string]$RunName = "",
    [switch]$Build,
    [switch]$SkipBuild,
    [switch]$KeepRunning,
    [switch]$NoKillExisting,
    [int]$CommitteeSize = 3,
    [int]$ClientThreads = 0,
    [int]$ServerThreads = 0,
    [int]$Workers = 0,
    [int]$InFlightRatio = 0,
    [int]$TransferAccounts = 0,
    [int]$TransferObject = 100,
    [int]$SharedCounter = 0
)

$ErrorActionPreference = "Stop"

# Windows PowerShell 5.1 does not define these PowerShell Core variables.
# The repo environment script may reference them, and StrictMode would otherwise
# fail before the benchmark can start.
if (-not (Test-Path variable:IsWindows)) { Set-Variable -Name IsWindows -Value $true -Scope Script }
if (-not (Test-Path variable:IsLinux)) { Set-Variable -Name IsLinux -Value $false -Scope Script }
if (-not (Test-Path variable:IsMacOS)) { Set-Variable -Name IsMacOS -Value $false -Scope Script }

function Write-Step {
    param([string]$Message)
    Write-Host ""
    Write-Host "==> $Message" -ForegroundColor Cyan
}

function Write-Good {
    param([string]$Message)
    Write-Host "OK: $Message" -ForegroundColor Green
}

function Write-Warn {
    param([string]$Message)
    Write-Host "WARN: $Message" -ForegroundColor Yellow
}

function Stop-OldProcesses {
    Write-Step "Stopping stale sui.exe/stress.exe processes"
    foreach ($name in @("stress", "sui")) {
        $procs = Get-Process $name -ErrorAction SilentlyContinue
        if ($null -ne $procs) {
            $procs | Stop-Process -Force -ErrorAction SilentlyContinue
            Write-Good "Stopped existing $name process(es)"
        }
    }
}

function Wait-Port {
    param(
        [string]$HostName,
        [int]$Port,
        [int]$TimeoutSeconds = 90
    )

    $deadline = (Get-Date).AddSeconds($TimeoutSeconds)
    while ((Get-Date) -lt $deadline) {
        try {
            $client = New-Object System.Net.Sockets.TcpClient
            $async = $client.BeginConnect($HostName, $Port, $null, $null)
            if ($async.AsyncWaitHandle.WaitOne(1000, $false)) {
                $client.EndConnect($async)
                $client.Close()
                return $true
            }
            $client.Close()
        } catch {
            Start-Sleep -Milliseconds 500
        }
        Start-Sleep -Milliseconds 500
    }

    return $false
}

function Join-WindowsArguments {
    param([string[]]$ArgsList)

    $escaped = New-Object System.Collections.Generic.List[string]
    foreach ($arg in $ArgsList) {
        if ($null -eq $arg) {
            $escaped.Add('""')
            continue
        }

        $s = [string]$arg
        if ($s.Length -eq 0) {
            $escaped.Add('""')
            continue
        }

        if ($s -match '[\s"]') {
            $s = $s -replace '\\(?=($|"))', '\\'
            $s = $s -replace '"', '\"'
            $escaped.Add('"' + $s + '"')
        } else {
            $escaped.Add($s)
        }
    }

    return [string]::Join(" ", $escaped)
}

function Invoke-NativeLogged {
    param(
        [Parameter(Mandatory=$true)][string]$FilePath,
        [Parameter(Mandatory=$true)][string[]]$ArgsList,
        [Parameter(Mandatory=$true)][string]$LogPath,
        [string]$WorkingDirectory = (Get-Location).Path
    )

    if (Test-Path $LogPath) {
        Remove-Item -Force $LogPath -ErrorAction SilentlyContinue
    }

    $psi = New-Object System.Diagnostics.ProcessStartInfo
    $psi.FileName = $FilePath
    $psi.Arguments = Join-WindowsArguments -ArgsList $ArgsList
    $psi.WorkingDirectory = $WorkingDirectory
    $psi.UseShellExecute = $false
    $psi.RedirectStandardOutput = $true
    $psi.RedirectStandardError = $true
    $psi.CreateNoWindow = $true

    $proc = New-Object System.Diagnostics.Process
    $proc.StartInfo = $psi

    $logWriter = New-Object System.IO.StreamWriter($LogPath, $true, [System.Text.Encoding]::UTF8)

    try {
        [void]$proc.Start()

        while (-not $proc.HasExited) {
            while (-not $proc.StandardOutput.EndOfStream) {
                $line = $proc.StandardOutput.ReadLine()
                if ($null -ne $line) {
                    Write-Host $line
                    $logWriter.WriteLine($line)
                }
            }

            while (-not $proc.StandardError.EndOfStream) {
                $line = $proc.StandardError.ReadLine()
                if ($null -ne $line) {
                    Write-Host $line
                    $logWriter.WriteLine($line)
                }
            }

            Start-Sleep -Milliseconds 100
        }

        while (-not $proc.StandardOutput.EndOfStream) {
            $line = $proc.StandardOutput.ReadLine()
            if ($null -ne $line) {
                Write-Host $line
                $logWriter.WriteLine($line)
            }
        }

        while (-not $proc.StandardError.EndOfStream) {
            $line = $proc.StandardError.ReadLine()
            if ($null -ne $line) {
                Write-Host $line
                $logWriter.WriteLine($line)
            }
        }

        return $proc.ExitCode
    }
    finally {
        $logWriter.Flush()
        $logWriter.Close()
        $proc.Dispose()
    }
}

function Set-BenchmarkDefaults {
    if ($script:InFlightRatio -le 0 -or $script:TransferAccounts -le 0 -or $script:Workers -le 0 -or $script:ClientThreads -le 0 -or $script:ServerThreads -le 0) {
        if ($script:TargetQps -le 1000) {
            if ($script:InFlightRatio -le 0) { $script:InFlightRatio = 5 }
            if ($script:TransferAccounts -le 0) { $script:TransferAccounts = 8 }
            if ($script:Workers -le 0) { $script:Workers = 12 }
            if ($script:ClientThreads -le 0) { $script:ClientThreads = 12 }
            if ($script:ServerThreads -le 0) { $script:ServerThreads = 12 }
        } elseif ($script:TargetQps -le 2000) {
            if ($script:InFlightRatio -le 0) { $script:InFlightRatio = 4 }
            if ($script:TransferAccounts -le 0) { $script:TransferAccounts = 4 }
            if ($script:Workers -le 0) { $script:Workers = 16 }
            if ($script:ClientThreads -le 0) { $script:ClientThreads = 16 }
            if ($script:ServerThreads -le 0) { $script:ServerThreads = 16 }
        } elseif ($script:TargetQps -le 3000) {
            if ($script:InFlightRatio -le 0) { $script:InFlightRatio = 3 }
            if ($script:TransferAccounts -le 0) { $script:TransferAccounts = 4 }
            if ($script:Workers -le 0) { $script:Workers = 18 }
            if ($script:ClientThreads -le 0) { $script:ClientThreads = 18 }
            if ($script:ServerThreads -le 0) { $script:ServerThreads = 18 }
        } elseif ($script:TargetQps -le 5000) {
            if ($script:InFlightRatio -le 0) { $script:InFlightRatio = 2 }
            if ($script:TransferAccounts -le 0) { $script:TransferAccounts = 2 }
            if ($script:Workers -le 0) { $script:Workers = 24 }
            if ($script:ClientThreads -le 0) { $script:ClientThreads = 24 }
            if ($script:ServerThreads -le 0) { $script:ServerThreads = 24 }
        } else {
            if ($script:InFlightRatio -le 0) { $script:InFlightRatio = 2 }
            if ($script:TransferAccounts -le 0) { $script:TransferAccounts = 2 }
            if ($script:Workers -le 0) { $script:Workers = 32 }
            if ($script:ClientThreads -le 0) { $script:ClientThreads = 32 }
            if ($script:ServerThreads -le 0) { $script:ServerThreads = 32 }
        }
    }

    $setupEstimate = $script:TargetQps * $script:InFlightRatio * ($script:TransferAccounts + 1)
    Write-Good "Benchmark defaults: target_qps=$script:TargetQps workers=$script:Workers threads=$script:ClientThreads/$script:ServerThreads in_flight=$script:InFlightRatio transfer_accounts=$script:TransferAccounts setup_estimate~$setupEstimate"
    if ($setupEstimate -gt 70000) {
        Write-Warn "Setup estimate is high. If gas initialization fails, lower -InFlightRatio or -TransferAccounts."
    }
}

function Ensure-AddressScript {
    param([string]$ToolsDir)

    New-Item -ItemType Directory -Force $ToolsDir | Out-Null
    $scriptPath = Join-Path $ToolsDir "print-real-benchmark-addresses.py"

    @'
import base64
import hashlib
import json
import subprocess
import sys
from pathlib import Path

try:
    from cryptography.hazmat.primitives.asymmetric import ed25519
    from cryptography.hazmat.primitives import serialization
except ImportError:
    print("Python package 'cryptography' is missing; attempting install...", file=sys.stderr)
    subprocess.check_call([sys.executable, "-m", "pip", "install", "cryptography"])
    from cryptography.hazmat.primitives.asymmetric import ed25519
    from cryptography.hazmat.primitives import serialization

path = Path(sys.argv[1])
keys = json.loads(path.read_text())

for encoded in keys:
    raw = base64.b64decode(encoded)
    scheme = raw[0]
    private_seed = raw[1:33]
    private_key = ed25519.Ed25519PrivateKey.from_private_bytes(private_seed)
    public_key = private_key.public_key().public_bytes(
        encoding=serialization.Encoding.Raw,
        format=serialization.PublicFormat.Raw,
    )
    address = hashlib.blake2b(bytes([scheme]) + public_key, digest_size=32).hexdigest()
    print("0x" + address)
'@ | Set-Content -Path $scriptPath -Encoding UTF8

    return $scriptPath
}

try {
    $RepoRoot = (Resolve-Path $RepoRoot).Path
    Set-Location $RepoRoot

    Write-Step "Repository root"
    Write-Host $RepoRoot

    $envScript = Join-Path $RepoRoot ".cargo\env-windows.ps1"
    if (Test-Path $envScript) {
        Write-Step "Loading Windows Cargo environment"
        Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass -Force | Out-Null
        Unblock-File $envScript -ErrorAction SilentlyContinue
        . $envScript
    } else {
        Write-Warn "No .cargo\env-windows.ps1 found; continuing with current environment"
    }

    Set-StrictMode -Version Latest

    if (-not $NoKillExisting) {
        Stop-OldProcesses
    }

    Set-BenchmarkDefaults

    $sui = Join-Path $RepoRoot "target\release\sui.exe"
    $stress = Join-Path $RepoRoot "target\release\stress.exe"

    if (-not $SkipBuild) {
        if ($Build -or -not (Test-Path $sui)) {
            Write-Step "Building sui.exe"
            cargo build --release -p sui --bin sui
        } else {
            Write-Good "Found $sui"
        }

        if ($Build -or -not (Test-Path $stress)) {
            Write-Step "Building stress.exe"
            cargo build --release -p sui-benchmark --bin stress
        } else {
            Write-Good "Found $stress"
        }
    }

    if (-not (Test-Path $sui)) {
        throw "Missing sui.exe at $sui. Run with -Build or build it manually."
    }
    if (-not (Test-Path $stress)) {
        throw "Missing stress.exe at $stress. Run with -Build or build it manually."
    }

    if ([string]::IsNullOrWhiteSpace($RunName)) {
        $stamp = Get-Date -Format "yyyyMMdd-HHmmss"
        $RunName = "3v-${TargetQps}qps-$stamp"
    }

    $runsRoot = Join-Path $RepoRoot ".bench-runs"
    $runDir = Join-Path $runsRoot $RunName
    $devnet = Join-Path $runDir "devnet"
    $logsDir = Join-Path $runDir "logs"
    $toolsDir = Join-Path $runsRoot "tools"

    New-Item -ItemType Directory -Force $devnet | Out-Null
    New-Item -ItemType Directory -Force $logsDir | Out-Null

    $resultJson = Join-Path $runDir "bench-result-${TargetQps}qps.json"
    $stressLog = Join-Path $logsDir "stress-${TargetQps}qps.log"
    $devnetOut = Join-Path $logsDir "devnet.stdout.log"
    $devnetErr = Join-Path $logsDir "devnet.stderr.log"

    Write-Step "Run directory"
    Write-Host $runDir

    Write-Step "Creating fresh 3-validator genesis"
    $benchmarkIps = "127.0.0.1,127.0.0.1,127.0.0.1"
    & $sui genesis `
        --working-dir $devnet `
        --force `
        --with-faucet `
        --benchmark-ips $benchmarkIps

    $genesisBlob = Join-Path $devnet "genesis.blob"
    $keystore = Join-Path $devnet "benchmark.keystore"

    if (-not (Test-Path $genesisBlob)) {
        throw "Genesis blob was not created at $genesisBlob"
    }
    if (-not (Test-Path $keystore)) {
        throw "Benchmark keystore was not created at $keystore"
    }

    Write-Step "Deriving real benchmark gas owner"
    $addrScript = Ensure-AddressScript -ToolsDir $toolsDir
    $addresses = & python $addrScript $keystore
    if ($LASTEXITCODE -ne 0 -or $addresses.Count -lt 1) {
        throw "Failed to derive benchmark addresses from $keystore"
    }

    $gasOwner = [string]$addresses[0]
    Write-Good "Primary gas owner: $gasOwner"

    Write-Step "Starting local devnet on RPC port $RpcPort"
    $devnetArgs = @(
        "start",
        "--network.config", $devnet,
        "--fullnode-rpc-port", "$RpcPort"
    )

    $devnetProcess = Start-Process `
        -FilePath $sui `
        -ArgumentList $devnetArgs `
        -WorkingDirectory $RepoRoot `
        -RedirectStandardOutput $devnetOut `
        -RedirectStandardError $devnetErr `
        -PassThru

    Write-Good "Started sui.exe PID $($devnetProcess.Id)"

    Write-Step "Waiting for RPC port $RpcPort"
    if (-not (Wait-Port -HostName "127.0.0.1" -Port $RpcPort -TimeoutSeconds 120)) {
        Write-Warn "RPC port did not open within timeout."
        Write-Warn "Devnet stdout: $devnetOut"
        Write-Warn "Devnet stderr: $devnetErr"
        throw "Devnet RPC did not become ready on port $RpcPort"
    }
    Write-Good "RPC is accepting connections on http://127.0.0.1:$RpcPort"

    Write-Step "Running stress benchmark"
    $stressArgs = @(
        "--genesis-blob-path", $genesisBlob,
        "--keystore-path", $keystore,
        "--primary-gas-owner-id", $gasOwner,
        "--fullnode-rpc-addresses", "http://127.0.0.1:$RpcPort",
        "--committee-size", "$CommitteeSize",
        "--num-client-threads", "$ClientThreads",
        "--num-server-threads", "$ServerThreads",
        "--num-transfer-accounts", "$TransferAccounts",
        "--run-duration", "${DurationSeconds}s",
        "--benchmark-stats-path", $resultJson,
        "--stat-collection-interval", "5",
        "--stress-stat-collection",
        "bench",
        "--target-qps", "$TargetQps",
        "--num-workers", "$Workers",
        "--in-flight-ratio", "$InFlightRatio",
        "--transfer-object", "$TransferObject",
        "--shared-counter", "$SharedCounter"
    )

    $stressExit = Invoke-NativeLogged `
        -FilePath $stress `
        -ArgsList $stressArgs `
        -LogPath $stressLog `
        -WorkingDirectory $RepoRoot

    if ($stressExit -ne 0) {
        throw "stress.exe exited with code $stressExit. Log: $stressLog"
    }

    Write-Step "Benchmark finished"
    Write-Good "Stress log: $stressLog"
    Write-Good "Devnet stdout: $devnetOut"
    Write-Good "Devnet stderr: $devnetErr"
    Write-Good "Result JSON: $resultJson"

    if (Test-Path $resultJson) {
        try {
            $json = Get-Content $resultJson -Raw | ConvertFrom-Json
            if ($null -ne $json.num_success_txes -and $null -ne $json.duration.secs -and $json.duration.secs -gt 0) {
                $computedTps = [math]::Round($json.num_success_txes / $json.duration.secs, 2)
                Write-Good "Computed TPS from JSON: $computedTps"
            }
        } catch {
            Write-Warn "Could not parse TPS from JSON, but result file exists."
        }
    }

    Write-Host ""
    Write-Host "Completed run: $RunName" -ForegroundColor Green
    Write-Host "Run folder: $runDir" -ForegroundColor Green
}
catch {
    Write-Host ""
    Write-Host "FAILED: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host "Tip: rerun with a different -RpcPort if Windows still has a socket in TIME_WAIT." -ForegroundColor Yellow
    exit 1
}
finally {
    if (-not $KeepRunning) {
        Write-Step "Cleaning up local sui/stress processes"
        foreach ($name in @("stress", "sui")) {
            Get-Process $name -ErrorAction SilentlyContinue | Stop-Process -Force -ErrorAction SilentlyContinue
        }
        Write-Good "Cleanup complete"
    } else {
        Write-Warn "Keeping devnet running because -KeepRunning was set"
    }
}
