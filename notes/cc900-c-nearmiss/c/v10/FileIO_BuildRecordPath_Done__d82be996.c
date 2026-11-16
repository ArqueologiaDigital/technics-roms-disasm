/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_m9a.c (2026-11-16-22-p6-m9)
   sha256 d82be9969bfcff2f1bb280e2fa82aeed8573c9916cec0bb8d50ccc60ae4d54b0 (name+funcs); compiled at (no flags) */
extern unsigned int ram_272cc, ram_272ce, DEMO_ACTIVE_ENTRY, DemoSong_EntryCol[];
void FileIO_BuildRecordPath_Done(unsigned char a) { if (a < 10) ram_272ce |= 1 << a; }
