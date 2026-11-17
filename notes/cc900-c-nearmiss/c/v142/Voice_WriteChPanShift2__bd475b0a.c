/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of sub/sub_B_8b.c (2026-11-16-82-sub-r8)
   sha256 bd475b0a234905c6efb6c6e86ec9471fb95bc7b36e30ff14fef91b19d3700a28 (name+funcs); compiled at -Xr */
extern unsigned int ram_451e6;
extern unsigned int ram_451e8;
extern int Int_ClampSignedToRange(int a, int hi, int lo);
void Voice_WriteChPanShift2(unsigned char *v, unsigned char flag)
{
    int l, r;
    if ((*(unsigned int *)(*(unsigned char **)(v + 39) + 24) & 0x100) && (*(unsigned int *)(v + 64) & 0xff)) {
        if (*(unsigned int *)(*(unsigned char **)(v + 39) + 24) & 0x200) {
            l = *(unsigned int *)(v + 62) & 0x7f;
            l -= (*(char **)(v + 35))[32];
            r = *(unsigned int *)(v + 64) & 0x7f;
            r -= (*(char **)(v + 35))[32];
        } else {
            l = *(unsigned int *)(v + 62) & 0x7f;
            l += (*(char **)(v + 35))[32];
            r = *(unsigned int *)(v + 64) & 0x7f;
            r += (*(char **)(v + 35))[32];
        }
        l = Int_ClampSignedToRange(l, 0x7f, 4);
        r = Int_ClampSignedToRange(r, 0x7f, 0);
        if (flag != 0) ram_451e8 = r | 0x8000;
        else ram_451e8 = (r & 0xff) | (*(unsigned int *)(v + 64) & 0xff00);
        ram_451e6 = (l & 0xff) | (*(unsigned int *)(v + 62) & 0xff00);
    } else {
        ram_451e6 = *(unsigned int *)(v + 62);
        ram_451e8 = *(unsigned int *)(v + 64);
    }
}
