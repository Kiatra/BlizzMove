# Author: Neil Mitchell
# Creator: Neil Mitchell
# Last Modified By: Neil Mitchell
# Runs the real bridge tool only against an isolated temporary client fixture.
[CmdletBinding()]
param()

$ErrorActionPreference = 'Stop'
Set-StrictMode -Version 2.0

$repoRoot = Split-Path -Parent $PSScriptRoot
$tool = Join-Path $repoRoot 'tools\Manage-ForeverSavedVariablesBridge.ps1'
$tempRoot = [IO.Path]::GetFullPath([IO.Path]::GetTempPath()).TrimEnd('\')
$fixture = Join-Path $tempRoot ('blizzmove-saved-bridge-' + [Guid]::NewGuid().ToString('N'))

function Get-Hash([string]$Path) {
    return (Get-FileHash -LiteralPath $Path -Algorithm SHA256).Hash
}

function Assert-ThrowsLike {
    param([scriptblock]$Operation, [string]$Pattern, [string]$FailureMessage)

    $matched = $false
    try {
        & $Operation | Out-Null
    } catch {
        $matched = $_.Exception.Message -like $Pattern
    }
    if (-not $matched) { throw $FailureMessage }
}

try {
    $flavor = Join-Path $fixture '_classic_beta_'
    $addon = Join-Path $flavor 'Interface\AddOns\BlizzMove'
    $accountName = 'TESTACCOUNT#1'
    $account = Join-Path $flavor (Join-Path 'WTF\Account' $accountName)
    $saved = Join-Path $account 'SavedVariables'
    $backupRoot = Join-Path $fixture 'bridge-backups'
    New-Item -ItemType Directory -Path $addon, $saved | Out-Null

    $toc = Join-Path $addon 'BlizzMove.toc'
    $originalToc = "## Interface: 16001`r`n## Title: BlizzMove fixture`r`n## SavedVariables: BlizzMoveDB`r`nLocale\Locale.xml`r`nBlizzMove.lua`r`n"
    [IO.File]::WriteAllText($toc, $originalToc, [Text.UTF8Encoding]::new($false))
    $main = Join-Path $saved 'BlizzMove.lua'
    $bak = $main + '.bak'
    $mainContent = 'BlizzMoveDB = { points = {}, generation = 1 }'
    $bakContent = 'BlizzMoveDB = { points = {}, generation = 0 }'
    [IO.File]::WriteAllText($main, $mainContent, [Text.UTF8Encoding]::new($false))
    [IO.File]::WriteAllText($bak, $bakContent, [Text.UTF8Encoding]::new($false))
    $mainStamp = [datetime]::SpecifyKind([datetime]'2026-09-19T20:00:00', [DateTimeKind]::Utc)
    $bakStamp = [datetime]::SpecifyKind([datetime]'2026-09-19T19:00:00', [DateTimeKind]::Utc)
    [IO.File]::SetLastWriteTimeUtc($main, $mainStamp)
    [IO.File]::SetLastWriteTimeUtc($bak, $bakStamp)
    $mainHash = Get-Hash $main
    $bakHash = Get-Hash $bak
    $mainAttributes = (Get-Item -LiteralPath $main -Force).Attributes
    $bakAttributes = (Get-Item -LiteralPath $bak -Force).Attributes

    $manifestPath = Join-Path $backupRoot 'explicit-install\manifest.json'
    & $tool -Action Install -WowFlavorPath $flavor -AccountName $accountName `
        -BackupRoot $backupRoot -ManifestPath $manifestPath | Out-Null

    $manifest = Get-Content -LiteralPath $manifestPath -Raw | ConvertFrom-Json
    if ($manifest.Status -ne 'INSTALLED' -or
        $manifest.Author -ne 'Neil Mitchell' -or
        $manifest.Creator -ne 'Neil Mitchell' -or
        $manifest.LastModifiedBy -ne 'Neil Mitchell') {
        throw 'Install manifest status or document metadata is incorrect.'
    }
    $mainBackup = Join-Path (Split-Path -Parent $manifestPath) 'SavedVariables.BlizzMove.lua'
    $bakBackup = Join-Path (Split-Path -Parent $manifestPath) 'SavedVariables.BlizzMove.lua.bak'
    if ((Get-Hash $mainBackup) -ne $mainHash -or
        (Get-Hash $bakBackup) -ne $bakHash -or
        (Get-Hash $manifest.BackupTocPath) -ne $manifest.OriginalTocSHA256) {
        throw 'The hash-verified backup does not preserve the original TOC/main/.bak files.'
    }
    if ((Get-Item -LiteralPath $mainBackup -Force).LastWriteTimeUtc -ne $mainStamp -or
        (Get-Item -LiteralPath $bakBackup -Force).LastWriteTimeUtc -ne $bakStamp -or
        (Get-Item -LiteralPath $mainBackup -Force).Attributes -ne $mainAttributes -or
        (Get-Item -LiteralPath $bakBackup -Force).Attributes -ne $bakAttributes) {
        throw 'SavedVariables backup file metadata was not preserved.'
    }
    if ((Get-Hash $main) -ne $mainHash -or (Get-Hash $bak) -ne $bakHash -or
        (Get-Item -LiteralPath $main -Force).LastWriteTimeUtc -ne $mainStamp -or
        (Get-Item -LiteralPath $bak -Force).LastWriteTimeUtc -ne $bakStamp -or
        (Get-Item -LiteralPath $main -Force).Attributes -ne $mainAttributes -or
        (Get-Item -LiteralPath $bak -Force).Attributes -ne $bakAttributes) {
        throw 'Install changed SavedVariables contents or file metadata.'
    }

    $installedToc = [IO.File]::ReadAllText($toc)
    $expectedToc = $originalToc.Replace(
        "BlizzMove.lua`r`n",
        "ForeverSavedVariables\BlizzMove.lua`r`nBlizzMove.lua`r`n"
    )
    if ($installedToc -cne $expectedToc) {
        throw 'Install did not add exactly one bridge entry immediately before BlizzMove.lua.'
    }
    $link = Join-Path $addon 'ForeverSavedVariables'
    $linkItem = Get-Item -LiteralPath $link -Force
    if ($linkItem.LinkType -ne 'Junction' -or
        -not ([IO.Path]::GetFullPath([string]@($linkItem.Target)[0])).Equals(
            [IO.Path]::GetFullPath($saved), [StringComparison]::OrdinalIgnoreCase)) {
        throw 'Install did not create the expected account SavedVariables junction.'
    }

    Assert-ThrowsLike -Pattern '*Bridge path already exists*' `
        -FailureMessage 'Repeated install was not refused.' -Operation {
            & $tool -Action Install -WowFlavorPath $flavor -AccountName $accountName `
                -BackupRoot $backupRoot
        }

    # Native-style rotation must remain visible through the directory junction.
    Move-Item -LiteralPath $main -Destination $bak -Force
    [IO.File]::WriteAllText($main, 'BlizzMoveDB = { points = {}, generation = 2 }', [Text.UTF8Encoding]::new($false))
    $linkedMain = Join-Path $link 'BlizzMove.lua'
    if ([IO.File]::ReadAllText($linkedMain) -cne [IO.File]::ReadAllText($main)) {
        throw 'The bridge exposed stale data after canonical SavedVariables rotation.'
    }
    $rotatedMainHash = Get-Hash $main
    $rotatedBakHash = Get-Hash $bak

    # A different junction at the exact bridge path must block rollback.
    [IO.Directory]::Delete($link, $false)
    $wrongTarget = Join-Path $fixture 'wrong-target'
    New-Item -ItemType Directory -Path $wrongTarget | Out-Null
    New-Item -ItemType Junction -Path $link -Target $wrongTarget | Out-Null
    Assert-ThrowsLike -Pattern '*target drifted*' `
        -FailureMessage 'Rollback accepted a junction pointing at the wrong target.' -Operation {
            & $tool -Action Rollback -WowFlavorPath $flavor -AccountName $accountName `
                -BackupRoot $backupRoot -ManifestPath $manifestPath
        }
    if ([IO.File]::ReadAllText($toc) -cne $installedToc) {
        throw 'Wrong-junction refusal changed the installed TOC.'
    }
    [IO.Directory]::Delete($link, $false)
    New-Item -ItemType Junction -Path $link -Target $saved | Out-Null

    # Unrelated TOC drift is never overwritten.
    [IO.File]::AppendAllText($toc, "# unrelated drift`r`n")
    Assert-ThrowsLike -Pattern '*unrelated changes*' `
        -FailureMessage 'Rollback overwrote unrelated TOC drift.' -Operation {
            & $tool -Action Rollback -WowFlavorPath $flavor -AccountName $accountName `
                -BackupRoot $backupRoot -ManifestPath $manifestPath
        }
    [IO.File]::WriteAllText($toc, $installedToc, [Text.UTF8Encoding]::new($false))

    & $tool -Action Rollback -WowFlavorPath $flavor -AccountName $accountName `
        -BackupRoot $backupRoot -ManifestPath $manifestPath | Out-Null
    if ([IO.File]::ReadAllText($toc) -cne $originalToc -or
        (Get-Item -LiteralPath $link -Force -ErrorAction SilentlyContinue) -or
        (Get-Hash $main) -ne $rotatedMainHash -or (Get-Hash $bak) -ne $rotatedBakHash) {
        throw 'Rollback failed to restore the TOC/remove only the link/preserve rotated data.'
    }

    # Partial install: original TOC with a checked junction. Rollback removes only the link.
    New-Item -ItemType Junction -Path $link -Target $saved | Out-Null
    & $tool -Action Rollback -WowFlavorPath $flavor -AccountName $accountName `
        -BackupRoot $backupRoot -ManifestPath $manifestPath | Out-Null
    & $tool -Action Rollback -WowFlavorPath $flavor -AccountName $accountName `
        -BackupRoot $backupRoot -ManifestPath $manifestPath | Out-Null
    if ((Get-Item -LiteralPath $link -Force -ErrorAction SilentlyContinue) -or
        [IO.File]::ReadAllText($toc) -cne $originalToc -or
        (Get-Hash $main) -ne $rotatedMainHash -or (Get-Hash $bak) -ne $rotatedBakHash) {
        throw 'Partial or repeated rollback was not idempotent and data preserving.'
    }

    Assert-ThrowsLike -Pattern '*literal account directory leaf*' `
        -FailureMessage 'Account-name traversal was not refused.' -Operation {
            & $tool -Action Install -WowFlavorPath $flavor -AccountName '..\escape' `
                -BackupRoot $backupRoot
        }
    Assert-ThrowsLike -Pattern '*separate from the addon and WTF account data trees*' `
        -FailureMessage 'BackupRoot inside account data was not refused.' -Operation {
            & $tool -Action Install -WowFlavorPath $flavor -AccountName $accountName `
                -BackupRoot (Join-Path $account 'unsafe-backup')
        }

    $realBackupTarget = Join-Path $fixture 'real-backup-target'
    $reparseBackupRoot = Join-Path $fixture 'reparse-backup-root'
    New-Item -ItemType Directory -Path $realBackupTarget | Out-Null
    New-Item -ItemType Junction -Path $reparseBackupRoot -Target $realBackupTarget | Out-Null
    Assert-ThrowsLike -Pattern '*contains a reparse point*' `
        -FailureMessage 'A reparse-point BackupRoot was not refused.' -Operation {
            & $tool -Action Install -WowFlavorPath $flavor -AccountName $accountName `
                -BackupRoot $reparseBackupRoot
        }
    [IO.Directory]::Delete($reparseBackupRoot, $false)

    $collisionBackupRoot = Join-Path $fixture 'collision-backups'
    $collisionManifestPath = Join-Path $collisionBackupRoot 'fresh\BlizzMove.toc'
    Assert-ThrowsLike -Pattern '*filename must be manifest.json*' `
        -FailureMessage 'A manifest path colliding with a fixed backup filename was not refused.' -Operation {
            & $tool -Action Install -WowFlavorPath $flavor -AccountName $accountName `
                -BackupRoot $collisionBackupRoot -ManifestPath $collisionManifestPath
        }
    if (Test-Path -LiteralPath (Split-Path -Parent $collisionManifestPath)) {
        throw 'Rejected colliding ManifestPath created a backup directory.'
    }

    $traversalBackupRoot = Join-Path $fixture 'manifest-traversal-backups'
    $outsideBackupTarget = Join-Path $fixture 'outside-backup-target'
    New-Item -ItemType Directory -Path $traversalBackupRoot, $outsideBackupTarget | Out-Null
    $traversalJunction = Join-Path $traversalBackupRoot 'existing-junction-to-outside'
    New-Item -ItemType Junction -Path $traversalJunction -Target $outsideBackupTarget | Out-Null
    $traversalManifest = Join-Path $traversalJunction 'fresh\manifest.json'
    Assert-ThrowsLike -Pattern '*contains a reparse point*' `
        -FailureMessage 'ManifestPath traversal through an existing junction was not refused.' -Operation {
            & $tool -Action Install -WowFlavorPath $flavor -AccountName $accountName `
                -BackupRoot $traversalBackupRoot -ManifestPath $traversalManifest
        }
    if (Test-Path -LiteralPath (Join-Path $outsideBackupTarget 'fresh')) {
        throw 'Rejected junction-traversing ManifestPath wrote outside BackupRoot.'
    }
    [IO.Directory]::Delete($traversalJunction, $false)

    [IO.File]::WriteAllText(
        $toc,
        $originalToc.Replace('## Interface: 16001', '## Interface: 11508'),
        [Text.UTF8Encoding]::new($false)
    )
    Assert-ThrowsLike -Pattern '*packaged WoW Forever BlizzMove.toc*' `
        -FailureMessage 'An alternate-flavor installed TOC was not refused.' -Operation {
            & $tool -Action Install -WowFlavorPath $flavor -AccountName $accountName `
                -BackupRoot $backupRoot
        }
    [IO.File]::WriteAllText(
        $toc,
        $originalToc.Replace(
            '## Interface: 16001',
            "## Interface: @toc-version-forever@`r`n## Interface: 120000"
        ),
        [Text.UTF8Encoding]::new($false)
    )
    Assert-ThrowsLike -Pattern '*source/debug and alternate-flavor TOCs are unsupported*' `
        -FailureMessage 'A source/debug TOC with placeholders was not refused.' -Operation {
            & $tool -Action Install -WowFlavorPath $flavor -AccountName $accountName `
                -BackupRoot $backupRoot
        }

    [IO.File]::WriteAllText(
        $toc,
        $originalToc.Replace('## SavedVariables: BlizzMoveDB', '## SavedVariables: OtherAddonDB'),
        [Text.UTF8Encoding]::new($false)
    )
    Assert-ThrowsLike -Pattern '*declare exactly one account SavedVariables entry for BlizzMoveDB*' `
        -FailureMessage 'A TOC with the wrong SavedVariables declaration was not refused.' -Operation {
            & $tool -Action Install -WowFlavorPath $flavor -AccountName $accountName `
                -BackupRoot $backupRoot
        }

    [IO.File]::WriteAllText($toc, $originalToc, [Text.UTF8Encoding]::new($false))
    Remove-Item -LiteralPath $main -Force
    Assert-ThrowsLike -Pattern '*no client-generated SavedVariables*' `
        -FailureMessage 'An account without a client-generated main database was not refused.' -Operation {
            & $tool -Action Install -WowFlavorPath $flavor -AccountName $accountName `
                -BackupRoot $backupRoot
        }

    # The client-generated main database is required; its optional .bak is not.
    $mainOnlyContent = 'BlizzMoveDB = { points = {}, generation = 3 }'
    [IO.File]::WriteAllText($main, $mainOnlyContent, [Text.UTF8Encoding]::new($false))
    Remove-Item -LiteralPath $bak -Force -ErrorAction SilentlyContinue
    $mainOnlyHash = Get-Hash $main
    $mainOnlyBackupRoot = Join-Path $fixture 'main-only-backups'
    $mainOnlyManifestPath = Join-Path $mainOnlyBackupRoot 'install\manifest.json'
    & $tool -Action Install -WowFlavorPath $flavor -AccountName $accountName `
        -BackupRoot $mainOnlyBackupRoot -ManifestPath $mainOnlyManifestPath | Out-Null
    $mainOnlyManifest = Get-Content -LiteralPath $mainOnlyManifestPath -Raw | ConvertFrom-Json
    if (@($mainOnlyManifest.SavedFiles).Count -ne 1 -or
        (Get-Hash $main) -ne $mainOnlyHash -or
        (Test-Path -LiteralPath (Join-Path (Split-Path -Parent $mainOnlyManifestPath) 'SavedVariables.BlizzMove.lua.bak'))) {
        throw 'Install did not correctly treat the SavedVariables .bak file as optional.'
    }
    & $tool -Action Rollback -WowFlavorPath $flavor -AccountName $accountName `
        -BackupRoot $mainOnlyBackupRoot -ManifestPath $mainOnlyManifestPath | Out-Null
    if ((Get-Hash $main) -ne $mainOnlyHash -or (Test-Path -LiteralPath $bak)) {
        throw 'Main-only rollback created or changed SavedVariables data.'
    }

    Write-Output 'PASS: bridge install, optional .bak, metadata preservation, rotation, TOC/path refusals, and idempotent rollback.'
} finally {
    $resolvedFixture = [IO.Path]::GetFullPath($fixture)
    if ($resolvedFixture.StartsWith($tempRoot + '\', [StringComparison]::OrdinalIgnoreCase) -and
        [IO.Path]::GetFileName($resolvedFixture).StartsWith('blizzmove-saved-bridge-', [StringComparison]::Ordinal)) {
        Remove-Item -LiteralPath $resolvedFixture -Recurse -Force -ErrorAction SilentlyContinue
    }
}
