/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_m9b.c (2026-11-16-22-p6-m9)
   sha256 5061182033df816bd8c38592a9bae7f8131de911549bf9c89a81971297466b2d (name+funcs); compiled at (no flags) */
extern unsigned int ram_272cc, ram_272ce, DEMO_ACTIVE_ENTRY, DemoSong_EntryCol[];
void FileIO_FormatName_Loop(unsigned char a) { unsigned int b = 1; if (a >= 10) return; b <<= a; ram_272cc |= b; }
