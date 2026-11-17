/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of sub/sub_Q_17a.c (2026-11-16-126-sub-r17)
   sha256 ac0e9204f80496a2a00e80ac0c4a0b41db26241507df15b2c4016b2c7863b004 (name+funcs); compiled at -Xr */
extern unsigned int ram_451e6;
extern unsigned int ram_451e8;
extern int Int_ClampSignedToRange(int a, int hi, int lo);
void Voice_WriteChPanShift2(unsigned char *v, unsigned char flag)
{
    int l, r, s;
    if ((*(unsigned int *)(*(unsigned char **)(v + 39) + 24) & 0x100) && (*(unsigned int *)(v + 64) & 0xff)) {
        if (*(unsigned int *)(*(unsigned char **)(v + 39) + 24) & 0x200) {
            s = (*(char **)(v + 35))[32];
            l = *(unsigned int *)(v + 62) & 0x7f;
            l -= s;
            s = (*(char **)(v + 35))[32];
            r = *(unsigned int *)(v + 64) & 0x7f;
            r -= s;
        } else {
            s = (*(char **)(v + 35))[32];
            l = *(unsigned int *)(v + 62) & 0x7f;
            l += s;
            s = (*(char **)(v + 35))[32];
            r = *(unsigned int *)(v + 64) & 0x7f;
            r += s;
        }
        l = Int_ClampSignedToRange(l, 0x7f, 4);
        r = Int_ClampSignedToRange(r, 0x7f, 0);
        if (flag != 0) ram_451e8 = r | 0x8000;
        else ram_451e8 = (*(unsigned int *)(v + 64) & 0xff00) | (r & 0xff);
        ram_451e6 = (*(unsigned int *)(v + 62) & 0xff00) | (l & 0xff);
    } else {
        ram_451e6 = *(unsigned int *)(v + 62);
        ram_451e8 = *(unsigned int *)(v + 64);
    }
}
