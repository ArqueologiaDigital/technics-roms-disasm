/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of hd/hd_r4_ppa.c (2026-11-16-56-hd-r6)
   sha256 14f8b2f6e52a7b7c9306f45841db09c00b3f45a67e845be4f571123ab9e00578 (tar-sha256); compiled at -Xr
   cc900-name: PP_Svc27=HDAE5000_PPORT_Svc27_DeleteSongParts */
extern unsigned char HDAE5000_RAM_PportInfoBlock[];
#define PPIB HDAE5000_RAM_PportInfoBlock
#define PP_W(o) (*(unsigned int *)(PPIB + (o)))
extern int HDAE5000_DeleteSongParts(unsigned int dir, unsigned int song, unsigned int mask, int spin, int sleep);
int PP_Svc27(unsigned int dir, unsigned int song)
{
    HDAE5000_DeleteSongParts(dir, song, PP_W(0), 1, 0);
    return 0;
}
