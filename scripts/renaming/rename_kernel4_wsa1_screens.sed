# rename_kernel4_wsa1_screens.sed -- lane open10/kernel4, 2026-11-06 (register item N-1e4a337c):
# prom_a 0xFF657B counts presses of two keys on FLOPPY DISK FORMAT and then requests the empty screen 0x52
# (wsa1/notes/open10-kernel4-probes/format_screen_requests.py).
s/\<sub_FF657B\>/HiddenKey_FloppyDiskFormatSelectType/g
