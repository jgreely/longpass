# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

`longpass` is a rule-based passphrase generator that creates strong passphrases using custom Diceware-style wordlists. It's packaged using Poetry and can be installed as a Python package.

## Architecture

### Core Components

- **`longpass.py`**: Main Python script with three key responsibilities:
  1. Pattern processing: Translates patterns like "a a a a" into wordlist selections
  2. Wordlist management: Loads and combines multiple wordlists from the `longpass_data` package or `~/lib/longpass/`
  3. Passphrase generation: Uses `secrets.choice()` for secure randomness

- **`longpass_data/`**: Python package containing wordlist data files. Each file contains one word/token per line. Some support Diceware format with "NUMBER\tWORD" (tab-separated), which the script handles by extracting just the word portion.

- **Wordlists** (`longpass_data/*.txt`): The data files are packaged with the Python module and accessed via `importlib.resources`. Falls back to `~/lib/longpass/` if package data is not found.

- **Patterns** (`longpass_data/patterns.txt`): Pre-defined templates where letters (a, b, c, etc.) represent wordlist positions, and any other character is inserted literally.

- **Default Rulesets** (`longpass_data/default-rulesets.txt`): Bundled default rulesets in ConfigParser format. Used as fallback when `~/.longpass` doesn't exist.

- **Configuration** (`~/.longpass`): Optional ConfigParser-format file defining named rulesets that bundle pattern + wordlist + options. If this file doesn't exist, the bundled default rulesets are used automatically.

### Key Design Patterns

1. **Pattern-to-wordlist mapping**: Command-line wordlist arguments map sequentially to letters a, b, c, etc. Pattern "a a b" with wordlists `noun adj` means: pick from noun twice, then pick from adj once.

2. **Character passthrough**: In the main loop, any pattern character not in the `rule` dict is inserted literally (e.g., "-" or ":" in patterns becomes a literal separator).

3. **Entropy calculation**: When `-e` flag is used, entropy is calculated from wordlist sizes and shuffle permutations.

4. **Mixed-case enforcement**: The `force_mixed()` function ensures at least one uppercase and one lowercase letter by toggling the first alpha character if needed - addresses legacy security requirements.

5. **Data file location**: The `get_data_dir()` function (longpass.py:58-69) checks for package data first using `importlib.resources`, then falls back to `~/lib/longpass/` for backward compatibility.

6. **Default rulesets fallback**: The `get_default_rulesets_content()` function (longpass.py:72-87) loads bundled default rulesets from `longpass_data/default-rulesets.txt`. When `~/.longpass` doesn't exist, these defaults are automatically loaded, allowing users to use rulesets like `-r smorg` without any setup.

## Development Commands

### Installation with Poetry
```bash
# Install dependencies
poetry install

# Build the package
poetry build

# Install locally in development mode
poetry install

# Run the script via poetry
poetry run longpass -c 3
```

### Installation with pip
```bash
# Install from source
pip install .

# Install in development mode
pip install -e .
```

### Testing the Script
```bash
# Basic test: generate default passphrases
python3 longpass.py -c 3

# Test pattern system
python3 longpass.py -l  # list all patterns and wordlists

# Test a specific pattern with custom wordlists
python3 longpass.py -c 5 -p "a-b a-b" adj noun

# Test ruleset functionality
python3 longpass.py -R  # list rulesets (uses bundled defaults if no ~/.longpass)
python3 longpass.py --default-rulesets  # display bundled default rulesets
python3 longpass.py -r spunky -c 3  # use a ruleset

# Test entropy calculation
python3 longpass.py -e -c 5

# Performance test
time python3 longpass.py -c 100000 eff5 > /dev/null
```

### Code Patterns to Follow

- Wordlists should contain one token per line, optionally with Diceware number prefix
- Empty lines in wordlists are converted to single space
- File paths use pathlib.Path for cross-platform compatibility
- The script looks for wordlists in the `longpass_data` package first, then falls back to `~/lib/longpass/` for backward compatibility
- Data files are included in the package via the `longpass_data` directory

## Important Notes

- **Security**: Uses `secrets.choice()` for cryptographic randomness, NOT `random.choice()`
- **Wordlist location**: Checks package data first (`longpass_data/`), then falls back to `~/lib/longpass/`
- **Pattern elements**: `collapse()` function concatenates non-space elements, allowing patterns like "aaaa" to pick 4 chars and join them
- **Shuffle entropy**: When `-s` is used, additional entropy from permutations is calculated using multiset combinatorics
- **ConfigParser format**: The `~/.longpass` file uses INI-style sections with lowercase option names
- **Default rulesets**: If `~/.longpass` doesn't exist, bundled defaults from `longpass_data/default-rulesets.txt` are used automatically. Users can view them with `--default-rulesets` and copy to `~/.longpass` to customize.
- **Package structure**:
  - `longpass.py`: Main script with `main()` entry point
  - `longpass_data/`: Python package containing all wordlist .txt files and default-rulesets.txt
  - `pyproject.toml`: Poetry configuration defining packages and dependencies
