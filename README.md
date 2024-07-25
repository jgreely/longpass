# longpass
rule-based passphrase generator with custom Diceware-ish dictionaries

## Overview

While [Diceware](http://world.std.com/~reinhold/diceware.html) is the
way to go when you need to be sure your passphrase is secure,
sometimes you need to generate them in bulk, and comply with policies
about mixed-case and special characters.

This script imports the Python `secrets` module to ensure that it
uses the most secure random number generator available on your
platform.

## Files

* `longpass` -- Python script to generate strong wordlist-based
  passphrases that follow a defined pattern. Can be installed anywhere.

* `lib/longpass/*.txt` -- a wide variety of wordlists, both short and
  long, as well as the list of pre-defined patterns in `patterns.txt`.
  Script only looks for them in `~/lib/longpass` at the moment.

* `dot-longpass.txt` -- sample `~/.longpass` file containing complete
  passphrase-generation recipes in ConfigParser format.

* `diceware/diceware-jp.txt` -- Japanese Diceware wordlist, extracted
  from JMDict_e using `make-japanese.rb -d`

* `make-japanese.rb` -- extracts common non-katakana words from JMDict_e
  for use as a wordlist.

### Obsolete Ruby version

* `longpass.rb` -- mostly the same functionality, but required caching
  due to the overhead of TOML parsing in Ruby.

* `rulesets/*` -- TOML rulesets for the Ruby version.

## Usage

```
# default output is 6 words chosen from the EFF 5-dice list
#
% longpass --count 5
mulch eraser sudden zestfully fit straw
powdering saggy pep remorse humorous coral
porthole crimp proxy footer splotchy language
handling improvise quaintly anagram nursery struggle
jawline strive wiry espionage settling humming

# list all predefined patterns and available wordlists,
# including the count of unique words in each list and the
# calculated entropy bits from using them.
#
% longpass -l
Predefined patterns:
  1 a a a a
  2 a a a a a
  3 a a a a a a
  4 aa aa aa
  5 aa aa aa aa
  6 ab ab ab
  7 ab ab ab ab
  8 aaaa aaaa aaaa aaaa
  9 aaab aaba abaa baaa
 10 aaaa aaaa aaaa aaaa bcdd
 11 aaab aaba abaa baaa cdee
 12 aaaaa aaaaa aaaaa aaaaa
 13 aaaaa abaaa aabaa aaaba

Available wordlists:
 Count   Bits  Name
  1296  10.34  adj
    54   5.75  alphanum
  7776  12.92  beale
  7776  12.92  diceware
    10   3.32  digit
  1296  10.34  eff4-1
  1296  10.34  eff4-2
  1296  10.34  eff4-3
  7776  12.92  eff5
  7776  12.92  finnish
  2048  11.00  german
    16   4.00  hex
  7776  12.92  japanese
  7776  12.92  noun
     5   2.32  op
    95   6.57  printable
    28   4.81  punct
    12   3.58  syl-a
    48   5.58  syl-b
  7776  12.92  tolkien
   384   8.58  us-fem
   384   8.58  us-male
   384   8.58  us-sur
    10   3.32  var

# return a string of four 4-digit lower-case hex numbers
# separated by dashes. (assumes `lib/longpass/patterns.txt`
# has "aaaa aaaa aaaa aaaa" as pattern #8)
# 
% longpass -c1 -p8 -j- hex
3296-0364-5a62-46bf

# returns 5-word passphrases combining five wordlists, shuffled for
# a few bits of extra entropy, guaranteed to contain both upper and
# lower-case letters. Also prints the estimated entropy at the beginning
# of each line. (assumes pattern #11 contains "aaab aaba abaa baaa cdee")
#
% longpass -c 5 -sem -p11 alphanum punct var op digit
107.48 G^xg 6Sp! (Ry9 qU=y Y+29
107.48 YGh& <N29 N#SF K+87 d5/N
107.48 2<8A C+00 (6EX zu#K pry]
107.48 dv,A F(v9 &dfC T=72 U7G^
107.48 :svw tku{ es[8 v:Z6 Y/73

# does the exact same thing using a recipe from `~/.longpass`
#
% longpass -r spunky -c 5 -e
107.48 Q-65 rB<U 7@8b 9B9@ .efh
107.48 Z=86 ;Tzy jhD: Rd?b f+RT
107.48 7as^ /uQP Q-64 K!bY c8!e
107.48 En't C/26 7&nT KuQ$ ,6Nx
107.48 t<b5 )7uA gKb) MC+h C*93

# lists all recipes defined in `~/.longpass`
#
% longpass -R
Defined rulesets:
  easy
  spunky
  shorthex
  longhex
  smorg

# mixes 11 different wordlists to create 9-word passphrases that
# should be long and strong enough for anyone (~127 bits of entropy).
#
% longpass -r smorg -c 3
stilt campen TcVG A/02 priscilla refract patrick bloated ellis
eier roderick lee A=43 modest tribute kristin outshoot eRSK
T=43 gestalt winter unnerving walton jUa8 beth mister andre

% time longpass -c 100000 eff5 > /dev/null

real    0m1.190s
user    0m0.920s
sys     0m0.200s
```

## Notes

* This package has included material from the JMdict (EDICT, etc.)
  dictionary files in accordance with the licence provisions of the
  Electronic Dictionaries Research Group. See
  [JMDict](https://www.edrdg.org/wiki/index.php/JMdict-EDICT_Dictionary_Project)
