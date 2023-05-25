# micro-sparta-dos
Sources for update and rewrite of Micro Sparta DOS by BW-SOFT

Changelog:

Micro-SpartaDOS (MSDOS.COM)
ChangeLog (WHATSNEW.DOC)
------------------------------------
By Jiri Bernasek - BEWESOFT
Continued by Pecus & Pirx
------------------------------------

MSDOS45.COM - Warsaw, 2010-06-12 
              Post-release update.
Bugs fixed:
 * in rare circumstances of a
   fragmented disk (specifically
   when the gap between consecutive
   sectors was between 128 and 254
   secs, the loading failed)
   Thanks to KMK for the bug report!
   
New features:
 * MSDOS recognizes a special entry
   in MSDOS.DAT configuration file.
   For the special file
   "*          " (it is asterisk
   followed by 10 spaces)
   the long name space is decoded
   as a number of settings for 
   a given directory.
   Version 4.5 uses 4 hexadecimal
   numbers. First three are values
   of colors in this sequence:
   letters, playground, frame
   ($2c5, $2c6, $2c8).
   Fourth turns off TURBO for the 
   given directory when it equals
   to "00".
   
   Example:
   *          020E0A01
   This entry does NOT turn off the
   turbo, but sets colors like
   POKE 709,2:POKE 710,14:POKE 712,10
   
   The configuration entry ("*" file)
   should be the first one on the
   list of files.
   
   Turbo is turned off after reading
   the directory contents (directory
   itself may read in turbo mode).
   
   Please note that MSDOS.DAT files
   are fully compatible throught all
   versions and we will strive to
   retain this compatibility.
  
 * Support for all drives (1-15)
   Keys [Ctrl]+[A] to [Ctrl]+[O]
   select drives A: to O: 
   (1-15, SpartDos style).
   Old style (pressing keys [1]-[8]) 
   work just like it used to.
   Pressing keys [1]-[8] displays
   drives AtariDOS style (D1:, D2:).
   When letter keys are pressed,
   display switches to A:, B:, etc.
   style.
   
 * MSINI3 - a new version of the
   long name editor now supporting
   color schemes and turbo switch.
   Few additional bugs fixed:
     - crash on no Sparta
     - bad rewert to edition
     - some typos
   Enjoy new color schemes including
   Blues, Copper Plate and Bitter
   Lemon.
   Please note the avertised web page
   is not active anymore :).
   
------------------------------------

MSDOS43.COM - Warsaw, 2010-05-29
			  
  Version 4.3 of MSDOS is a serious
rewrite, done primarily by Pecus.
  It uses a novel approach to mapping
index sectors.
  Basically, index sectors are read 
beforehand and the sector map is 
compressed to, usually, just few 
bytes - saving room that would be 
normally occupied by the second 
sector buffer. This is especially 
important for quadruple (512 bytes) 
sectors when two buffers would eat
1KiB.
  Version 4.3 contains only the most
popular Happy / UltraSpeed routines. 
  Holding [SHIFT] during booting 
turns off HS I/O entirely.
  This version detects BASIC and
QMEG. With QMEG the High Speed I/O is
turned off by the popular request as
QMEG handles HS I/O by itself. 
  After selecting the game to load
the current MEMLO is shown on screen. 

Other changes:
 * Support for quadruple sectors
   (512 bytes long). This is possible
   in the latest SpartaDosX and
   expands the avalilable partition
   size to 32MiB. 
 * MSDOS does not revert to D1: after
   an error, but stays on the boot
   drive.
    
------------------------------------

MSDOS30.COM - Warsaw, 2005

This version supports XF 551 drives 
with HS, Happy Warp/US-Doubler
drives with High Speed, and Speedy HS
(only in US-Doubler mode).
When the program is using Happy
and US routines, MEMLO is $AFC.

SIO2IDE interface is working great
with this and later versions of
MSDOS!

------------------------------------

MSDOS23.COM - Warsaw, 2001

Pecus modified version with multi
disc operation.
Keys 1-8 - select working drive
and read the main directory.
        
------------------------------------


MSDOS22.COM - Prague, 93-05-03
            original BEWESOFT version
