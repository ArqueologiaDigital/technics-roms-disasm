/* Functions of display/graphics_text_vga.s.  Firmware C (cc900 phase 6), built by scripts/build/cc900_firmware_c.py with the cc900 reference model;
   no Toshiba program.  Names are the tree's; ram_<hex> is a RAM cell the tree has not named yet. */
extern unsigned int GFX_BG_COLOR;

void Display_SetBackgroundColor(unsigned int c) { GFX_BG_COLOR = c; }
