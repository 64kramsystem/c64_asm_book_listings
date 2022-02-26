# C64 (Commodore 64) ASM Book Listings

Listings from (old) C64 ASM books I've studied on.

Many (if not all) of the books from the past don't have a digital edition, so, while studying them, I'm publishing their listings, in a cleaned, converted (to Kick Assembler) and commented version.

The listings are in the format `$book_name/$chapter.$page.$description.asm`.

## Current books/listings

The listing presented have been fixed, where I've found bugs. I've published the errata, with explanations, on my [professional blog](https://saveriomiroddi.github.io/tag/retrocomputing/).

### Machine Code Games Routines for the Commodore 64 (WIP)

- 06.047: Spiral screen fill
  - includes 09.071: Rectangle fill
- 09.071: Small memory fill (with fix, and extended version)
- 09.071: Block fill
- 09.074: Memory copy (with simple optimizations)
- 09.076: Delay (3 versions)
- 09.080: Fundamental Bomb Update (with fix)
- 09.081: Hail Of Barbs (with BASIC fix, but untested ASM)
- 09.085: 256 Byte Continuous Scroll (with fix)
- 09.086: Scroll Into Lower Memory
- 09.087: Line Blank
- 09.090: Joystick Handling
- 09.092: Inverting (characters)
- 09.094: Attribute Flasher (with fix)
- 09.094: Alternative Sprite System
- 10.102: Sprite vectoring (with full ASM port of the BASIC program below)
  - 10.103: BASIC program including the above
- 10.110: Interrupt-driven Tune Player (commented and with tune, but unverified)
- 10.115: Window Projection (commented, but unverified)
- 10.116: Projecting a Landscape (fixed, extended, and simplified)
- 10.120: Array Routines 1: Plot Characters
- 10.120: Array Routines 2: Move Characters

This book uses intentionally relative jumps (typically `CLC`+`BCC`) instead of straight `JMP`s, for relocatability purposes; the modified code listings respect this design.

The book aim for simplicity rather than optimization, so optimizations have been applied only where they don't affect simplicity (or even improve it).

Generally, the loop structure:

- `LDr #0`
- ...
- `INr`
- `CPr #SIZE`
- `BNE loop`

can be optimized to:

- `LDr #(SIZE - 1)`
- `DEr`
- `BPL loop`

Arguably, this is equally simple, although SIZE must not be greater than 128, otherwise the loop will exit after the first cycle.
