---
author: Neil Mitchell
creator: Neil Mitchell
last_modified_by: Neil Mitchell
date: 2026-09-20
---

# Optional Windows workaround for the Forever SavedVariables loading bug

Use this only for a Forever beta installation where BlizzMove writes its saved
database to disk but the client fails to load it on restart. First select
**Remember Permanently** for positions/scales, move a window and use `/reload`.
An ordinary session preference or a frame-specific movement problem does not
justify installing a filesystem workaround.

On the tested 1.60.1.69913 installation, ordinary addon initialization received
an empty database even though the saved file held the coordinates. Loading that
same file as a TOC script before the core restored persistence. The user then
confirmed all tested positions survived `/reload` and a full client restart.
This establishes a local workaround, not a fix to Blizzard's loader or a promise
for later builds. See also the [earlier build's loading bug report](https://eu.forums.blizzard.com/en/wow/t/addon-savedvariables-never-load-on-160169893/629799).

## What the helper changes

`tools/Manage-ForeverSavedVariablesBridge.ps1` is a manual Windows developer tool,
excluded from the addon package. It requires an explicit client-flavor folder,
account folder name and backup directory.

It creates this directory junction inside the installed addon:

```text
Interface\AddOns\BlizzMove\ForeverSavedVariables
    -> WTF\Account\<your-account-folder>\SavedVariables
```

It adds `ForeverSavedVariables\BlizzMove.lua` before `BlizzMove.lua` in the
installed `BlizzMove.toc`, while retaining `## SavedVariables: BlizzMoveDB`.
The client remains responsible for writing the database normally. A directory
junction follows the current filename even when the client rotates `.lua` to
`.lua.bak` and creates a fresh file; a hard link to one file would not do that.

The helper backs up the TOC and existing saved-data files, records hashes and
checks for concurrent changes before installation. It does not edit or replace
the saved coordinates, change Blizzard files, install a background process,
change system security settings, or close the client.

## Setup

1. Use `/reload` to flush the positions you want to retain. Identify the **exact
   Forever flavor folder** and the matching account directory under `WTF\Account`.
   Do not guess from another retail/classic installation.
2. Run the helper in PowerShell with your actual paths. The example names below
   are placeholders. Put backups outside the addon and account-data directories.

```powershell
./tools/Manage-ForeverSavedVariablesBridge.ps1 -Action Install `
    -WowFlavorPath 'C:\Games\World of Warcraft\_classic_beta_' `
    -AccountName 'YOUR-ACCOUNT-FOLDER' `
    -BackupRoot 'D:\AddonBackups\BlizzMove-Forever'
```

3. Keep the printed backup manifest path. If a concurrent save is detected,
   inspect the reported state rather than discarding the backup or saved files.
4. Use `/reload`, then open the moved windows without dragging them. Confirm
   they return to their saved positions. A full restart is an additional test
   of this particular loader workaround, not a requirement for ordinary Lua
   edits. Run it when convenient if you need restart acceptance.

The tool targets an installed, resolved Forever `BlizzMove.toc`, not a Git
checkout containing packager placeholders. It requires an existing main
`BlizzMove.lua` saved-data file; it is not a database recovery/import utility.

## Rollback

Use the same explicit client/account/backup arguments and the manifest printed
at installation:

```powershell
./tools/Manage-ForeverSavedVariablesBridge.ps1 -Action Rollback `
    -WowFlavorPath 'C:\Games\World of Warcraft\_classic_beta_' `
    -AccountName 'YOUR-ACCOUNT-FOLDER' `
    -BackupRoot 'D:\AddonBackups\BlizzMove-Forever' `
    -ManifestPath 'D:\AddonBackups\BlizzMove-Forever\<backup>\manifest.json'
```

Rollback restores the original TOC and removes only the checked junction. It
never restores an old copy over newer saved coordinates or deletes the target
directory. Unexpected TOC or link changes cause a refusal so an addon update
or another account's data is not overwritten. Use `/reload` after rollback.

## Limits and precautions

- **One account only:** the installed TOC points at the selected account's data.
  Remove the bridge before using a different account in this client installation.
  Otherwise it can load the selected account's database into that other account's
  session. This is not an account-switching solution.
- **Windows filesystem setup:** a directory junction must be supported by the
  destination volume. No macOS/Linux implementation is supplied or validated.
- **Updates:** replacing the addon can remove the extra TOC line or junction.
  Inspect and reinstall deliberately after updates; do not blindly copy a
  modified addon directory to another computer or account.
- **Data trust:** the helper loads the same client-generated Lua file the addon
  normally declares as SavedVariables. It does not validate arbitrary imported
  Lua or establish that an unknown saved file is safe to execute.
- **No bundled personal state:** never distribute the junction, backups,
  manifest, account directory names or saved database. They are deliberately
  absent from this repository and addon release packages.
- **Beta scope:** retest after client changes and remove the workaround when the
  native loader works reliably. No claim is made that initialization delay,
  a TOC flag, or this helper resolves all persistence failures on all clients.

## Developer validation

```powershell
python -m pip install -r requirements-test.txt
python -m unittest discover -s tests -p 'test_*.py' -v
./tests/test_saved_variables_bridge.ps1
```

The Windows tests create synthetic client data in a temporary directory, call
the real helper, exercise rotation and rollback, and check refusal paths. They
do not operate on a live WoW installation. Filesystem tests do not replace
in-game testing of the rebased addon or the specific beta loader.
