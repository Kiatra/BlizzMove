---
author: Neil Mitchell
creator: Neil Mitchell
last_modified_by: Neil Mitchell
date: 2026-09-20
---

# Forever follow-up: full change accounting

Comparison baseline: upstream **v3.8.0**, commit
`9823699188c3596d6d5db9248ec2981815dbeddb` (initial WoW Forever support).
The working personal adaptation started from v3.7.43. This proposal is rebuilt
on v3.8.0; it does not replace the current version framework with the older fork.

Target observed in game: **WoW Forever beta 1.60.1, build 69913, interface 16001**.
This is a review proposal, not a claim that every upstream issue or every beta
client is fixed. The v3.8.0 port still needs in-game acceptance.

## Changes added to current upstream

### Position capture and restoration

- Start upstream's existing global mouse-release listener when a Forever drag
  starts. This records the final position even when the originating frame does
  not receive `OnMouseUp`.
- Observe `SetPointBase` as well as `SetPoint` on Forever when that method exists.
  The beta panel manager can move a window without triggering the usual hook.
- On Forever `OnShow`, queue a saved, dragged permanent position again. Respect
  attached-child and maximized-frame exclusions; leave session/off preferences
  and non-Forever behavior alone.
- Defer Forever initialization by one frame, retaining the normal database
  assignment and migration logic. This reduces initialization timing problems;
  it does **not** repair the client's failure to load saved data after restart.
- Default missing Forever position and scale preferences to `permanent`.
  Preserve existing explicit preferences. Other clients retain session defaults.
- Fix a shared combat-queue bug: a call made outside combat now executes once
  and returns, instead of also entering the queue for a second execution later.

### Group Finder drag surface

- Force a shared title-bar handle for Forever's `LFGParentFrame`, so Listing,
  Browse and Who List move the same parent. Keep Classic registrations unchanged.
- Limit the handle to the title strip, leaving the portrait and close button
  available for their normal interactions.
- Set its frame level above all available native page title containers. This
  addresses Browse being frozen on first opening until another tab is selected.
- Defer processing of forced-handle frames in combat, including an unprotected
  parent that still requires a secure handle. Reuse existing reprocessing logic
  to retain storage/hooks and retire an old handle.

### Exact-build native UI workarounds

These three workarounds require version `1.60.1`, build `69913`, interface `16001`.
They intentionally do not activate on a future beta without another audit.

- **Browse visual recovery:** after the native Group Finder addon loads, defer
  one frame and finish the missing portrait, title and inset setup only when
  the real Who page exists, modern style is selected, an active listing exists,
  and Browse's title is empty. Refresh native tabs/portrait and handles outside
  combat. Do not create a dummy Who frame or replay the active-entry search.
- **Narrow error display filter:** hide only the built-in popup/history entry
  matching the known line-29 nil-`LFGWhoListFrame` error, native Browse/active-entry
  load stack, and still-loading addon state with Who absent. Preserve other
  errors, other builds, inaccessible values, original call arguments/returns,
  native backend logging and other error handlers. Do not change `scriptErrors`.
  `BlizzMove.foreverLFGSuppressedErrors` is an unsaved diagnostic count. This
  suppresses a known symptom; it does not fix Blizzard's XML load order.
- **Barbershop mouse/keyboard guard:** wrap `UpdateSmallButtons` on the real
  `CharCustomizeFrame` instance only when attached to `BarberShopFrame`. Skip the
  character-creation name-box collision check there, retaining XML anchors;
  forward other calls. Install outside combat, including after late loading.
  Do not invent `CharacterCreateFrame`, change a shared mixin, or replace
  Blizzard files. Controller navigation is outside the validated scope.

### Frame registration

- Register Forever's `Blizzard_LegacySystem` / `LegacySystemFrame`.
- Keep the current modern achievement `SearchResults` spelling and existing
  professions registrations. Do not register the nonexistent standalone
  `ProfessionsBookFrame` on Forever; its overview is within `ProfessionsFrame`.
- Do not disable all compatibility warnings to mask missing-frame registrations.

### Credit, tests and distribution

- Add `Lau [WoW Forever edits]` in the options donation area, visible only on
  Forever. It uses the existing copy-URL popup with
  <https://streamlabs.com/lausudo/tip>. Preserve Kiatra and Numy's names, buttons,
  and exact PayPal URLs. This is a proposed credit, subject to maintainer review.
- Add portable Lua 5.1 behavioral tests using Python/Lupa, plus whole-project
  Lua syntax and option callback checks. Test other-client/build exclusions.
- Add an optional Windows SavedVariables bridge helper, rollback manifest and
  isolated filesystem regression tests; see [setup and limits](FOREVER-PERSISTENCE.md).
- Add pull-request CI for Lua tests and Windows bridge tests. Preserve the
  existing release packaging workflow. Exclude docs, tests, tools and test
  dependencies from addon packages.
- Keep upstream's multi-flavor TOC, project IDs, version packaging tokens, icon,
  author metadata, libraries and API/version framework intact.

## Differences from the earlier local v3.7.43 adaptation

| Earlier local difference | Treatment in this v3.8.0 proposal |
| --- | --- |
| Single interface `16001` TOC and `X-Forever-Adapted` marker | Superseded by upstream's native Forever detection and multi-flavor packager TOC. No private marker required. |
| Avoiding `SecureHandlerBaseTemplate:Execute` on Forever because its secure snippet compiler was absent | Already in v3.8.0; retained unchanged, not claimed as new. |
| Explicit numeric Forever ranges for modern bags, Player Spells, Hero Talents, professions and achievement frames | Current upstream's version/family framework already selects these. Preserve that framework instead of copying old range edits. |
| v3.7.43's numeric range API/types | Adopt current v3.8.0's `BlizzMoveAPI.Versions`, `GetGameVersion()` and `Types.lua` support for `Versions` registrations unchanged. These are upstream additions since the old base, not new features authored in this proposal. |
| Legacy System registration | Still missing upstream; included here. |
| Local refreshed TGA icon and icon-path metadata | Cosmetic local-only difference, excluded from this upstream fixes proposal. Upstream icon retained. |
| Release-package debug blocks already commented out | Keep upstream source debug markers and let its existing packager process them; do not copy generated release formatting back into source. |
| Blanket Forever compatibility-warning suppression | Excluded. Keep meaningful upstream warnings. |
| Temporary `/bm positioncheck` instrumentation | Removed from the final local build and not introduced here. |
| Earlier dummy-Who experiment / active-search replay | Rejected during diagnosis; absent from the final working build and this proposal. It broke the real Who page. |
| Session-only SavedVariables file workaround | Superseded by the optional restart bridge. No file-deletion workaround is shipped. |
| Account-specific junction and extra TOC load line | Never committed or packaged. A manual, parameterized helper offers the same mechanism with backups and rollback. |
| Lau credit and Streamlabs URL | Included as a Forever-only options entry, retaining original author links. |
| Local installer, ZIP, backups, private manifests and saved coordinates | Excluded from this repository and addon package. |
| Separate DBM compatibility work | Outside BlizzMove; no DBM code or filters included here. |

## Known limitations: fixed, mitigated and remaining

| Limitation | Status and evidence boundary |
| --- | --- |
| Missing final drag coordinates | Global-release capture included. Accepted in the local build; rebased production functions covered by tests. |
| Windows snapping back on reopen despite permanent storage | `SetPointBase` and `OnShow` restoration included. All windows tested by the user stayed in the local build; this is not a claim to resolve every report of snapping on every client. |
| Frozen initial Group Browser and missing eye/title | Shared handle and deferred visual recovery included; accepted in the local beta build. |
| Nil Who error during native addon load | Precisely filtered in Blizzard's error display only. Native load-order bug remains; deferred visual recovery mitigates its UI effects. |
| Saved positions disappear on full beta restart | Optional account-specific Windows bridge survived `/reload` and a full restart in the local installation. Ordinary Lua initialization alone cannot guarantee this. No bridge is installed automatically. |
| Barbershop nil CharacterCreateFrame error | Exact-build mouse/keyboard path guarded; local user accepted the fix. Controller behavior unverified. |
| Duplicate combat-queue execution outside combat | Fixed in this proposal and covered by behavioral tests. |
| Protected frame operations in combat | Native restriction remains. Processing waits for combat to end. |
| Separate individual bags | Not added; existing combined-bag and current registration behavior retained. |
| Blizzard panel auto-closing / automatic layout policy | Not globally disabled or rewritten. |
| Retail world-map rescaling and unrelated open upstream issues | Not addressed or claimed fixed. No unrelated issue is auto-closed. |
| Multi-account, non-Windows or future-build restart behavior | Not established by this local test. The optional bridge binds one account; remove/rebind before account switching and re-audit after beta changes. |
| Addon updates | Can replace the local bridge's TOC line or directory. Re-check setup after updates; rollback refuses unexpected TOC changes. |
| Adapted CurseForge publication | Permission is requested from the maintainers. No license grant, approval or separate publication is claimed. |

## Validation and acceptance

Local v3.7.43 adaptation: the user verified normal Who List, first-open dragging,
visual recovery, unrelated Lua errors remaining visible, barbershop operation,
and all tested windows retaining positions after `/reload` and a full client
restart with the account bridge installed. These are observations from that
local installation, not universal beta guarantees.

This v3.8.0 proposal passes 25 portable Lua 5.1 tests (including project syntax
and config callbacks), isolated Windows bridge fixtures, and the diff whitespace
check. Core and bridge review found no remaining concrete blockers after fixing
manifest-name collisions and reparse-path checks. These checks do not access a
live client or real account data. They
cannot prove secure-frame behavior or game rendering. Before merging/releasing,
test this exact port in game: first-open active-listing Group Finder, all three
tabs, dragging/reopening representative windows, `/reload`, combat deferral,
an unrelated error control, barbershop mouse/keyboard, and a full restart only
when verifying the optional bridge. Other-client smoke tests remain necessary.

Sources: [upstream v3.8.0](https://github.com/Kiatra/BlizzMove/releases/tag/v3.8.0)
and the [reported beta SavedVariables loading failure](https://eu.forums.blizzard.com/en/wow/t/addon-savedvariables-never-load-on-160169893/629799).
The latter describes build 69893; the local restart observation above is 69913.
