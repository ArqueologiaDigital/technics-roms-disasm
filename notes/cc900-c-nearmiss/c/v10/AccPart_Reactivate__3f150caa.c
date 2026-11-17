/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_A_1b.c (2026-11-16-31-p6-r1b)
   sha256 3f150caa4e8af344bb960480c9e2d9301aeff28c615c172cb13fb76c7a3f84d7 (tar-sha256); compiled at -Xr */
extern unsigned char __near ACC_PART_BIT;
extern unsigned char __near ram_33e0;
extern unsigned char __near ACC_LANES_ENDING1;
extern unsigned char __near ACC_LANES_ENDING2;
extern unsigned char __near ACC_LANES_PARKED;
extern unsigned char __near ACC_LANES_ENDED;
extern unsigned char __near ACC_LANES_FILLIN1;
extern unsigned char __near ACC_LANES_FILLIN2;
extern unsigned char __near ACC_LANES_INTRO1;
extern unsigned char __near ACC_LANES_COUNTIN;
extern unsigned char __near ACC_LANES_INTRO2;
extern unsigned char __near ram_335d;
extern unsigned char __near ram_3329;
extern unsigned char __near ACC_CUR_MEASURE;
extern unsigned int __near ACC_CUR_BLOCK;
extern unsigned int __near ACC_CUR_READ_POS;
void AccPart_Reactivate(void)
{
    unsigned char b;
    if (ACC_PART_BIT & ram_33e0) {
        if ((ACC_LANES_ENDING1 | ACC_LANES_ENDING2) & ACC_PART_BIT) {
            ACC_LANES_PARKED |= ACC_PART_BIT;
            ACC_LANES_ENDED |= ACC_PART_BIT;
            *(unsigned char *)&ACC_CUR_BLOCK = 254;
            *(unsigned char *)&ACC_CUR_READ_POS = 6;
        } else {
            b = ACC_PART_BIT ^ 0xff;
            ACC_LANES_FILLIN1 &= b;
            ACC_LANES_FILLIN2 &= b;
            ACC_LANES_INTRO1 &= b;
            ACC_LANES_COUNTIN &= b;
            ACC_LANES_INTRO2 &= b;
            ram_335d &= b;
            ram_3329 &= b;
            ACC_CUR_MEASURE = 0;
            *(unsigned char *)&ACC_CUR_BLOCK = 254;
            *(unsigned char *)&ACC_CUR_READ_POS = 6;
        }
    }
}
