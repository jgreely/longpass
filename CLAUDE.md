# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

`longpass` is a rule-based passphrase generator that creates strong passphrases using custom Diceware-style wordlists. It's implemented as a single Python script that uses the `secrets` module for cryptographically-secure random number generation.

## Architecture

### Core Components

- **`longpass`** (lines 1-278): Main Python script with three key responsibilities:
  1. Pattern processing: Translates patterns like "a a a a" into wordlist selections
  2. Wordlist management: Loads and combines multiple wordlists from `~/lib/longpass/`
  3. Passphrase generation: Uses `secrets.choice()` for secure randomness

- **Wordlists** (`lib/longpass/*.txt`): Each file contains one word/token per line. Some support Diceware format with "NUMBER\tWORD" (tab-separated), which the script handles by extracting just the word portion.

- **Patterns** (`lib/longpass/patterns.txt`): Pre-defined templates where letters (a, b, c, etc.) represent wordlist positions, and any other character is inserted literally.

- **Configuration** (`~/.longpass`): Optional ConfigParser-format file defining named rulesets that bundle pattern + wordlist + options.

### Key Design Patterns

1. **Pattern-to-wordlist mapping**: Command-line wordlist arguments map sequentially to letters a, b, c, etc. Pattern "a a b" with wordlists `noun adj` means: pick from noun twice, then pick from adj once.

2. **Character passthrough**: In `longpass:253-258`, any pattern character not in the `rule` dict is inserted literally (e.g., "-" or ":" in patterns becomes a literal separator).

3. **Entropy calculation**: When `-e` flag is used, entropy is calculated from wordlist sizes and shuffle permutations (lines 239-250).

4. **Mixed-case enforcement**: The `force_mixed()` function (lines 35-47) ensures at least one uppercase and one lowercase letter by toggling the first alpha character if needed - addresses legacy security requirements.

## Development Commands

### Installation
```bash
make install
# Installs to ~/bin/longpass and ~/lib/longpass/*
# Optionally: cp dot-longpass.txt ~/.longpass
```

### Testing the Script
```bash
# Basic test: generate default passphrases
./longpass -c 3

# Test pattern system
./longpass -l  # list all patterns and wordlists

# Test a specific pattern with custom wordlists
./longpass -c 5 -p "a-b a-b" adj noun

# Test ruleset functionality
./longpass -R  # list rulesets (requires ~/.longpass)
./longpass -r spunky -c 3  # use a ruleset

# Test entropy calculation
./longpass -e -c 5

# Performance test
time ./longpass -c 100000 eff5 > /dev/null
```

### Code Patterns to Follow

- Wordlists should contain one token per line, optionally with Diceware number prefix
- Empty lines in wordlists are converted to single space (line 234)
- All file paths use `os.path.join()` for cross-platform compatibility
- The script looks ONLY in `~/lib/longpass/` for wordlists unless a dot is in the filename (lines 225-228)

## Important Notes

- **Security**: Uses `secrets.choice()` for cryptographic randomness, NOT `random.choice()`
- **Wordlist location**: Currently hardcoded to `~/lib/longpass/` - no search path support yet (see TODO on line 224)
- **Pattern elements**: `collapse()` function (lines 23-32) concatenates non-space elements, allowing patterns like "aaaa" to pick 4 chars and join them
- **Shuffle entropy**: When `-s` is used, additional entropy from permutations is calculated using multiset combinatorics (lines 243-250)
- **ConfigParser format**: The `~/.longpass` file uses INI-style sections with lowercase option names
