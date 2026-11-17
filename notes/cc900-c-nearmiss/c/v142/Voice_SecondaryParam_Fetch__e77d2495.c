/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of sub/sub_C_2a.c (2026-11-16-47-sub-r2)
   sha256 e77d2495b549821b0ba06f8b78d5c1927c12696a39635b76364de81b0b34400e (name+funcs); compiled at -Xr */
extern unsigned char ram_4136e[];
extern unsigned char ram_41372[];
extern unsigned char Voice_SecondaryParam_Curve[];
#define PART_W72(p)     (*(unsigned int *)(ram_41372 + (p) * 0x11f))
#define PART_PATCH(p)   (*(unsigned char **)(ram_4136e + (p) * 0x11f))
unsigned char Voice_SecondaryParam_Fetch(unsigned char part)
{
    if (PART_W72(part) & 0x8000L) {
        if ((PART_PATCH(part)[93] & 0xf) == 9) return Voice_SecondaryParam_Curve[PART_PATCH(part)[94]];
        else return 0xff;
    }
    return 0xff;
}
