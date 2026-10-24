# rename_wp17_ram.sed -- WP17 RAM-name corrections (sed -i -f, LC_ALL=C; the .s files hold raw high bytes)
# 0x0420 gates PLAY_CLOCK / PLAY_BEAT_COUNT (0x417 / 0x418); the accompaniment clock ACC_CLOCK / ACC_BEAT is gated by 0x041E,
# which takes the name ACC_TRANSPORT_STATE (AccPlayMode_StartAccPlay, AccAutoPlay_* bit 2).
s/\<ACC_TRANSPORT_STATE\>/PLAY_TRANSPORT_STATE/g
