"""floppy/kn5000/formats.py -- the SX-KN5000 file-format describers (floppy/README.md).

describe(ctx) dispatches on the file's extension.  Formats not described yet return None (one
generic .incbin of the reference)."""

BOOT_NOTE = [
    'The KN5000 formatter writes these first 32 bytes: FDC_Format2HD_WriteBoot (v10/v9 0xf522f5)',
    'copies FDC_Format2HD_BootSectorHead (v10 0xe450da, v10/maincpu/ui_widgets/widget_descriptors.s),',
    'which is EB 1C 90 "Technics", this BPB and EB FE, byte for byte.  On these images the rest',
    'of the sector, signature word included, is zero.',
]


def describe(ctx):
    return None
