/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of hdae5000_v1_10i/hdae5000_flsitem2.c (2026-11-17-17-hd-r45-ports)
   sha256 7acef2dd73a6f56c2491dd150c7817f8a84715aaa667857864a17956dbcea9d9 (tar-sha256); compiled at -Xr
   cc900-options: -Xr */
extern unsigned char HDAE5000_RAM_FlsRecords[];
struct FlsItem { unsigned int dir; unsigned int song; unsigned char as; unsigned char al; };
#define FLSB(o, f, i) (*(unsigned char *)((unsigned long)&HDAE5000_RAM_FlsRecords[o] + ((unsigned long)(f) * 144 + (i))))
int HDAE5000_FlsItem_IsSet(unsigned int fls, unsigned int item);
void HDAE5000_FlsItem_Get(unsigned int fls, unsigned int item, struct FlsItem *out)
{
    unsigned int r;
    (void)&fls;
    if ((r = HDAE5000_FlsItem_IsSet(fls, item)) != 0xffff) {
        out->dir = (unsigned char)(FLSB(16, fls, item) - 1);
        out->song = (unsigned char)(FLSB(48, fls, item) - 1);
        out->as = FLSB(80, fls, item);
        out->al = FLSB(112, fls, item);
    }
}
