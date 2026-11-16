# The SMF DIRECT PLAY page's two toggles (owner, 2026-11-16; naka_disk_menu_file_io.c): the getters and the setter.
# Run on every main-CPU tree's .s and cc900/*.c (and the notes that quote the names); the RAM cells themselves are
# renamed per tree by rename_smf_direct_play_cells_<tree>.sed, because their addresses differ between versions.
s/\bGetPlayState1\b/Smf_GetPlayAsGm/g
s/\bGetPlayState2\b/Smf_GetMidiOut/g
s/\bSmfMedley_RawData\b/Smf_SetMidiOut/g
