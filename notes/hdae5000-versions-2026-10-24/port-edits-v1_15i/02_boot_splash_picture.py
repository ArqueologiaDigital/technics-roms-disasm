"""The boot splash: v1.x's own palette and picture (hdae5000_data_tables.s).

v2.x's splash bytes occur nowhere in v1.15i; its splash differs in 762 of the palette's
1,024 bytes and in the picture, which has no "Version 2" line and reads "Startup !".
scripts/build/hdae5000_images.py VERSION_ASSETS['hdae5000_v1_15i'] exports both.
"""
from _edit import replace

replace("hdae5000_data_tables.s", [
    (b'''	; Built from images/HDAE5000_Palette_Splash.txt by scripts/build/hdae5000_images.py.
	; Was: .incbin "includes/code_29af2d_2fffff.bin", 306849, 1024
	.incbin "includes/generated/HDAE5000_Palette_Splash.bin"	; census: generated -- scripts/build/hdae5000_images.py, from hdae5000/images/HDAE5000_Palette_Splash.txt
''', b'''	; v1.x's own palette (762 of the 1,024 bytes differ from v2.x's), built from
	; hdae5000_v1_15i/images/HDAE5000_Palette_Splash_v1_15i.txt by
	; scripts/build/hdae5000_images.py.
	.incbin "includes/generated/HDAE5000_Palette_Splash_v1_15i.bin"	; census: generated -- scripts/build/hdae5000_images.py, from hdae5000_v1_15i/images/HDAE5000_Palette_Splash_v1_15i.txt
'''),
    (b'''	; Built from images/HDAE5000_SplashScreen.png by scripts/build/hdae5000_images.py.
	; Was: .incbin "includes/code_29af2d_2fffff.bin", 307873, 76800
	.incbin "includes/generated/HDAE5000_SplashScreen.bin"	; census: generated -- scripts/build/hdae5000_images.py, from hdae5000/images/HDAE5000_SplashScreen.png
''', b'''	; v1.x's own picture: the same wordmark and platter, but no "Version 2" line,
	; and "Startup !" for v2.x's "Start-up !".  Built from
	; hdae5000_v1_15i/images/HDAE5000_SplashScreen_v1_15i.png by
	; scripts/build/hdae5000_images.py.
	.incbin "includes/generated/HDAE5000_SplashScreen_v1_15i.bin"	; census: generated -- scripts/build/hdae5000_images.py, from hdae5000_v1_15i/images/HDAE5000_SplashScreen_v1_15i.png
'''),
])
print("ok")
