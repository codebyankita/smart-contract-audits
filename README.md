# **Universal Smart Contract Auditing Cockpit**  

 

## ** (30-Second Start)**

```bash
# 1. Clone the cockpit
git clone https://github.com/web3sec/audit-cockpit.git && cd audit-cockpit

# 2. Install everything (Mac/Linux/WSL)
make install

# 3. Audit ANY project
make audit PROJECT=../your-contract-folder
```

Open `report/YYYY-MM-DD-Report.pdf` → **Submit to CodeHawks, Immunefi, or Client.**

---

## **What You’ll Get After Running This**

```
audit-cockpit/
├── report/
│   ├── 2025-11-06-your-project.pdf       ← Final PDF report
│   ├── 2025-11-06-your-project.md        ← Markdown source
│   ├── slither-output.txt                ← Full Slither log
│   ├── report-aderyn.md                  ← Aderyn findings
│   ├── gas-table.md                      ← Forge gas report
│   └── forge.log                         ← Test output
├── findings/
│   ├── S-1-Reentrancy.md
│   ├── S-2-Weak-RNG.md
│   └── _template.md                      ← Cyfrin-standard layout
├── src/                                  ← Your target contracts
├── test/                                 ← Your PoC tests
└── script/generate-report.sh             ← Auto-generates everything
```

---

## **Who Is This For?**

| You | This Cockpit Helps You |
|-----|------------------------|
| **New Auditor** | Step-by-step install + explanations |
| **Competitive Auditor** | CodeHawks-ready PDF in 1 click |
| **Freelancer** | Client-ready branded report |
| **Security Researcher** | Reproducible, publishable findings |

---

## **Step-by-Step: Full Installation (Beginner-Friendly)**

> **Works on Mac, Linux, WSL2 (Windows).**

---

### **Step 1: Install System Dependencies**

```bash
# Mac (Homebrew)
brew install git python3 jq pandoc texlive-latex-extra

# Ubuntu/Debian
sudo apt update && sudo apt install -y git python3-pip jq pandoc texlive-latex-extra

# WSL2 (Ubuntu)
sudo apt update && sudo apt install -y git python3-pip jq pandoc texlive-latex-extra
```

> **Why?**  
> - `git` → Clone repos  
> - `python3` → Slither  
> - `jq` → Parse JSON output  
> - `pandoc` + `texlive` → Generate PDF reports

---

### **Step 2: Install Foundry (Ethereum Dev Toolkit)**

```bash
curl -L https://foundry.paradigm.xyz | bash
source ~/.bashrc
foundryup
```

> **Verify:**
```bash
forge --version  # → forge 0.2.0
cast --version   # → cast 0.2.0
anvil --version  # → anvil 0.2.0
```

> **What is Foundry?**  
> - **Forge**: Write & run tests  
> - **Cast**: CLI for contracts  
> - **Anvil**: Local Ethereum node  
> - **Chisel**: Solidity REPL

---

### **Step 3: Install Slither (Static Analyzer)**

```bash
pipx install slither-analyzer
```

> **Verify:**
```bash
slither --version  # → 0.10.0
```

> **What does Slither do?**  
> - Detects 100+ vulnerabilities automatically  
> - Outputs `slither-output.txt`  
> - Used by Trail of Bits, ConsenSys, OpenZeppelin

---

### **Step 4: Install Aderyn (Rust-based Analyzer)**

```bash
# Mac (Homebrew)
brew install cyfrin/tap/aderyn

# Or via npm
npm i -g @cyfrin/aderyn
```

> **Verify:**
```bash
aderyn --version  # → aderyn 0.1.6
```

> **Why Aderyn?**  
> - Faster than Slither  
> - Focuses on *real* bugs  
> - Outputs `report-aderyn.md`

---

### **Step 5: Install cloc (Code Line Counter)**

```bash
# Mac
brew install cloc

# Linux
sudo apt install cloc
```

> **Verify:**
```bash
cloc --version  # → 1.98
```

> **Why?**  
> - Shows **nSLOC**, **Complexity**  
> - Required for audit scoping

---

### **Step 6: Install Pandoc Template (PDF Reports)**

```bash
# Create templates folder
mkdir -p ~/.pandoc/templates

# Download Eisvogel (professional LaTeX template)
curl -L https://raw.githubusercontent.com/Wandmalfarbe/pandoc-latex-template/master/eisvogel.tex -o ~/.pandoc/templates/eisvogel.latex
```

> **Add Your Logo (Optional)**
```bash
cp your-logo.pdf ~/.pandoc/templates/logo.pdf
```

---

### **Step 7: Clone & Setup the Cockpit**

```bash
git clone https://github.com/web3sec/audit-cockpit.git
cd audit-cockpit
```

---

### **Step 8: One-Click Install All Tools**

```bash
make install
```

> **This does everything above in one command.**

---

## **How to Audit ANY Contract (Step-by-Step)**

---

### **Step 1: Drop In Your Target Project**

```bash
make audit PROJECT=../puppy-raffle
# or
make audit PROJECT=../thunder-loan
# or
make audit PROJECT=../my-dex
```

> **What happens?**
> - Copies `src/` and `test/`  
> - Runs `forge build`  
> - Runs `slither`, `aderyn`, `cloc`  
> - Generates gas report  
> - Creates `report/` folder

---

### **Step 2: Run Static Analysis**

```bash
# Slither (100+ detectors)
slither . --exclude-dependencies > report/slither-output.txt

# Aderyn (fast, accurate)
aderyn . > report/report-aderyn.md
```

---

### **Step 3: Write Findings (Cyfrin Standard)**

```bash
cp findings/_template.md findings/S-1-Reentrancy.md
code findings/S-1-Reentrancy.md
```

#### **Finding Template (Copy-Paste)**

```markdown
### [S-1] Reentrancy in withdraw() (Critical)

**Severity:** High  
**Lines:** src/PuppyRaffle.sol:120-135  
**Detector:** `reentrancy-eth`

**Description:**  
`withdraw()` sends ETH before updating balance.

**Impact:**  
Attacker can drain entire contract.

**Proof of Concept:**
```solidity
function test_Reentrancy() public {
    Attacker a = new Attacker(target);
    a.attack{value: 1 ether}();
    assertEq(address(target).balance, 0);
}
```

**Recommended Mitigation:**
```solidity
balance[msg.sender] -= amount;
(bool s,) = msg.sender.call{value: amount}("");
require(s);
```
**Fixed in:** `abc123`

### **Step 4: Generate Final Report (PDF + MD)**

```bash
./script/generate-report.sh
```

> **Outputs:**
> - `report/2025-11-06-your-project.md`  
> - `report/2025-11-06-your-project.pdf` (via Pandoc)

---

### **Step 5: Publish Like a Pro**

```bash
# Commit & push
git add .
git commit -m "audit: complete - 3 findings"
git push

# Tweet
echo "Just shipped a full audit using @web3sec cockpit! PDF ready in 5 mins. https://github.com/yourname/audit"
```

---

## **Professional Report Structure (Auto-Generated)**

```markdown
# Smart Contract Security Audit Report

**Date:** 2025-11-06  
**Auditor:** YOUR_NAME_HERE  
**Client:** [Optional]  
**Tools:** Foundry, Slither, Aderyn, cloc

## Summary
- **nSLOC:** 143  
- **Complexity:** 115  
- **Gas Used:** 1.2M avg  
- **Findings:** 3 High, 2 Medium, 1 Gas

## Scope
- **Compiler:** `^0.8.20`  
- **In Scope:** `src/PuppyRaffle.sol`  
- **Out of Scope:** Dependencies

## Findings
- [S-1] Reentrancy in withdraw()  
- [S-2] Weak RNG in selectWinner()  
- [S-3] DoS via unbounded loop

## Raw Outputs
- [Slither Report](slither-output.txt)  
- [Aderyn Report](report-aderyn.md)  
- [Gas Report](gas-table.md)
```

---

## **Tooling Deep Dive**

| Tool | Purpose | Command | Output |
|------|-------|--------|--------|
| **Foundry** | Testing, fuzzing, forking | `forge test -vvv` | `forge.log` |
| **Slither** | 100+ vuln detectors | `slither .` | `slither-output.txt` |
| **Aderyn** | Fast Rust analyzer | `aderyn .` | `report-aderyn.md` |
| **cloc** | LOC & complexity | `cloc src/` | In PDF |
| **Pandoc** | MD → PDF | `pandoc ...` | `report.pdf` |

---

## **VS Code Setup (Pro Workflow)**

```bash
code --install-extension juanblanco.solidity
code --install-extension tintinweb.solidity-visual-auditor
code --install-extension shd101wyy.markdown-preview-enhanced
```

| Shortcut | Action |
|--------|--------|
| `⌘ K V` | Preview Markdown |
| `⌘ T` | Open Terminal |
| `⌘ Shift F` | Search All Files |
| `Ctrl + ↑` | Run Last Command |

---

## **Example Audit Folders (Real-World)**

```
report/
├── 2023-09-01-puppy-raffle.md
├── 2023-09-01-puppy-raffle.pdf
├── CodeHawksPuppyRaffle.md
├── finding_layout.md
├── report-aderyn.md
├── slither-output.txt
└── gas-table.md
```

> **All generated automatically.**

---

## **Bonus: 10 Must-Star Repos**

| Repo | Why |
|------|-----|
| [Foundry Book](https://book.getfoundry.sh) | Official docs |
| [Cyfrin Course](https://github.com/Cyfrin/security-and-auditing-full-course-s23) | Full audit walkthroughs |
| [Aderyn](https://github.com/Cyfrin/aderyn) | Rust analyzer |
| [Slither Docs](https://github.com/crytic/slither/wiki/Detector-Documentation) | All detectors |
| [Solodit](https://solodit.cyfrin.io) | Real bug database |
| [CodeHawks](https://codehawks.com) | Competitive audits |
| [Secure Contracts](https://secure-contracts.com) | Best practices |
| [SC Exploits](https://github.com/Cyfrin/sc-exploits-minimized) | PoC library |
| [Report Template](https://github.com/Cyfrin/audit-report-templating) | PDF generator |
| [This Cockpit](https://github.com/web3sec/audit-cockpit) | You’re here |

---

## **Final Checklist (Before Submit)**

```bash
[ ] forge test -vvv                → 0 failures
[ ] slither . --checklist          → 0 HIGH
[ ] aderyn .                       → report exists
[ ] cloc src/                      → < 5k LOC
[ ] findings/ has ≥ 1 real bug
[ ] report/*.pdf rendered
[ ] git commit -m "audit: complete"
```

---

## **You Are Now a Professional Auditor**

1. Run `make audit PROJECT=../your-contract`  
2. Write 1 finding  
3. Run `./script/generate-report.sh`  
4. Open `report/2025-11-06-*.pdf`  
5. Submit to **CodeHawks**, **Immunefi**, or **Client**

> **Tweet your first audit:**  
> _"Just shipped my first pro audit using the Universal Audit Cockpit. PDF in 5 mins. No excuses."_  
> → Link to your repo

---

**Happy hacking. Stay paranoid. Ship secure.**  



steps for proper auditing 
1.scopping
2.recon



✅ Final Fix — Make 5-t-swap-audit a normal folder

Run these exact commands in order from inside your main repo (smart-contract-audit):

# 1. Completely remove it from Git’s tracking index (no data loss)
git rm -r --cached 5-t-swap-audit

# 2. Remove any leftover Git metadata from inside that folder
rm -rf 5-t-swap-audit/.git
rm -rf 5-t-swap-audit/.gitmodules

# 3. Add the cleaned folder again
git add 5-t-swap-audit

# 4. Commit and push it as a normal directory
git commit -m "fix: include 5-t-swap-audit as a normal folder (not submodule)"
git push origin main


🧩 Tip for future audits

Whenever you clone an audit repo (like from Cyfrin or your own), do this before adding it to your main repo:

git clone https://github.com/Cyfrin/5-t-swap-audit.git
rm -rf 5-t-swap-audit/.git