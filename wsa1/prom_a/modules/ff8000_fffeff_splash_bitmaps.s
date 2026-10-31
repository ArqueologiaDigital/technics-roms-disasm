; ==============================================================================
; 0xFF8000-0xFFF080 -- THREE 320 x 240 BITMAPS, and how the ROM says so
; ==============================================================================
;
; Converted 2026-08-25 by notes/gen_prom_a_splash.py.  Verified by
; notes/prom_a_splash_checks.py.
;
; ★ THE GEOMETRY IS THE CALLER'S, NOT A GUESS.  prom_a 0xF94131 is
;
;     ld XIY,0x00FF8000 / ldw IX,0x0000 / ldw HL,0x00F0 / ldw BC,0x0028
;     ldb A,0x03 / swi 7
;
;   and SWI7 service 0x03 is `LCD_Svc_03_BlitColumns` (0xF8EDB4), whose header
;   in this file reads: XIY = source, BC = number of COLUMNS, HL = bytes down
;   each column, IX = the destination offset within the current layer.  So
;   BC = 40 columns, HL = 240 bytes per column, 40 x 240 = 9,600 bytes, and the
;   routine issues CSRDIR DOWN before it starts -- the source is stored
;   COLUMN-MAJOR and lands row-major in display RAM.
;
;   40 bytes x 8 pixels = 320 wide, 240 tall, which is exactly the panel:
;   notes/FINDINGS-display-controller.md reads C/R = 0x27+1 = 40 and
;   L/F = 0xEF+1 = 240 off the SED1330's own SYSTEM SET bytes.
;
;   PIXEL (x, y) IS BIT (7 - x%8) OF BYTE (x/8)*240 + y.
;
; ★ AND THE THREE IMAGES TILE THE REGION: 0xFF8000 + 3 x 9,600 = 0xFFF080,
;   where 3,712 bytes of 0x0E padding run to the vector table at 0xFFFF00.
;   Each of the three is named by its own blit site -- 0xFF8000 at 0xF94131,
;   0xFFA580 at 0xF94142, 0xFFCB00 at 0xF941D3 -- and no other address in this
;   region is named by anything in either image.
;
; ★ IMAGES 0 AND 1 ARE COMPLEMENTARY HALVES OF ONE DITHERED PICTURE, and that
;   is arithmetic rather than impression: they have **NO SET BIT IN COMMON**
;   (bitwise AND over all 9,600 bytes is zero), and their popcounts are EQUAL
;   -- 3983 and 3983, summing to 7966.  Two disjoint half-tones of the same
;   artwork, going to two different display layers (IX = 0x0000 and IX =
;   0x4C00, and 0x4C00 is SAD3, the third layer's base).  The SED1330
;   OR-composites its layers, so together they make the solid shape; alone,
;   either is a 50% grey of it.
;
; ⚠ WHAT THE ARTWORK SAYS was left open for images 0 and 1 until 2026-09-02
;   (closed just below).  The preview
;   below shows a large italic script logotype in four glyph-like clusters,
;   occupying rows 72-153 of the panel.  This file does not name it.
; ★ CLOSED 2026-09-02, lane IMAGE.  Images 0 and 1 are committed as PNGs --
;   images/SplashImage_DitherA.png and images/SplashImage_DitherB.png -- and
;   opened together (they are disjoint half-tones the panel OR-composites) they
;   read `WSA` in a brush script.  ASCII art at 2x3 could not show that; an
;   image file can.  See notes/FINDINGS-image-files.md section 3.  ⚠ Felipe's
;   hardware testimony still outranks this: a photograph of a real SX-WSA1 at
;   power-on is the last word.
;
;   Image 2 is different: it is plainly the word `Technics` in a bold face, and the preview
;   shows it.  ⚠ MIXED CASE, corrected 2026-08-25 -- an earlier draft of this
;   line wrote it TECHNICS.  Re-rendered from the ROM at full resolution with
;   this file's own formula (bit 7-x%8 of byte (x/8)*240+y over the 320 x 240
;   geometry stated above), the glyphs are a capital T followed by lowercase
;   e c h n i c s,
;   the `i` carries its dot at row 89, and the ink occupies rows 89-121 and
;   columns 43-275.  That is the Technics logotype as the brand sets it.
; ==============================================================================

; ---------------------------------------------------------------------
; SplashImage_DitherA -- 9,600 bytes, 0xFF8000-0xFFA57F
;
; Blitted by 0xF94131 with IX = 0x0000, i.e. to offset 0 of the layer that
; (0x2540) selects -- layer 0, base 0x0000 (SAD1).  Paint_PowerOnSplash does not
; write (0x2540) before this blit; it relies on layer 0, the only layer under
; which this half lands at display RAM 0x0000, where its scroll of layer 0 back
; to SAD 0 ends (notes/open4-d-probes/splash_layer_and_logo.py).  With
; SplashImage_DitherB it reads `WSA` in a brush script.  One of the two
; disjoint dither halves.
; Non-empty rows: 72-153.  Preview, OR-downsampled 2x3:
; ---------------------------------------------------------------------
;                                                                                       ########                 ######
;                                       ###                                          ############              ######### ##                          ##  ##
;                                    #######                                      ################           ##############                     #####
;                                  ###########                              ##   ################           ###############                 ######
;                               ###############                           ###################             ################              ########
;                            #################                           ##################             ##################           #########
;                         ####################                         #################              ####################        ############
;                      ######################                         ################               ############ ########    #############   #
;                   #############  #########        ####            ###############                ############    #########################
;                #############     ########       ########         ################               ############     ################# ####
;                                 ########      ##########        ###############               ############      ############## ####
;                                #########     ###########       ################              ############       ############ ###
;                               #########    #############     ##################            ############      ################
;                               #########   ##############     ##################           ############     ###############
;                              #########  ################   ###########  ########        ############    #################
;                              ########  #################   ##########     #######      ############    #################
;                             ################### ########  ##########       ########   ############   ###################
;                             ##################  ######## ##########          ####################  #####################
;                             ################    #################             ################     #####################
;                            ################     ################                ######## ####        ######### ########
;                            ##############       ###############                 #########              ######## ########
;                            ############           ############                ###########                 ##############
;                             #########             ###########           #################                   ###########
;                            #########                ########        ####################                       #########
;                             ## ###                     ###         ####################                         #######
;                                                                      ################                               ###
;                                                                         #########
;                                                                           #
; ---------------------------------------------------------------------
SplashImage_DitherA:
	.incbin	"images/SplashImage_DitherA.bin", 0, 9600	; census: generated -- scripts/build/wsa1_bitmaps.py, from the .png beside it


; ---------------------------------------------------------------------
; SplashImage_DitherB -- 9,600 bytes, 0xFFA580-0xFFCAFF
;
; Blitted by 0xF94142 with IX = 0x4C00 into the same layer 0 (base 0x0000), so
; to display RAM 0x4C00 -- SAD3, the third graphics layer's base
; (notes/FINDINGS-display-controller.md sec. on SCROLL).  The other dither half:
; it shares no set bit with the first and has the same number of them.
; Non-empty rows: 72-153.  Preview, OR-downsampled 2x3:
; ---------------------------------------------------------------------
;                                                                                       #########                #######
;                                       ##                                           #############             ######### ##                         ## #
;                                    #######                                       ################           #############                      #####
;                                 ############                             ##   #################          ################                 #####
;                               ###############                           ####################            #################             #########
;                            #################                          ##################              ##################          ##########
;                         ####################                          ################               ###################        ############
;                      ######################                         ################               ############ ########    ############
;                   ##############  ########        ####             ###############               #############   ######## ########### ####
;               ##############     ########       ########         ###############               #############    #######################
;               #         #       #########      #########        ###############               #############     ##############  ###
;                                #########    ############      #################             #############       ###########  ###
;                                ########    #############      #################            ############       ########### ###
;                               ########   ###############    ###################          ############      ###############
;                              #########  ################    ##########   #######        ############     ###############
;                              ########  #################   ##########    ########      ############    #################
;                              ######## ##################  ##########       ########   ############   ###################
;                             ##################  ##################          ####################  #####################
;                             ################    ##################             ################    #####################
;                            ###############      ################                ######## #  #        ########  #########
;                            ##############        ##############                 #########               ################
;                            ############           ############                ##########                  #############
;                            ###########             ##########             ###############                    ###########
;                             ########               ########         ####################                      #########
;                              ######                     ###         ###################                          ######
;                                                                     #################                               ###
;                                                                         ##########
;                                                                           #
; ---------------------------------------------------------------------
SplashImage_DitherB:
	.incbin	"images/SplashImage_DitherB.bin", 0, 9600	; census: generated -- scripts/build/wsa1_bitmaps.py, from the .png beside it


; ---------------------------------------------------------------------
; SplashImage_Wordmark -- 9,600 bytes, 0xFFCB00-0xFFF07F
;
; Blitted by 0xF941D3, which sets (0x2540) = 1 immediately before it and passes
; IX = 0x0000.  Not dithered: solid pixels.
; Non-empty rows: 89-121 -- a single band of large letterforms.  Preview,
; OR-downsampled 2x3:
; ---------------------------------------------------------------------
;                        ###################                          #######                                ######
;                        ###################                          #######                                ######
;                        ###    #####    ###                            #####                                 ####
;                        ###    #####    ##############     ########### #############     ##############    ######    ###########  ###########
;                               #####     #######  #####  ####### ##### ##############    ###############   ######   ######  #### ############
;                               #####     #####     ##### #####     ### #####    ######     ####    #####     ####  #####      ## #####     ##
;                               #####    #####################          #####    ######     ####     ####     ####  #####         ##########
;                               #####    #####################          #####    ######     ####     ####     ####  #####            #########
;                               #####     #####      #### #####     ### #####    ######     ####     ####     ####  ######    ### ##     #####
;                             #########    #############  ############################### ################# ######## ############ ############
;                             #########      #########      ########  ################### ################# ########   ########   ###########
; ---------------------------------------------------------------------
SplashImage_Wordmark:
	.incbin	"images/SplashImage_Wordmark.bin", 0, 9600	; census: generated -- scripts/build/wsa1_bitmaps.py, from the .png beside it

; 0xFFF080-0xFFFEFF -- 3712 bytes of 0x0E (RET), image-area padding.
; Checked byte by byte, not sampled: this generator refuses to
; emit the directive unless set(ROM[lo:hi]) == {0x0E}.
	.fill 3712, 1, 0x0E
