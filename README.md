# longpass
rule-based passphrase generator with custom Diceware-ish dictionaries

## Overview

While [Diceware](http://world.std.com/~reinhold/diceware.html) is the
way to go when you need to be sure your passphrase is secure,
sometimes you need to generate them in bulk, and comply with policies
about mixed-case and special characters.

## Files

* `longpass` -- generate a bunch of strong dictionary-based passphrases
that follow a defined pattern.

* `rulesets/*` -- a bunch of possible ruleset files

* `cache/rulesets/*` -- cached JSON rulesets for performance

* `make-japanese` -- use JMDict_e to generate a Japanese ruleset or
Diceware file (with `-d`).

* `diceware/diceware-jp.txt` -- output of `make-japanese.rb -d`

## Usage

```
% longpass -l rulesets/japanese.txt 
Ruleset: rulesets/japanese.txt
Array Sizes:
   a 9695
   d 10
   s 4
   v 10
Patterns:
   1 ( 88.10): a a a a a a vsd
   2 (114.59): a a a a a a a a vsd
   3 (101.35): a a a a a a a vsd
   4 ( 74.86): a a a a a vsd
   5 ( 61.62): a a a a vsd
   6 (105.94): a a a a a a a a
   7 ( 92.70): a a a a a a a
   8 ( 79.46): a a a a a a
   9 ( 66.22): a a a a a
  10 ( 52.97): a a a a

Random printable ASCII passwords (6.57 bits/char):
   8=52.56  10=65.70  12=78.84  14=91.98  16=105.12  18=118.26

% longpass -c 5 rulesets/japanese.txt 
hansei boken tekubi kicho konro tokoya A*9
daga hiritsu chojin wakaru keigen kiseru X-5
kippo miukeru ensei kiseru yozora kansho Y-6
orei sokutei omutsu tagaku kakeru kome Y-2
yui kanku haikyo gairoju inritsu mokunin X+3

% longpass -p 14 -c 5 rulesets/eff4dice1.txt
prizebooth emptyice awokejoy Z-6
mardistony decalhash icetug Q*7
thosepurr bagelhut acidwife B*1
payeromen booklurk slamdress Y*7
happyslice denimarmed relayrebel N-2

% longpass -c 100000 rulesets/tolkien.txt > /dev/null

real    0m1.987s
user    0m1.892s
sys     0m0.065s
```

## Notes

* [JMDict_e source](http://ftp.monash.edu/pub/nihongo/JMdict_e.gz) for
use by `make-japanese`

## TODO

Improve the rather simple-minded caching; should go into a well-defined
directory.
