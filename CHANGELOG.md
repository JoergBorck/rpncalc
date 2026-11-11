# Changelog

## Unreleased

- Functions and variables pages: the list and the function keys are separate areas; arrows scroll the list and shift long code
- AC also returns the display to the calculator page with input and stack
- The arrows on the cursor cross no longer look slanted

## 0.3.0

- In the functions area, the up and down arrow keys page the function keys like the mouse wheel
- The function keys slide visibly: swiping follows the finger column by column and snaps to a page (a quick swipe turns one page); the mouse wheel slides them vertically and snaps to a page
- Pasting numbers as text (from the stack or from Excel) writes them as you would type them, separated by spaces
- New key CL clears the input line without touching the stack (empty line: removes the line below); Shift+CL (AC) also clears the history, the stack and its tags; Esc works like CL
- After an error, backspace first removes all keys typed after it at once
- Swiping vertically in the input and stack columns scrolls line by line and keeps moving after a fast swipe; the mouse wheel scrolls one line per notch
- Libraries can mark helper functions as internal (rpnintern): they get no function key; schwingungen hides rw, wr, osz and fpol
- Help mode: the mouse wheel and swiping page the function keys; clicking inside their frame shows help on the page (e.g. the library)
- In alpha mode, the function keys look like all other letter keys
- In alpha mode, the mouse wheel and swiping no longer page the function keys in the background
- On the PC, the function key block turns slightly orange while the mouse is over it (the mouse wheel pages there)
- Internal restructuring, no visible change
- Console menu: the note on starting the server names the message that stops it

## 0.2.0

- Pasting values: commas in a row (4,5,6,7) or next to a decimal point separate numbers.
- Firefox: pasting from the context menu works; if the browser refuses, the app says so.
- ENTER and Return work repeatedly: ENTER duplicates x, Return adds empty lines; the keypad Enter is recognized in browsers.
- Fixes for phones: tooltips on long press, key labels no longer wrap.
- Help texts revised after review: arguments for rnd and round, rounding modes as a table, clearer wording.
- Help start page in three parts: help on help, help on the app, help on the calculator.
- Stack scrolling reaches the deepest value and stops there.
- No tooltips over an open context menu.
- Typing on the PC keyboard hides tooltips until the mouse moves to another element.
- Functions page with sections for your own functions and each loaded library; it scrolls along with the function keys.
- Clipboard: context menu in the display (right click, long press), Ctrl+C/V and backslash commands.
- Swiping and the mouse wheel over the function keys turn their pages.
- After ~, keys it does not apply to no longer turn grey; ~ then acts as ±.
- After ~ or |, keys with a different meaning get a thin border.
- sinh, cosh, tanh and their inverses.
- The ~ and | keys show their own function (± and □|.□) below the symbol.

## 0.1.0

- Initial version.
