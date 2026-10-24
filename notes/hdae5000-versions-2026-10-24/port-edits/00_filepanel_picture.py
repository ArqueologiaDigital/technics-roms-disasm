"""The file-selection backdrop: v2.01i's own palette and picture (hdae5000_data_tables.s).

A record of a one-off hand edit of hdae5000_v2_01i/ (see README.md here); it matches
exact text of the tree as it was then and will not apply again.
"""
import os
ROOT = os.path.dirname(os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__)))))
p = os.path.join(ROOT, 'hdae5000_v2_01i', 'hdae5000_data_tables.s')
s = open(p, 'rb').read()
old_pal = b'''HDAE5000_Palette_FilePanel:	; 0x2CE58E
	; 0x400 B = 256 RGBX entries but only 110 distinct colours: a long grey
	; ramp plus the blue stone texture used by the panel.  Copied to
	; 0x069400 by 0x28069D.
	; Built from images/HDAE5000_Palette_FilePanel.txt by scripts/build/hdae5000_images.py.
	; Was: .incbin "includes/code_29af2d_2fffff.bin", 210529, 1024
	.incbin "includes/generated/HDAE5000_Palette_FilePanel.bin"
'''
new_pal = b'''HDAE5000_Palette_FilePanel:
	; v2.01i's own palette for its own backdrop below (v2.06i's differs in
	; 326 of the 1,024 bytes).  Built from
	; hdae5000_v2_01i/images/HDAE5000_Palette_FilePanel_v2_01i.txt by
	; scripts/build/hdae5000_images.py.
	.incbin "includes/generated/HDAE5000_Palette_FilePanel_v2_01i.bin"
'''
old_bmp = b'''HDAE5000_Bitmap_FilePanel:	; 0x2CE98E
	; 320 x 240 @ 8bpp.  The file-selection panel background: three sunken
	; list wells over a blue stone fill, with the grey scroll strip along
	; the bottom.  Halves at 0x2CE98E and 0x2D7F8E.  Already extracted as
	; images/HDAE5000_FilePanel.bin.
	; Built from images/HDAE5000_FilePanel.png by scripts/build/hdae5000_images.py.
	; Was: .incbin "includes/code_29af2d_2fffff.bin", 211553, 76800
	.incbin "includes/generated/HDAE5000_FilePanel.bin"
'''
new_bmp = b'''HDAE5000_Bitmap_FilePanel:
	; 320 x 240 @ 8bpp.  The file-selection panel background, as v2.01i draws
	; it: the same three sunken list wells as v2.06i's, but over a magenta
	; marble fill instead of a plain dark one, and with five buttons in the
	; grey strip along the bottom where v2.06i has three.  Built from
	; hdae5000_v2_01i/images/HDAE5000_FilePanel_v2_01i.png by
	; scripts/build/hdae5000_images.py.
	.incbin "includes/generated/HDAE5000_FilePanel_v2_01i.bin"
'''
assert s.count(old_pal) == 1 and s.count(old_bmp) == 1
s = s.replace(old_pal, new_pal).replace(old_bmp, new_bmp)
open(p, 'wb').write(s)
print("ok")
