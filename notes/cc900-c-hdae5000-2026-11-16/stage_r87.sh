#!/bin/bash
# stage_r87.sh TREE...: stage round 87's matching per-tree C (runs 2026-11-20-1-hd-r87-v1gap, -2-hd-r87b-v201lyr)
# into TREE/cc900-staged/.  v1 trees take the hd_r87a_* functions, v2.01i the hd_r87b_* ones.  Run from the
# repository root.  Which functions matched: hd_v423.py --check RUN --dir TREE --image IMG (all of them, per tree).
set -eu
S=notes/cc900-c-hdae5000-2026-11-16
P=$S/probes
for T in "$@"; do
    O=$T/cc900-staged
    mkdir -p "$O"
    case $T in
    hdae5000_v1_15i|hdae5000_v1_10i)
        W="$T: v1.x per-tree C, round 87 (2026-11-20), run 2026-11-20-1-hd-r87-v1gap"
        python3 -B $S/stage_from_probe.py $P/hd_r87a_showflags_fs__v1.c $O/hdae5000_showflags_fs__v1_r87.c "$W" \
            HDAE5000_FdList_Redisplay HDAE5000_DelOpt_ShowFlags
        python3 -B $S/stage_from_probe.py $P/hd_r87a_showflags_drv__v1.c $O/hdae5000_showflags_drv__v1_r87.c "$W" \
            HDAE5000_TypeSel_ShowSaveFlags
        python3 -B $S/stage_from_probe.py $P/hd_r87a_ui_display__menuvis_v1.c $O/hdae5000_ui_display__menuvis_v1_r87.c \
            "$W" HDAE5000_Set_Menu_Visibility
        python3 -B $S/stage_from_probe.py $P/hd_r87a_file_load_screen__v1.c $O/hdae5000_file_load_screen__v1_r87.c \
            "$W" HDAE5000_FILE_LOAD_Screen
        python3 -B $S/stage_from_probe.py $P/hd_r87a_setup_copy_filesystem__copytohd_v1.c \
            $O/hdae5000_setup_copy_filesystem__copytohd_v1_r87.c "$W" HDAE5000_CopyToHDScreen
        python3 -B $S/stage_from_probe.py $P/hd_r87a_boot__framehandler_v1.c $O/hdae5000_boot__framehandler_v1_r87.c \
            "$W" FrameH_a
        ;;
    hdae5000_v2_01i)
        W="$T: v2.01i per-tree C, round 87 (2026-11-20), run 2026-11-20-2-hd-r87b-v201lyr"
        python3 -B $S/stage_from_probe.py $P/hd_r87b_lyrics__songinfo_v201.c $O/hdae5000_lyrics__songinfo_v201_r87.c \
            "$W" HDAE5000_Lyrics_ReadVarLen HDAE5000_Lyrics_ReadSongInfo
        ;;
    *) echo "stage_r87.sh: unknown tree $T" >&2; exit 1 ;;
    esac
done
