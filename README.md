# scuba-steve

Names are hard. Scuba Steve will find your files with the same base name and allow
you to cycle through them. There are two commands: 'scuba-steve:toggle', scuba-steve:start-dive'.
Dive will refresh the path cache, and toggle will cycle through similar files (foo.hpp, foo.cpp, etc).

Example keymap:

```
'atom-workspace:not([mini])':
	'alt-o': 'scuba-steve:toggle'
```
