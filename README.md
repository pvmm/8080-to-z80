Converts 8080 assembly to Z80
=============================

Hackish and stupid assembly converter that uses GNU awk to convert tiny BASIC code in https://github.com/pvmm/tinybasic.

```
./8080-to-z80 < input.8080 > output.z80
```

Parameters:
* `CODE_START` column where assembly code really starts (default: `1`, meaning first column)
* `CODE_END` column where assembly code ends (default: `-1`, meaning whole line)
* `COMMENT_SEP` comment separator (default: `;` character)
* `UNCLUTTERED` unclutters the code, removing all kinds of comment (default: `0`, meaning no)

Use it like this:

```
./8080-to-z80 -v CODE_START=23 -v CODE_END=47 < ../tinybasic/tinybasicv3.8080 > ../tinybasic/tinybasicv3.z80
```
