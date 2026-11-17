/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of hdae5000_v1_10i/hdae5000_loadsong2.c (2026-11-17-13-hd-r42-ports)
   sha256 601083a765c1ea160f0a9ff82d991019896a0ddc9f15c69814ff1f3448e8613d (tar-sha256); compiled at -Xr
   cc900-options: -Xr */
extern unsigned char HDAE5000_RAM_FlsRecords[];
#define FLS(o, f, i) (*(unsigned char *)((unsigned long)&HDAE5000_RAM_FlsRecords[o] + ((unsigned long)(f) * 144 + (i))))
void HDAE5000_Fls_ForgetSong(unsigned int dir, unsigned int song)
{
    unsigned int i, j;

    for (i = 0; i < 120; i++) {
        for (j = 0; j < 32; j++) {
            if (FLS(16, i, j) == dir + 1 && FLS(48, i, j) == song + 1) {
                FLS(16, i, j) = 0;
                FLS(48, i, j) = 0;
                FLS(80, i, j) = 0;
                FLS(112, i, j) = 0;
            }
        }
    }
}
