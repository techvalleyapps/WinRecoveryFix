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
| `unattend.xml` | Creates local account `User / 1233`, sets en-GB locale, auto-login |

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
On next boot after reset you will get a local account (`User`, password `1233`) — no online account prompt.

---

## Customising

Edit the `unattend.xml` section inside the script before running to change:

- **Computer name** — `<ComputerName>WIN11-PC</ComputerName>`
- **Username / password** — `<Name>User</Name>` / `<Value>1233</Value>`
- **Locale / timezone** — `en-GB` / `GMT Standard Time`

---

## Notes

- `C:\Recovery` is a protected system folder. The script takes ownership automatically.
- The script sets `C:\Recovery` back to hidden+system after writing files.
- Safe to re-run if something went wrong — it overwrites existing files.
