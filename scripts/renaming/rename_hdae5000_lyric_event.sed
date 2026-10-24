# rename_hdae5000_lyric_event.sed -- 0x230430 is the parsed lyric event (meta type word first), not the end of
# LyricBuffer, although it follows it: Lyrics_ParseEvent stores the type there and tests it for 0x2F (end of track).
# Run (repository root):  LC_ALL=C sed -i -f scripts/renaming/rename_hdae5000_lyric_event.sed hdae5000/*.s
s/\bHDAE5000_RAM_LyricBufferEnd\b/HDAE5000_RAM_LyricEvent/g
