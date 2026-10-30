"""v1.x has no file-selection backdrop picture: drop v2.01i's from hdae5000_data_tables.s.

hdae5000_version_delta.py v2_01i:v1_15i maps v2.01i's 77,824 bytes at 0x2cdd9c (palette and
picture) onto nothing in v1.15i, and v2.06i's FilePanel bytes occur nowhere in the v1.15i
image, while Logo, DriveMech, the HDD icon and their palettes occur there unchanged.  The
two labels stay, empty, until the code that read them (HDAE5000_Alloc_Memory_3,
HDAE5000_TtlScreenR3Proc) is ported.
"""
from _edit import replace

replace("hdae5000_data_tables.s", [
    (b'''	; hdae5000_v2_01i/images/HDAE5000_Palette_FilePanel_v2_01i.txt by
	; scripts/build/hdae5000_images.py.
	.incbin "includes/generated/HDAE5000_Palette_FilePanel_v2_01i.bin"
''', b'''	; hdae5000_v2_01i/images/HDAE5000_Palette_FilePanel_v2_01i.txt by
	; scripts/build/hdae5000_images.py.
'''),
    (b'''	; scripts/build/hdae5000_images.py.
	.incbin "includes/generated/HDAE5000_FilePanel_v2_01i.bin"
''', b'''	; scripts/build/hdae5000_images.py.
'''),
])
print("ok")
