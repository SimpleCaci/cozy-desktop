# FAQ and troubleshooting

## Do I need administrator access?

Use your normal account. The default install writes current-user settings and
files. A protected custom install path or a managed PC may block it. Running as
administrator is not a supported workaround for organization policy.

## Which download should I use?

Preview release ZIPs include the source-drawn Starter theme, the button executable,
scripts and a `START-HERE.md` guide. Extract everything together. GitHub's automatic
“Source code” archives are repository snapshots, not the same packaged build.
Those snapshots retain Sunbeam Kitty's unresolved artwork references.

## Why is Sunbeam Kitty still in the repo but not in release ZIPs?

The original artwork was generated using image references, reportedly from
Pinterest, without a recorded creator or permission. It stays while the source is
investigated, as the owner prefers. Starter is drawn from source code and is the
theme packaged for redistribution. [Asset audit](ASSET-AUDIT.md).

## Does it run all the time?

The button and its PowerShell process exit after switching. Optional scheduling
uses Windows Task Scheduler. There are no CPU/RAM or gaming benchmarks, and no
claim of zero resource use.

## Why did the wallpaper change but an icon did not?

Windows caches icons and some special views use built-in artwork. Reopen the
folder or sign out/in. The toolkit does not restart Explorer for you. Include your
Windows build and the affected view in a bug report; a registry write succeeding
does not prove that every shell view will display it.

## The Recycle Bin stays on one picture

The current implementation keeps empty/full state mappings in Explorer and backs
up/removes a competing static class override. Older versions wrote both locations.
If the display still sticks after updating and reopening Explorer, report the
version and whether the bin contains items. Never empty personal files just to
test an icon.

## A folder cannot be customized

The folder must exist and be writable. Symlinks, junctions, drive roots and linked
`desktop.ini` files are rejected. Cloud-only folders or unusual permissions can
also block the change. A special shell tile may ignore `desktop.ini` even when a
normal folder window displays the icon.

## PowerShell or Windows blocks the install

Check that you extracted the full archive, have Windows PowerShell 5.1/.NET
Framework available, and are using a normal user-writable location. The documented
process-scoped execution policy does not override organization policy. Unsigned
previews can be blocked; do not disable Windows security protections to run them.

## Can I install again or change the schedule?

Reset the current installation first. Keep its files until reset succeeds, then
remove the restored installation yourself or choose a new empty install path.
Change `config.json` before the next installation. The installer does not overwrite
an existing install folder or its desktop button names.

## Does reset return factory-default Windows?

It restores the tracked settings as they were before Cozy Desktop changed them.
It does not capture every appearance setting or a slideshow's playback state.
Keep original wallpaper files and reconnect themed monitors. [Exact backup scope](SAFETY.md).

## Reset failed halfway through

Keep the installed toolkit and `.state` backup. Fix the reported missing file,
folder or monitor, then retry the same reset command. Earlier restoration steps
may already have run; the backup is archived only after the function finishes.
Never upload the backup to a public issue.

## Can I change themes after installing?

Theme assets stay in the installed folder because Windows refers to those paths.
For a different theme, reset first and configure the new theme before reinstalling.
There is not yet a graphical theme importer or picker. [Theme guide](THEMES.md).
