# Author: Neil Mitchell
# Creator: Neil Mitchell
# Last Modified By: Neil Mitchell
<#
.SYNOPSIS
Installs or rolls back a WoW Forever SavedVariables junction for BlizzMove.

.DESCRIPTION
The bridge adds ForeverSavedVariables\BlizzMove.lua immediately before
BlizzMove.lua in the addon's TOC and creates a junction from the addon folder
to one account's canonical SavedVariables directory. SavedVariables files are
backed up and hash checked, but are never rewritten, replaced, or deleted.
Only the installed file Interface\AddOns\BlizzMove\BlizzMove.toc with one
numeric 160xx Interface line is supported; source/debug and other flavor TOCs
are refused.
#>
[CmdletBinding()]
param(
    [ValidateSet('Install', 'Rollback')]
    [string]$Action = 'Install',

    [Parameter(Mandatory)]
    [string]$WowFlavorPath,

    [Parameter(Mandatory)]
    [string]$AccountName,

    [Parameter(Mandatory)]
    [string]$BackupRoot,

    [string]$ManifestPath
)

$ErrorActionPreference = 'Stop'
Set-StrictMode -Version 2.0

$dataLine = 'ForeverSavedVariables\BlizzMove.lua'

function Get-NormalizedAbsolutePath {
    param([Parameter(Mandatory)][string]$Path, [Parameter(Mandatory)][string]$Label)

    if ([string]::IsNullOrWhiteSpace($Path) -or $Path -notmatch '^[A-Za-z]:[\\/]') {
        throw "$Label must be a drive-qualified absolute Windows path."
    }
    return [IO.Path]::GetFullPath($Path).TrimEnd([IO.Path]::DirectorySeparatorChar)
}

function Test-PathWithin {
    param([string]$Candidate, [string]$Parent)

    $candidatePath = $Candidate.TrimEnd('\')
    $parentPath = $Parent.TrimEnd('\')
    return $candidatePath.Equals($parentPath, [StringComparison]::OrdinalIgnoreCase) -or
        $candidatePath.StartsWith($parentPath + '\', [StringComparison]::OrdinalIgnoreCase)
}

function Assert-NoReparseComponents {
    param([Parameter(Mandatory)][string]$Path, [Parameter(Mandatory)][string]$Label)

    $fullPath = [IO.Path]::GetFullPath($Path)
    $root = [IO.Path]::GetPathRoot($fullPath)
    $relative = $fullPath.Substring($root.Length)
    $current = $root
    foreach ($component in $relative.Split(@('\'), [StringSplitOptions]::RemoveEmptyEntries)) {
        $current = Join-Path $current $component
        $item = Get-Item -LiteralPath $current -Force -ErrorAction SilentlyContinue
        if ($item -and ($item.Attributes -band [IO.FileAttributes]::ReparsePoint)) {
            throw "$Label contains a reparse point at '$current'; refusing path drift."
        }
    }
}

function Get-FileHashValue {
    param([Parameter(Mandatory)][string]$Path)
    return (Get-FileHash -LiteralPath $Path -Algorithm SHA256).Hash
}

function Get-BytesHash {
    param([Parameter(Mandatory)][byte[]]$Bytes)

    $sha = [Security.Cryptography.SHA256]::Create()
    try {
        return [BitConverter]::ToString($sha.ComputeHash($Bytes)).Replace('-', '')
    } finally {
        $sha.Dispose()
    }
}

function Get-TocCandidate {
    param([Parameter(Mandatory)][string]$Path)

    [byte[]]$originalBytes = [IO.File]::ReadAllBytes($Path)
    $hasBom = $originalBytes.Length -ge 3 -and
        $originalBytes[0] -eq 0xEF -and $originalBytes[1] -eq 0xBB -and $originalBytes[2] -eq 0xBF
    $utf8 = [Text.UTF8Encoding]::new($false, $true)
    $offset = if ($hasBom) { 3 } else { 0 }
    $text = $utf8.GetString($originalBytes, $offset, $originalBytes.Length - $offset)
    $newline = if ($text.Contains("`r`n")) { "`r`n" } elseif ($text.Contains("`n")) { "`n" } else {
        throw 'BlizzMove.toc has no recognizable newline sequence.'
    }
    $lines = $text.Split(@($newline), [StringSplitOptions]::None)
    $interfaceValues = @()
    foreach ($line in $lines) {
        if ($line -match '^## Interface:\s*(.+?)\s*$') { $interfaceValues += $Matches[1] }
    }
    if ($interfaceValues.Count -ne 1 -or $interfaceValues[0] -notmatch '^160\d{2}$') {
        throw 'Install requires the packaged WoW Forever BlizzMove.toc with one numeric 160xx Interface line; source/debug and alternate-flavor TOCs are unsupported.'
    }
    if (@($lines | Where-Object { $_ -match '^## SavedVariables:\s*BlizzMoveDB\s*$' }).Count -ne 1) {
        throw 'BlizzMove.toc must declare exactly one account SavedVariables entry for BlizzMoveDB.'
    }
    if (@($lines | Where-Object { $_ -ceq $dataLine }).Count -ne 0) {
        throw 'The SavedVariables bridge TOC entry already exists.'
    }
    $coreIndexes = @()
    for ($index = 0; $index -lt $lines.Count; $index++) {
        if ($lines[$index] -ceq 'BlizzMove.lua') { $coreIndexes += $index }
    }
    if ($coreIndexes.Count -ne 1) {
        throw 'Expected exactly one BlizzMove.lua line in BlizzMove.toc.'
    }
    $candidateLines = [Collections.Generic.List[string]]::new()
    for ($index = 0; $index -lt $lines.Count; $index++) {
        if ($index -eq $coreIndexes[0]) { $candidateLines.Add($dataLine) }
        $candidateLines.Add($lines[$index])
    }
    $candidateText = [string]::Join($newline, $candidateLines)
    [byte[]]$candidateContent = $utf8.GetBytes($candidateText)
    if ($hasBom) {
        [byte[]]$candidateBytes = [byte[]](@(0xEF, 0xBB, 0xBF) + $candidateContent)
    } else {
        [byte[]]$candidateBytes = $candidateContent
    }
    return [pscustomobject]@{
        OriginalBytes = $originalBytes
        OriginalSHA256 = Get-BytesHash -Bytes $originalBytes
        InstalledBytes = $candidateBytes
        InstalledSHA256 = Get-BytesHash -Bytes $candidateBytes
    }
}

function Get-SavedFileSnapshot {
    param([Parameter(Mandatory)][string]$Path)

    $item = Get-Item -LiteralPath $Path -Force
    return [pscustomobject]@{
        SourcePath = [IO.Path]::GetFullPath($item.FullName)
        SHA256 = Get-FileHashValue -Path $item.FullName
        Length = [long]$item.Length
        LastWriteTimeUtc = $item.LastWriteTimeUtc.ToString('o')
        Attributes = $item.Attributes.ToString()
    }
}

function Assert-SavedSnapshot {
    param([Parameter(Mandatory)][object[]]$Snapshots, [Parameter(Mandatory)][string[]]$ExpectedPaths)

    foreach ($expectedPath in $ExpectedPaths) {
        $snapshot = @($Snapshots | Where-Object {
            $_.SourcePath.Equals($expectedPath, [StringComparison]::OrdinalIgnoreCase)
        })
        $exists = Test-Path -LiteralPath $expectedPath -PathType Leaf
        if (($snapshot.Count -eq 1) -ne $exists) {
            throw 'SavedVariables file presence changed; inspect the retained manifest and backup.'
        }
        if ($exists) {
            $item = Get-Item -LiteralPath $expectedPath -Force
            if ((Get-FileHashValue -Path $expectedPath) -ne $snapshot[0].SHA256 -or
                $item.Length -ne $snapshot[0].Length -or
                $item.LastWriteTimeUtc.ToString('o') -ne $snapshot[0].LastWriteTimeUtc -or
                $item.Attributes.ToString() -ne $snapshot[0].Attributes) {
                throw 'SavedVariables content or metadata changed; inspect the retained manifest and backup.'
            }
        }
    }
}

function Assert-Junction {
    param([Parameter(Mandatory)][string]$LinkPath, [Parameter(Mandatory)][string]$ExpectedTarget)

    $item = Get-Item -LiteralPath $LinkPath -Force -ErrorAction Stop
    $targets = @($item.Target)
    if ($item.LinkType -ne 'Junction' -or $targets.Count -ne 1) {
        throw 'Bridge path is not the expected single-target junction.'
    }
    $actualTarget = [IO.Path]::GetFullPath([string]$targets[0]).TrimEnd('\')
    if (-not $actualTarget.Equals($ExpectedTarget.TrimEnd('\'), [StringComparison]::OrdinalIgnoreCase)) {
        throw "Bridge junction target drifted to '$actualTarget'."
    }
}

function Write-Manifest {
    param([Parameter(Mandatory)][object]$Manifest, [Parameter(Mandatory)][string]$Path)

    $json = $Manifest | ConvertTo-Json -Depth 8
    [IO.File]::WriteAllText($Path, $json + [Environment]::NewLine, [Text.UTF8Encoding]::new($false))
}

$WowFlavorPath = Get-NormalizedAbsolutePath -Path $WowFlavorPath -Label 'WowFlavorPath'
$BackupRoot = Get-NormalizedAbsolutePath -Path $BackupRoot -Label 'BackupRoot'
if ([string]::IsNullOrWhiteSpace($AccountName) -or
    $AccountName -in @('.', '..') -or
    [IO.Path]::GetFileName($AccountName) -cne $AccountName -or
    $AccountName.IndexOfAny([IO.Path]::GetInvalidFileNameChars()) -ge 0) {
    throw 'AccountName must be one literal account directory leaf name.'
}

$addonRoot = [IO.Path]::GetFullPath((Join-Path $WowFlavorPath 'Interface\AddOns\BlizzMove')).TrimEnd('\')
$accountRoot = [IO.Path]::GetFullPath((Join-Path $WowFlavorPath (Join-Path 'WTF\Account' $AccountName))).TrimEnd('\')
$savedRoot = Join-Path $accountRoot 'SavedVariables'
$tocPath = Join-Path $addonRoot 'BlizzMove.toc'
$linkPath = Join-Path $addonRoot 'ForeverSavedVariables'
$savedPaths = @((Join-Path $savedRoot 'BlizzMove.lua'), (Join-Path $savedRoot 'BlizzMove.lua.bak'))

if ((Test-PathWithin -Candidate $BackupRoot -Parent $addonRoot) -or
    (Test-PathWithin -Candidate $BackupRoot -Parent $accountRoot) -or
    (Test-PathWithin -Candidate $addonRoot -Parent $BackupRoot) -or
    (Test-PathWithin -Candidate $accountRoot -Parent $BackupRoot)) {
    throw 'BackupRoot must be separate from the addon and WTF account data trees.'
}
if (-not (Test-Path -LiteralPath $addonRoot -PathType Container) -or
    -not (Test-Path -LiteralPath $savedRoot -PathType Container) -or
    -not (Test-Path -LiteralPath $tocPath -PathType Leaf)) {
    throw 'Expected BlizzMove addon, TOC, or account SavedVariables directory is missing.'
}

$driveRoot = [IO.Path]::GetPathRoot($savedRoot)
if ([IO.DriveInfo]::new($driveRoot).DriveFormat -ne 'NTFS') {
    throw 'The selected account SavedVariables directory is not on NTFS; no junction can be installed.'
}
Assert-NoReparseComponents -Path $addonRoot -Label 'Addon path'
Assert-NoReparseComponents -Path $savedRoot -Label 'SavedVariables path'
Assert-NoReparseComponents -Path $BackupRoot -Label 'Backup path'
Assert-NoReparseComponents -Path $tocPath -Label 'TOC path'
foreach ($savedPath in $savedPaths) {
    if (Test-Path -LiteralPath $savedPath -PathType Leaf) {
        Assert-NoReparseComponents -Path $savedPath -Label 'SavedVariables file path'
    }
}

if ($Action -eq 'Rollback') {
    if ([string]::IsNullOrWhiteSpace($ManifestPath)) { throw 'Rollback requires -ManifestPath.' }
    $ManifestPath = Get-NormalizedAbsolutePath -Path $ManifestPath -Label 'ManifestPath'
    if ([IO.Path]::GetFileName($ManifestPath) -cne 'manifest.json') {
        throw 'ManifestPath filename must be manifest.json.'
    }
    if (-not (Test-PathWithin -Candidate $ManifestPath -Parent $BackupRoot) -or
        -not (Test-Path -LiteralPath $ManifestPath -PathType Leaf)) {
        throw 'ManifestPath must identify an existing manifest below BackupRoot.'
    }
    Assert-NoReparseComponents -Path $ManifestPath -Label 'Manifest path'
    $manifest = Get-Content -LiteralPath $ManifestPath -Raw | ConvertFrom-Json
    $backupDirectory = [IO.Path]::GetFullPath((Split-Path -Parent $ManifestPath)).TrimEnd('\')
    $expectedBackupToc = Join-Path $backupDirectory 'BlizzMove.toc'
    if ($manifest.Tool -ne 'Manage-ForeverSavedVariablesBridge' -or
        -not ([string]$manifest.WowFlavorPath).Equals($WowFlavorPath, [StringComparison]::OrdinalIgnoreCase) -or
        $manifest.AccountName -cne $AccountName -or
        -not ([string]$manifest.BackupRoot).Equals($BackupRoot, [StringComparison]::OrdinalIgnoreCase) -or
        -not ([string]$manifest.TocPath).Equals($tocPath, [StringComparison]::OrdinalIgnoreCase) -or
        -not ([string]$manifest.LinkPath).Equals($linkPath, [StringComparison]::OrdinalIgnoreCase) -or
        -not ([string]$manifest.Target).Equals($savedRoot, [StringComparison]::OrdinalIgnoreCase) -or
        -not ([string]$manifest.BackupTocPath).Equals($expectedBackupToc, [StringComparison]::OrdinalIgnoreCase)) {
        throw 'Manifest does not describe the exact requested client, account, backup, and bridge paths.'
    }
    Assert-NoReparseComponents -Path $expectedBackupToc -Label 'TOC backup path'
    if (-not (Test-Path -LiteralPath $expectedBackupToc -PathType Leaf) -or
        (Get-FileHashValue -Path $expectedBackupToc) -ne $manifest.OriginalTocSHA256) {
        throw 'Manifest TOC backup is missing or does not match its recorded hash.'
    }
    $candidate = Get-TocCandidate -Path $expectedBackupToc
    if ($candidate.OriginalSHA256 -ne $manifest.OriginalTocSHA256 -or
        $candidate.InstalledSHA256 -ne $manifest.InstalledTocSHA256) {
        throw 'Manifest TOC hashes do not match the recorded installation transformation.'
    }
    $manifestSavedSources = @()
    foreach ($savedFile in @($manifest.SavedFiles)) {
        $sourcePath = [IO.Path]::GetFullPath([string]$savedFile.SourcePath)
        $backupPath = [IO.Path]::GetFullPath([string]$savedFile.BackupPath)
        Assert-NoReparseComponents -Path $backupPath -Label 'SavedVariables backup path'
        $expectedBackupName = if ($sourcePath.Equals($savedPaths[0], [StringComparison]::OrdinalIgnoreCase)) {
            'SavedVariables.BlizzMove.lua'
        } elseif ($sourcePath.Equals($savedPaths[1], [StringComparison]::OrdinalIgnoreCase)) {
            'SavedVariables.BlizzMove.lua.bak'
        } else {
            throw 'Manifest contains a SavedVariables source outside the exact requested main/.bak paths.'
        }
        if ($manifestSavedSources -contains $sourcePath) {
            throw 'Manifest contains a duplicate SavedVariables source path.'
        }
        $manifestSavedSources += $sourcePath
        if (-not $backupPath.Equals((Join-Path $backupDirectory $expectedBackupName), [StringComparison]::OrdinalIgnoreCase) -or
            -not (Test-Path -LiteralPath $backupPath -PathType Leaf) -or
            (Get-FileHashValue -Path $backupPath) -ne $savedFile.SHA256) {
            throw 'A SavedVariables backup path or hash does not match the exact manifest backup.'
        }
    }
    if ($manifestSavedSources -notcontains $savedPaths[0]) {
        throw 'Manifest is missing the required main SavedVariables backup.'
    }
    $manifestHasBak = $manifestSavedSources -contains $savedPaths[1]
    $backupHasBak = Test-Path -LiteralPath (Join-Path $backupDirectory 'SavedVariables.BlizzMove.lua.bak') -PathType Leaf
    if ($manifestHasBak -ne $backupHasBak) {
        throw 'Manifest and backup disagree about the optional SavedVariables .bak file.'
    }

    $link = Get-Item -LiteralPath $linkPath -Force -ErrorAction SilentlyContinue
    if ($link) { Assert-Junction -LinkPath $linkPath -ExpectedTarget $savedRoot }
    $currentTocHash = Get-FileHashValue -Path $tocPath
    if ($currentTocHash -notin @($manifest.OriginalTocSHA256, $manifest.InstalledTocSHA256)) {
        throw 'BlizzMove.toc has unrelated changes; refusing rollback overwrite.'
    }
    if ($currentTocHash -eq $manifest.InstalledTocSHA256) {
        [IO.File]::WriteAllBytes($tocPath, [IO.File]::ReadAllBytes($expectedBackupToc))
    }
    if ($link) {
        # Delete only the already checked reparse point. Never recurse into its target.
        [IO.Directory]::Delete($linkPath, $false)
    }
    if ((Get-FileHashValue -Path $tocPath) -ne $manifest.OriginalTocSHA256 -or
        (Get-Item -LiteralPath $linkPath -Force -ErrorAction SilentlyContinue)) {
        throw 'Rollback verification failed; inspect the retained backup and manifest.'
    }
    $manifest.Status = 'ROLLED_BACK'
    $manifest.LastModifiedBy = 'Neil Mitchell'
    $manifest | Add-Member -MemberType NoteProperty -Name RolledBack -Value (Get-Date).ToString('o') -Force
    Write-Manifest -Manifest $manifest -Path $ManifestPath
    Write-Output "Rolled back the TOC and checked junction. SavedVariables files were not changed."
    return
}

if (Get-Item -LiteralPath $linkPath -Force -ErrorAction SilentlyContinue) {
    throw 'Bridge path already exists; inspect it instead of replacing it.'
}
if (-not (Test-Path -LiteralPath $savedPaths[0] -PathType Leaf)) {
    throw 'The selected account has no client-generated SavedVariables\BlizzMove.lua file.'
}

$tocCandidate = Get-TocCandidate -Path $tocPath
$savedSnapshots = @()
foreach ($savedPath in $savedPaths) {
    if (Test-Path -LiteralPath $savedPath -PathType Leaf) {
        $savedSnapshots += Get-SavedFileSnapshot -Path $savedPath
    }
}

if ($ManifestPath) {
    $ManifestPath = Get-NormalizedAbsolutePath -Path $ManifestPath -Label 'ManifestPath'
    if ([IO.Path]::GetFileName($ManifestPath) -cne 'manifest.json') {
        throw 'ManifestPath filename must be manifest.json.'
    }
    if (-not (Test-PathWithin -Candidate $ManifestPath -Parent $BackupRoot)) {
        throw 'Install ManifestPath must be below BackupRoot.'
    }
    $backupDirectory = [IO.Path]::GetFullPath((Split-Path -Parent $ManifestPath)).TrimEnd('\')
    if (Test-Path -LiteralPath $ManifestPath) { throw 'Install ManifestPath already exists.' }
    if (Test-Path -LiteralPath $backupDirectory) { throw 'Install manifest directory already exists.' }
} else {
    $backupDirectory = Join-Path $BackupRoot ((Get-Date -Format 'yyyyMMdd-HHmmss') + '-' + [Guid]::NewGuid().ToString('N'))
    $ManifestPath = Join-Path $backupDirectory 'manifest.json'
}
if (-not (Test-PathWithin -Candidate $backupDirectory -Parent $BackupRoot)) {
    throw 'Backup directory escaped BackupRoot.'
}
Assert-NoReparseComponents -Path $backupDirectory -Label 'Backup directory path'

New-Item -ItemType Directory -Path $backupDirectory | Out-Null
$backupTocPath = Join-Path $backupDirectory 'BlizzMove.toc'
Copy-Item -LiteralPath $tocPath -Destination $backupTocPath
$savedManifest = @()
foreach ($snapshot in $savedSnapshots) {
    $backupName = if ($snapshot.SourcePath.EndsWith('.bak', [StringComparison]::OrdinalIgnoreCase)) {
        'SavedVariables.BlizzMove.lua.bak'
    } else {
        'SavedVariables.BlizzMove.lua'
    }
    $backupPath = Join-Path $backupDirectory $backupName
    Copy-Item -LiteralPath $snapshot.SourcePath -Destination $backupPath
    $backupItem = Get-Item -LiteralPath $backupPath -Force
    if ((Get-FileHashValue -Path $backupPath) -ne $snapshot.SHA256 -or
        $backupItem.Length -ne $snapshot.Length -or
        $backupItem.LastWriteTimeUtc.ToString('o') -ne $snapshot.LastWriteTimeUtc -or
        $backupItem.Attributes.ToString() -ne $snapshot.Attributes) {
        throw 'SavedVariables backup content or metadata mismatch; no addon files changed.'
    }
    $savedManifest += [ordered]@{
        SourcePath = $snapshot.SourcePath
        BackupPath = $backupPath
        SHA256 = $snapshot.SHA256
        Length = $snapshot.Length
        LastWriteTimeUtc = $snapshot.LastWriteTimeUtc
        Attributes = $snapshot.Attributes
    }
}
if ((Get-FileHashValue -Path $backupTocPath) -ne $tocCandidate.OriginalSHA256) {
    throw 'TOC backup hash mismatch; no addon files changed.'
}

# Recheck path identity and all source hashes immediately before the first live mutation.
Assert-NoReparseComponents -Path $addonRoot -Label 'Addon path'
Assert-NoReparseComponents -Path $savedRoot -Label 'SavedVariables path'
Assert-NoReparseComponents -Path $backupDirectory -Label 'Backup path'
if (Get-Item -LiteralPath $linkPath -Force -ErrorAction SilentlyContinue) {
    throw 'Bridge path appeared during backup; no addon files changed.'
}
if ((Get-FileHashValue -Path $tocPath) -ne $tocCandidate.OriginalSHA256) {
    throw 'BlizzMove.toc changed during backup; no addon files changed.'
}
Assert-SavedSnapshot -Snapshots $savedSnapshots -ExpectedPaths $savedPaths

$manifest = [ordered]@{
    Tool = 'Manage-ForeverSavedVariablesBridge'
    Version = 1
    Author = 'Neil Mitchell'
    Creator = 'Neil Mitchell'
    LastModifiedBy = 'Neil Mitchell'
    Created = (Get-Date).ToString('o')
    Status = 'BACKED_UP_PENDING_INSTALL'
    WowFlavorPath = $WowFlavorPath
    AccountName = $AccountName
    BackupRoot = $BackupRoot
    TocPath = $tocPath
    LinkPath = $linkPath
    Target = $savedRoot
    BackupTocPath = $backupTocPath
    OriginalTocSHA256 = $tocCandidate.OriginalSHA256
    InstalledTocSHA256 = $tocCandidate.InstalledSHA256
    SavedFiles = $savedManifest
}
Write-Manifest -Manifest $manifest -Path $ManifestPath

New-Item -ItemType Junction -Path $linkPath -Target $savedRoot | Out-Null
Assert-Junction -LinkPath $linkPath -ExpectedTarget $savedRoot
[IO.File]::WriteAllBytes($tocPath, $tocCandidate.InstalledBytes)
if ((Get-FileHashValue -Path $tocPath) -ne $tocCandidate.InstalledSHA256) {
    throw 'Installed TOC hash mismatch; use the manifest to roll back the checked junction.'
}
Assert-SavedSnapshot -Snapshots $savedSnapshots -ExpectedPaths $savedPaths
$manifest.Status = 'INSTALLED'
$manifest.Installed = (Get-Date).ToString('o')
Write-Manifest -Manifest $manifest -Path $ManifestPath

Write-Output ($manifest | ConvertTo-Json -Depth 8)
Write-Output ('ManifestPath: ' + $ManifestPath)
