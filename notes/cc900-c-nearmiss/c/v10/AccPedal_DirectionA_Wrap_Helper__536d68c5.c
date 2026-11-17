/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_A_16a.c (2026-11-16-100-p6-r19)
   sha256 536d68c5f63c70de9d18f69197f3e601618301b5706aa5a6952db8278237746d (tar-sha256); compiled at -O3 -Xr */
extern unsigned int __near ACC_CUR_BLOCK;
extern unsigned int __near ACC_CUR_READ_POS;
extern unsigned char AccPart_BitToIndexTable[];
void AccPedal_DirectionA_Wrap_Helper(unsigned char bit)
{
    if (bit == 2)
        ACC_CUR_BLOCK = 0xfffe;
    else
        ACC_CUR_BLOCK = (*(unsigned int **)0x3426)[AccPart_BitToIndexTable[bit]];
    ACC_CUR_READ_POS = 6;
}
