# gi - git for fast fingers

> "I meant to type `git add` but my fingers had other plans" — Every developer, daily

Ever type `gi tadd` instead of `git add`? Your fingers were moving at the speed of thought, but that pesky `t` from `git` got attached to your command. **gi** understands your pain and fixes it.

```bash
$ gi tadd .
gi: running git add .    # gi's got your back

$ gi tcommit -m "fix bug"
gi: running git commit -m "fix bug"    # no judgement here

$ gi psuh origin main
gi: running git push origin main    # we've all been there
```

## Why gi?

Because your keyboard can't keep up with your caffeine-fueled typing speed:

```
git add .     # What you meant
gi tadd .     # What actually happened at 2am
```

**gi** recognizes this pattern (and 100+ other typos that happen when you're in the zone) and runs the correct git command. It's like autocorrect, but for people who know what they're doing and just have rebellious fingers.

## Installation

### Linux / macOS (Manual)

```bash
# Download the script
curl -o gi https://raw.githubusercontent.com/tomhudak/gi/main/gi

# Make it executable
chmod +x gi

# Move to a directory in your PATH
sudo mv gi /usr/local/bin/
```

### macOS / Linux (Quick Install)

```bash
curl -sSL https://raw.githubusercontent.com/tomhudak/gi/main/gi | sudo tee /usr/local/bin/gi > /dev/null && sudo chmod +x /usr/local/bin/gi
```

### Windows

```powershell
# Create a directory for scripts (if it doesn't exist)
New-Item -ItemType Directory -Force -Path "$HOME\bin"

# Download both files
Invoke-WebRequest -Uri "https://raw.githubusercontent.com/tomhudak/gi/main/gi.ps1" -OutFile "$HOME\bin\gi.ps1"
Invoke-WebRequest -Uri "https://raw.githubusercontent.com/tomhudak/gi/main/gi.cmd" -OutFile "$HOME\bin\gi.cmd"

# Add to PATH (run once, then restart your terminal)
[Environment]::SetEnvironmentVariable("Path", $env:Path + ";$HOME\bin", "User")
```

After restarting your terminal, `gi` works globally from cmd, PowerShell, or Windows Terminal.

**Using Git Bash:**
```bash
curl -o ~/bin/gi https://raw.githubusercontent.com/tomhudak/gi/main/gi
chmod +x ~/bin/gi
```

### From Source

```bash
git clone https://github.com/tomhudak/gi.git
cd gi
sudo cp gi /usr/local/bin/
sudo chmod +x /usr/local/bin/gi
```

## Usage

Just use `gi` like you would use `git`:

```bash
gi status          # Works normally
gi tadd .          # Corrects to: git add .
gi tcommit -m "x"  # Corrects to: git commit -m "x"
gi psuh            # Corrects to: git push
gi stauts          # Corrects to: git status
```

### Options

```bash
gi --help          # Show help
gi --version       # Show version
gi --list-typos    # List all known typo corrections
```

### Environment Variables

| Variable | Description |
|----------|-------------|
| `GI_QUIET=1` | Don't show "gi: running git ..." messages |
| `GI_NO_COLOR=1` | Disable colored output |

```bash
# Silent mode - just run the corrected command
GI_QUIET=1 gi tadd .

# Or export for your session
export GI_QUIET=1
```

### Replace git with gi (recommended)

To get typo correction for **all** your git commands (including `git addd`, `git comit`, etc.), alias `git` to `gi`:

**Bash** (~/.bashrc):
```bash
alias git='gi'
```

**Zsh** (~/.zshrc):
```bash
alias git='gi'
```

**Fish** (~/.config/fish/config.fish):
```fish
alias git='gi'
```

**PowerShell** ($PROFILE):
```powershell
Set-Alias -Name git -Value gi
```

After adding the alias, reload your shell:
```bash
source ~/.bashrc  # or ~/.zshrc, or restart PowerShell
```

Now typo correction works everywhere:
```bash
$ git addd .
gi: running git add .

$ git comit -m "fix"
gi: running git commit -m "fix"
```

## Supported Typos

### The "t" Prefix (main feature)

When you type `gi t<command>` instead of `git <command>`:

| Typo | Corrected |
|------|-----------|
| `tadd` | `add` |
| `tbranch` | `branch` |
| `tcheckout` | `checkout` |
| `tcommit` | `commit` |
| `tdiff` | `diff` |
| `tfetch` | `fetch` |
| `tlog` | `log` |
| `tmerge` | `merge` |
| `tpull` | `pull` |
| `tpush` | `push` |
| `trebase` | `rebase` |
| `treset` | `reset` |
| `tstash` | `stash` |
| `tstatus` | `status` |
| ... and more |

### Swapped/Transposed Letters

| Typo | Corrected |
|------|-----------|
| `psuh` | `push` |
| `puhs` | `push` |
| `stauts` | `status` |
| `comit` | `commit` |
| `chekcout` | `checkout` |
| `brnach` | `branch` |
| `cloen` | `clone` |
| ... and more |

### Double Letters

| Typo | Corrected |
|------|-----------|
| `addd` | `add` |
| `committ` | `commit` |
| `pussh` | `push` |
| `pulll` | `pull` |
| ... and more |

### Short Aliases

| Shortcut | Corrected |
|----------|-----------|
| `st` | `status` |
| `co` | `checkout` |
| `ci` | `commit` |
| `br` | `branch` |
| `df` | `diff` |
| ... and more |

Run `gi --list-typos` to see all 100+ supported corrections.

## Uninstallation

**Linux / macOS:**
```bash
sudo rm /usr/local/bin/gi
```

**Windows:**
```powershell
Remove-Item "$HOME\bin\gi.ps1", "$HOME\bin\gi.cmd"
```

## FAQ

**Q: Does gi work with all git commands and options?**
A: Yes! Any command or option not in the typo list is passed directly to git unchanged. gi doesn't judge your exotic git flags.

**Q: Will gi slow down my git commands?**
A: No. gi is a simple bash script. The only thing slower than gi is you typing `git` correctly.

**Q: Can I add my own typo corrections?**
A: Yes! Edit the `TYPO_MAP` in the script. We all have our own special typos we're ashamed of.

**Q: Does gi modify my git configuration?**
A: No. gi just wraps git commands - it's a helpful middleman, not a control freak.

## Contributing

Found a typo that's not covered? Open an issue or PR!

```bash
# Fork and clone
git clone https://github.com/YOUR_USERNAME/gi.git

# Add your typo to the TYPO_MAP in the gi script
# Test it
./gi your-typo

# Submit a PR
```

## License

MIT License - see [LICENSE](LICENSE)

## Related Projects

- [thefuck](https://github.com/nvbn/thefuck) - Corrects your previous console command
- [git-extras](https://github.com/tj/git-extras) - Git utilities

---

Made with ❤️ by [tomhudak](https://github.com/tomhudak)
