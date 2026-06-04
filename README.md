# WinRecoveryFix

Run **once** after a fresh Windows install (as Administrator).  
Sets up `C:\Recovery\OEM\` so **Reset PC → Remove everything** always skips the online account screen and boots straight into a local account — no Microsoft account required, ever.

> These files survive every future reset. You never need to run this again.

---

## What it does

Places three files into `C:\Recovery\OEM\`:

| File | Purpose |
|---|---|
| `ResetConfig.xml` | Tells Windows Reset to run `Restore.cmd` after re-imaging |
| `Restore.cmd` | Copies `unattend.xml` and sets registry keys to bypass NRO |
| `unattend.xml` | Skips all OOBE screens, auto-creates local account `User` with no password |

After reset, Windows boots straight to the desktop — no internet screen, no account prompts. The local account `User` is created with an empty password. You can set a password afterwards via Settings.

---

## Usage

### Option A — Run locally (recommended)

1. Download or clone this repo
2. Open **PowerShell as Administrator**
3. Run:

```powershell
powershell -ExecutionPolicy Bypass -File setup-recovery-oem.ps1
```

### Option B — Run directly from the web

Open **PowerShell as Administrator** and run:

```powershell
irm "https://raw.githubusercontent.com/techvalleyapps/WinRecoveryFix/main/setup-recovery-oem.ps1" | iex
```

---

## Requirements

- Windows 10 / 11
- Must run as **Administrator**
- PowerShell 5.1+ (built into Windows)

---

## After running

Go to **Settings → System → Recovery → Reset this PC → Remove everything**.  
Windows will skip all setup screens and boot straight to the desktop as local account `User` with no password. You can rename the account or set a password afterwards in Settings.

---

## Customising

The account is auto-created as `User` with no password — no prompts at all after reset.

To change other defaults, edit the script before running:

- **Computer name** — `<ComputerName>WIN11-PC</ComputerName>`
- **Locale / timezone** — `en-GB` / `GMT Standard Time`

---

## Notes

- `C:\Recovery` is a protected system folder. The script takes ownership automatically.
- The script sets `C:\Recovery` back to hidden+system after writing files.
- Safe to re-run if something went wrong — it overwrites existing files.
