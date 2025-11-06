

# 🧠 Smart Contract Auditing Setup & Workflow Guide

### (Universal Auditing Handbook for Beginners → Professionals)

---

## 🚀 Purpose

This document is a **complete end-to-end guide** for setting up, running, and understanding the **smart contract auditing process**, based on Cyfrin’s *Smart Contract Security, Auditing, Assembly, and DeFi Course* and practical debugging experience.

Use this as your **one-stop reference** whenever you start a new audit or review project.

---

## 🧩 Table of Contents

1. [🛠️ Prerequisites](#️-prerequisites)
2. [⚙️ Environment Setup](#️-environment-setup)
3. [📦 Installing Essential Tools](#-installing-essential-tools)
4. [🔍 Static Analysis Tools](#-static-analysis-tools)
5. [💣 Common Solidity Exploits](#-common-solidity-exploits)
6. [🧪 Testing & Fuzzing](#-testing--fuzzing)
7. [📊 Metrics & Code Structure](#-metrics--code-structure)
8. [📘 General Audit Workflow](#-general-audit-workflow)
9. [🧾 Writing Audit Reports](#-writing-audit-reports)
10. [📚 Continuous Learning Resources](#-continuous-learning-resources)

---

## 🛠️ Prerequisites

Before auditing, make sure you understand:

* Solidity basics (variables, functions, modifiers)
* Foundry test framework (`forge`)
* Ethereum transactions & gas model
* Git & Markdown

**Tools you should already have or install:**

* [VS Code](https://code.visualstudio.com)
* [Git](https://git-scm.com/)
* [Foundry](https://book.getfoundry.sh/)
* [Node.js](https://nodejs.org/)
* [Python 3](https://www.python.org/)
* [Rust (cargo)](https://www.rust-lang.org/tools/install)
* [Homebrew (Mac)](https://brew.sh/)
* **AI Helper (ChatGPT, Phind, etc.)**

---

## ⚙️ Environment Setup

### 1️⃣ Install Foundry (forge, cast, chisel)

```bash
curl -L https://foundry.paradigm.xyz | bash
foundryup
```

Check:

```bash
forge --version
cast --version
```

---

### 2️⃣ Initialize or Clone an Audit Project

Example (Cyfrin Puppy Raffle Audit):

```bash
git clone https://github.com/Cyfrin/4-puppy-raffle-audit.git
cd 4-puppy-raffle-audit
forge build
```

---

### 3️⃣ Fix Missing Libraries (like OpenZeppelin)

If `openzeppelin-contracts` is missing or wrong version:

#### Option A — Use Solidity 0.8.24+:

```bash
forge install OpenZeppelin/openzeppelin-contracts@v5.5.0
```

Update your contracts’ pragma:

```solidity
pragma solidity ^0.8.24;
```

#### Option B — Keep Solidity 0.8.20:

```bash
rm -rf lib/openzeppelin-contracts
forge install OpenZeppelin/openzeppelin-contracts@v4.9.6
```

Then rebuild:

```bash
forge clean && forge build
```

---

## 📦 Installing Essential Tools

### 🧰 Slither (Static Analysis - Python)

```bash
pipx install slither-analyzer
```

If not found:

```bash
pipx ensurepath
pipx install slither-analyzer
```

Run:

```bash
slither .
```

---

### 🦅 Aderyn (Rust-based Analyzer)

#### Install (choose one):

**Via Homebrew (recommended):**

```bash
brew install cyfrin/tap/aderyn
```

**Via npm:**

```bash
npm install -g @cyfrin/aderyn
```

**Via Curl:**

```bash
curl --proto '=https' --tlsv1.2 -LsSf https://github.com/cyfrin/aderyn/releases/latest/download/aderyn-installer.sh | bash
```

Check version:

```bash
aderyn --version
```

Run on project:

```bash
aderyn
```

→ Output: `report.md` generated in project root

---

### 🧮 cloc (Count Lines of Code)

```bash
brew install cloc
cloc src/
```

---

### 📈 Solidity Metrics (in VSCode)

Install VSCode extension:

> **Solidity Visual Developer**

Then:

* Right-click on `src/` folder → “Run Solidity Metrics”
* Generates a metrics report

---

## 🔍 Static Analysis Tools

| Tool                 | Purpose                                | Command                         |
| -------------------- | -------------------------------------- | ------------------------------- |
| **Slither**          | Detects vulnerabilities, code smells   | `slither .`                     |
| **Aderyn**           | Rust-based static analyzer (by Cyfrin) | `aderyn`                        |
| **cloc**             | Line count, project estimation         | `cloc src/`                     |
| **Solidity Metrics** | Visual code stats                      | VSCode → “Run Solidity Metrics” |

---

## 💣 Common Solidity Exploits

| Category              | Example                | Prevention                                        |
| --------------------- | ---------------------- | ------------------------------------------------- |
| **Reentrancy**        | DAO Hack               | CEI (Checks-Effects-Interactions), `nonReentrant` |
| **Denial of Service** | Loops or unbounded gas | Remove unnecessary loops                          |
| **Weak RNG**          | Predictable randomness | Use Chainlink VRF                                 |
| **Arithmetic Issues** | Overflow / rounding    | Use Solidity ≥ 0.8 (auto safe math)               |
| **Poor ETH Handling** | Stuck ETH              | Add `withdraw()` function                         |
| **Access Control**    | Missing onlyOwner      | Use OpenZeppelin’s `Ownable`                      |

---

## 🧪 Testing & Fuzzing

Run tests:

```bash
forge test
```

Run specific test:

```bash
forge test --mt test_denialOfService
```

Enable traces:

```bash
forge test -vvv
```

Fuzz testing (randomized inputs) is built-in in Foundry.
You can write:

```solidity
function testFuzz_Input(uint256 amount) public { ... }
```

---

## 📊 Metrics & Code Structure

Audit estimation using **cloc**:

```bash
cloc src/
```

**Solidity Metrics in VSCode** helps visualize:

* Function sizes
* Complexity
* Comment ratio
* Cyclomatic complexity

Use it to estimate audit scope and focus areas.

---

## 📘 General Audit Workflow

### 🧭 1. Initial Review

* Read project README
* Identify protocol purpose
* Map dependencies and external calls
* Check compiler & dependency versions

### 🔍 2. Scoping & Reconnaissance

* Use `cloc` & `Solidity Metrics` to measure size
* Identify key contracts (entry points)
* List all modifiers & state variables

### 🧨 3. Vulnerability Identification

* Run **Slither** and **Aderyn**
* Manually check:

  * Reentrancy
  * Access control
  * Logic errors
  * Uninitialized storage
  * Arithmetic precision

### 🧾 4. Reporting

Create `report.md` (template below)

---

## 🧾 Writing Audit Reports

### Example Report Template

```markdown
# 🧠 Smart Contract Security Review

**Project:** Puppy Raffle  
**Date:** YYYY-MM-DD  
**Auditor:** [Your Name]  
**Tools:** Slither, Aderyn, Foundry

---

## Summary
- Total contracts: 5
- Compiler version: 0.8.24
- Libraries: OpenZeppelin v5.5.0

---

## Findings

| ID | Severity | Title | Description | Recommendation |
|----|-----------|--------|--------------|----------------|
| 1 | Critical | Reentrancy | Vulnerable to reentry in withdraw() | Apply CEI & `nonReentrant` |
| 2 | Medium | Weak RNG | Uses block.timestamp | Use Chainlink VRF |
| 3 | Informational | Strict Solidity Version | Use caret (^) instead of exact = |

---

## Recommendations
- Add fuzz/invariant tests
- Apply CEI pattern everywhere
- Use latest compiler version
```

---

## 📚 Continuous Learning Resources

| Topic                       | Resource                                                                     |
| --------------------------- | ---------------------------------------------------------------------------- |
| 🧑‍💻 **Cyfrin Course**     | [Cyfrin Updraft Security Course](https://updraft.cyfrin.io/courses/security) |
| 🧠 **Competitive Auditing** | [CodeHawks](https://codehawks.com)                                           |
| 🧮 **Bug Database**         | [Solodit](https://solodit.xyz)                                               |
| 🧱 **Docs Reference**       | [OpenZeppelin Docs](https://docs.openzeppelin.com/contracts)                 |
| 🗞️ **Newsletters**         | Officer CIA, Week in Ethereum, Rekt                                          |
| 🗣️ **Communities**         | Cyfrin Discord, Ethereum Stack Exchange                                      |

---

## ✅ Final Notes

* Always keep your environment updated:

  ```bash
  brew update && brew upgrade
  foundryup
  cyfrinup
  ```
* Use **burner wallets** for testing real contracts
* Never copy-paste fixes — understand root causes
* Keep versioning and documentation clean
* Remember: **You are a Security Researcher**, not just an auditor.

Excellent 🎯

What you’re asking for is a **comprehensive README / Handbook** — a **Smart Contract Auditing Setup & Workflow Guide** — that takes **everything from your terminal logs, installations, errors, Cyfrin audit curriculum, and auditing concepts** and organizes it into a **single self-contained step-by-step document**.

This guide will work as your **personal “Auditor’s Manual”** — so that anytime you start a new project or review, you can just open it and go from zero to audit-ready.

---

Below is the **complete and properly structured README.md** you can save to your root folder.

---

# 🧠 Smart Contract Auditing Setup & Workflow Guide

### (Universal Auditing Handbook for Beginners → Professionals)

---

## 🚀 Purpose

This document is a **complete end-to-end guide** for setting up, running, and understanding the **smart contract auditing process**, based on Cyfrin’s *Smart Contract Security, Auditing, Assembly, and DeFi Course* and practical debugging experience.

Use this as your **one-stop reference** whenever you start a new audit or review project.

---

## 🧩 Table of Contents

1. [🛠️ Prerequisites](#️-prerequisites)
2. [⚙️ Environment Setup](#️-environment-setup)
3. [📦 Installing Essential Tools](#-installing-essential-tools)
4. [🔍 Static Analysis Tools](#-static-analysis-tools)
5. [💣 Common Solidity Exploits](#-common-solidity-exploits)
6. [🧪 Testing & Fuzzing](#-testing--fuzzing)
7. [📊 Metrics & Code Structure](#-metrics--code-structure)
8. [📘 General Audit Workflow](#-general-audit-workflow)
9. [🧾 Writing Audit Reports](#-writing-audit-reports)
10. [📚 Continuous Learning Resources](#-continuous-learning-resources)

---

## 🛠️ Prerequisites

Before auditing, make sure you understand:

* Solidity basics (variables, functions, modifiers)
* Foundry test framework (`forge`)
* Ethereum transactions & gas model
* Git & Markdown

**Tools you should already have or install:**

* [VS Code](https://code.visualstudio.com)
* [Git](https://git-scm.com/)
* [Foundry](https://book.getfoundry.sh/)
* [Node.js](https://nodejs.org/)
* [Python 3](https://www.python.org/)
* [Rust (cargo)](https://www.rust-lang.org/tools/install)
* [Homebrew (Mac)](https://brew.sh/)
* **AI Helper (ChatGPT, Phind, etc.)**

---

## ⚙️ Environment Setup

### 1️⃣ Install Foundry (forge, cast, chisel)

```bash
curl -L https://foundry.paradigm.xyz | bash
foundryup
```

Check:

```bash
forge --version
cast --version
```

---

### 2️⃣ Initialize or Clone an Audit Project

Example (Cyfrin Puppy Raffle Audit):

```bash
git clone https://github.com/Cyfrin/4-puppy-raffle-audit.git
cd 4-puppy-raffle-audit
forge build
```

---

### 3️⃣ Fix Missing Libraries (like OpenZeppelin)

If `openzeppelin-contracts` is missing or wrong version:

#### Option A — Use Solidity 0.8.24+:

```bash
forge install OpenZeppelin/openzeppelin-contracts@v5.5.0
```

Update your contracts’ pragma:

```solidity
pragma solidity ^0.8.24;
```

#### Option B — Keep Solidity 0.8.20:

```bash
rm -rf lib/openzeppelin-contracts
forge install OpenZeppelin/openzeppelin-contracts@v4.9.6
```

Then rebuild:

```bash
forge clean && forge build
```

---

## 📦 Installing Essential Tools

### 🧰 Slither (Static Analysis - Python)

```bash
pipx install slither-analyzer
```

If not found:

```bash
pipx ensurepath
pipx install slither-analyzer
```

Run:

```bash
slither .
```

---

### 🦅 Aderyn (Rust-based Analyzer)

#### Install (choose one):

**Via Homebrew (recommended):**

```bash
brew install cyfrin/tap/aderyn
```

**Via npm:**

```bash
npm install -g @cyfrin/aderyn
```

**Via Curl:**

```bash
curl --proto '=https' --tlsv1.2 -LsSf https://github.com/cyfrin/aderyn/releases/latest/download/aderyn-installer.sh | bash
```

Check version:

```bash
aderyn --version
```

Run on project:

```bash
aderyn
```

→ Output: `report.md` generated in project root

---

### 🧮 cloc (Count Lines of Code)

```bash
brew install cloc
cloc src/
```

---

### 📈 Solidity Metrics (in VSCode)

Install VSCode extension:

> **Solidity Visual Developer**

Then:

* Right-click on `src/` folder → “Run Solidity Metrics”
* Generates a metrics report

---

## 🔍 Static Analysis Tools

| Tool                 | Purpose                                | Command                         |
| -------------------- | -------------------------------------- | ------------------------------- |
| **Slither**          | Detects vulnerabilities, code smells   | `slither .`                     |
| **Aderyn**           | Rust-based static analyzer (by Cyfrin) | `aderyn`                        |
| **cloc**             | Line count, project estimation         | `cloc src/`                     |
| **Solidity Metrics** | Visual code stats                      | VSCode → “Run Solidity Metrics” |

---

## 💣 Common Solidity Exploits

| Category              | Example                | Prevention                                        |
| --------------------- | ---------------------- | ------------------------------------------------- |
| **Reentrancy**        | DAO Hack               | CEI (Checks-Effects-Interactions), `nonReentrant` |
| **Denial of Service** | Loops or unbounded gas | Remove unnecessary loops                          |
| **Weak RNG**          | Predictable randomness | Use Chainlink VRF                                 |
| **Arithmetic Issues** | Overflow / rounding    | Use Solidity ≥ 0.8 (auto safe math)               |
| **Poor ETH Handling** | Stuck ETH              | Add `withdraw()` function                         |
| **Access Control**    | Missing onlyOwner      | Use OpenZeppelin’s `Ownable`                      |

---

## 🧪 Testing & Fuzzing

Run tests:

```bash
forge test
```

Run specific test:

```bash
forge test --mt test_denialOfService
```

Enable traces:

```bash
forge test -vvv
```

Fuzz testing (randomized inputs) is built-in in Foundry.
You can write:

```solidity
function testFuzz_Input(uint256 amount) public { ... }
```

---

## 📊 Metrics & Code Structure

Audit estimation using **cloc**:

```bash
cloc src/
```

**Solidity Metrics in VSCode** helps visualize:

* Function sizes
* Complexity
* Comment ratio
* Cyclomatic complexity

Use it to estimate audit scope and focus areas.

---

## 📘 General Audit Workflow

### 🧭 1. Initial Review

* Read project README
* Identify protocol purpose
* Map dependencies and external calls
* Check compiler & dependency versions

### 🔍 2. Scoping & Reconnaissance

* Use `cloc` & `Solidity Metrics` to measure size
* Identify key contracts (entry points)
* List all modifiers & state variables

### 🧨 3. Vulnerability Identification

* Run **Slither** and **Aderyn**
* Manually check:

  * Reentrancy
  * Access control
  * Logic errors
  * Uninitialized storage
  * Arithmetic precision

### 🧾 4. Reporting

Create `report.md` (template below)

---

## 🧾 Writing Audit Reports

### Example Report Template

```markdown
# 🧠 Smart Contract Security Review

**Project:** Puppy Raffle  
**Date:** YYYY-MM-DD  
**Auditor:** [Your Name]  
**Tools:** Slither, Aderyn, Foundry

---

## Summary
- Total contracts: 5
- Compiler version: 0.8.24
- Libraries: OpenZeppelin v5.5.0

---

## Findings

| ID | Severity | Title | Description | Recommendation |
|----|-----------|--------|--------------|----------------|
| 1 | Critical | Reentrancy | Vulnerable to reentry in withdraw() | Apply CEI & `nonReentrant` |
| 2 | Medium | Weak RNG | Uses block.timestamp | Use Chainlink VRF |
| 3 | Informational | Strict Solidity Version | Use caret (^) instead of exact = |

---

## Recommendations
- Add fuzz/invariant tests
- Apply CEI pattern everywhere
- Use latest compiler version
```

---

## 📚 Continuous Learning Resources

| Topic                       | Resource                                                                     |
| --------------------------- | ---------------------------------------------------------------------------- |
| 🧑‍💻 **Cyfrin Course**     | [Cyfrin Updraft Security Course](https://updraft.cyfrin.io/courses/security) |
| 🧠 **Competitive Auditing** | [CodeHawks](https://codehawks.com)                                           |
| 🧮 **Bug Database**         | [Solodit](https://solodit.xyz)                                               |
| 🧱 **Docs Reference**       | [OpenZeppelin Docs](https://docs.openzeppelin.com/contracts)                 |
| 🗞️ **Newsletters**         | Officer CIA, Week in Ethereum, Rekt                                          |
| 🗣️ **Communities**         | Cyfrin Discord, Ethereum Stack Exchange                                      |

---

## ✅ Final Notes

* Always keep your environment updated:

  ```bash
  brew update && brew upgrade
  foundryup
  cyfrinup
  ```
* Use **burner wallets** for testing real contracts
* Never copy-paste fixes — understand root causes
* Keep versioning and documentation clean
* Remember: **You are a Security Researcher**, not just an auditor.

---
Good catch bringing that snippet here — it looks like you’re trying to measure **gas usage** for a function call (`enterRaffle`) using Foundry’s console utilities.

However, the syntax in your code has a few small mistakes — missing operators, parentheses, and incorrect function argument format.

Let’s fix it and explain.

---

### ✅ Corrected Version

```solidity
// See how much gas it costs
uint256 gasStart = gasleft();
puppyRaffle.enterRaffle{value: entranceFee}(players);
uint256 gasEnd = gasleft();
uint256 gasUsedFirst = (gasStart - gasEnd) * tx.gasprice;

console.log("Gas cost of the first 100 players: ", gasUsedFirst);
```

---

### 🧩 Explanation

| Line                                                        | Purpose                                                                             |
| ----------------------------------------------------------- | ----------------------------------------------------------------------------------- |
| `uint256 gasStart = gasleft();`                             | Records the remaining gas *before* the call                                         |
| `puppyRaffle.enterRaffle{value: entranceFee}(players);`     | Executes the raffle entry function, passing `players` and sending `entranceFee` ETH |
| `uint256 gasEnd = gasleft();`                               | Records remaining gas *after* the call                                              |
| `uint256 gasUsedFirst = (gasStart - gasEnd) * tx.gasprice;` | Calculates the total cost in **wei** (gas used × gas price)                         |
| `console.log("Gas cost...", gasUsedFirst);`                 | Logs to Foundry console for measurement                                             |

---

### 💡 Tips

1. **Use Foundry’s built-in gas reporter** instead of manual measurement:

   ```bash
   forge test --gas-report
   ```

   It shows gas per function automatically.

2. **For readability**, you can log both gas used and ETH equivalent:

   ```solidity
   console.log("Gas used:", gasStart - gasEnd);
   console.log("Cost in wei:", gasUsedFirst);
   console.log("Cost in gwei:", gasUsedFirst / 1 gwei);
   ```

3. **Be careful** — `tx.gasprice` gives the *base gas price*, but if you’re using `EIP-1559` style transactions (maxFeePerGas, etc.), your local simulation may not reflect mainnet prices perfectly. It’s still fine for **relative gas comparisons**.

---

Would you like me to show how to **benchmark multiple runs** (e.g., compare gas for 10, 100, and 1000 players) and print a small gas report table automatically inside your test?


Good question — you can absolutely preview your `findings.md` file (or any Markdown file like `README.md`) directly in **VS Code** on your Mac.

Here’s how 👇

---

### 💻 **Shortcut Keys (MacBook)**

| Action                                      | Shortcut                          |
| ------------------------------------------- | --------------------------------- |
| 🟢 **Open Markdown Preview (side-by-side)** | `⌘ + K V`                         |
| 🟢 **Open Markdown Preview (in same tab)**  | `⌘ + Shift + V`                   |
| 🔵 **Close the preview**                    | `⌘ + W` (closes that preview tab) |
| 🟠 **Reopen preview to the side**           | `⌘ + K V` again                   |

---

### ⚙️ **Alternate Way (if you forget the shortcut)**

1. Open your `findings.md` file in VS Code.
2. Click on the **“Open Preview to the Side”** icon (📄 with a magnifier) in the **top right corner** of the editor.
3. The preview pane will open beside your code.

---

### 🧠 Tip

You can also enable **auto preview updates** (it refreshes as you type):

```text
Settings → "Markdown: Preview Front Matter" → Enable
```

And to zoom or adjust styling, you can install the extension
**“Markdown Preview Enhanced”** — it gives a cleaner, formatted view (with diagrams, LaTeX, etc.).

---

So for your case, to preview `findings.md` side-by-side, just hit:

> **⌘ + K V**

Want me to show how to export that preview to PDF or HTML (for sharing the audit findings)?



with slither . command find error and find bug also from that 

https://github.com/crytic/slither/wiki/Detector-Documentation#weak-PRNG


https://solodit.cyfrin.io/?i=HIGH%2CMEDIUM%2CLOW%2CGAS&maxf=&minf=&rf=alltime&sd=Desc&sf=Recency


https://github.com/Cyfrin/security-and-auditing-full-course-s23/blob/main/finding_layout.md
from this link we get how to write contract audit first 
### [S-#] TITLE (Root Cause + Impact)

**Description:** 

**Impact:** 

**Proof of Concept:**

**Recommended Mitigation:** 