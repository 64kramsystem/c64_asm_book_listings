# C64 (Commodore 64) ASM Book Listings

Listings from (old) C64 ASM books I've studied on.

Many (if not all) of the books from the past don't have a digital edition, so, while studying them, I'm publishing their listings, along with fixes, improvements, extensions, comments, and in a format that can be compiled by Kick Assembler.

The details about the fixes have been, separately, published on my [professional blog](https://saveriomiroddi.github.io/tag/retrocomputing).

The filenames are in the format `$book_name/$chapter.$page.$title.$ext`.

**Update**: Since fixing and improving the routines has been *very* time-consuming, the current book may be the only one included in the project.

## Current books/listings

### Machine Code Games Routines for the Commodore 64

This book includes the ASM routines; only the BASIC listing invoking ASM have been added.

Routines:

- 06.047: Spiral screen fill
  - includes 09.071: Rectangle fill
- 09.071: Small memory fill (fixed and extended)
- 09.071: Block fill
- 09.074: Memory copy (with simple optimizations)
- 09.076: Delay (3 versions)
- 09.080: Fundamental Bomb Update (fixed)
- 09.081: Hail Of Barbs (fixed, and dumped the ASM routine)
- 09.085: 256 Byte Continuous Scroll (fixed)
- 09.086: Scroll Into Lower Memory
- 09.087: Line Blank
- 09.090: Joystick Handling
- 09.092: Inverting (characters)
- 09.094: Attribute Flasher (fixed)
- 09.094: Alternative Sprite System
- 10.102: Sprite vectoring (with full ASM port of the BASIC program below)
  - 10.103: BASIC program including the above
- 10.110: Interrupt-driven Tune Player (commented and added tune, but unverified)
- 10.115: Window Projection (commented, but unverified)
- 10.116: Projecting a Landscape (fixed and simplified)
- 10.120: Array Routines 1: Plot Characters
- 10.120: Array Routines 2: Move Characters
- 10.121: Array Routines 3: Search Entry (simplified and optimized)
- 10.122: Array Routines 4: Delete Entry
- 10.124: Random Numbers
- 10.130: Homing Motion (optimized and simplified; added randomized sprites)

The book intentionally uses relative jumps (typically `CLC`+`BCC`) instead of straight `JMP`s, for relocatability purposes; the modified code listings respect this design.

Since the book aims for simplicity rather than optimization, optimizations have been applied only where they don't affect readability (or when they simplify the logic). An optimization that hasn't always been applied is to turn `INr/CPr/BNE` / `DEr/BNE` loops into `DEr/BPL` (which saves a CMP in the first case, and removes the -1 offset in the second).
