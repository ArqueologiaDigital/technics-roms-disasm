/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_R_31r1m236b.c (2026-11-22-15-p6-r82)
   sha256 e4d13e98413a89c5200da790afad82efe1a381c0a0fa06765d15b9d7d99ab16b (tar-sha256); compiled at -O3 -Xr */
extern unsigned char __near SEQ_ERROR_CODE;
struct bo { unsigned int block; unsigned int offset; };
extern unsigned char __near SEQ_EDIT_FLAGS;
extern unsigned long __near ram_25da;
extern unsigned long __near ram_27e4;
extern unsigned int __near ram_27e8;
extern unsigned int __near ram_27ea;
extern unsigned int __near ram_27ec;
extern unsigned int __near ram_27ee;
extern unsigned int __near ram_265c;
extern unsigned int __near ram_265e;
extern struct bo __near ram_282c;
extern struct bo __near ram_2830;
extern struct bo __near ram_2834;
extern void PartCtrl_FindActiveByLimit(unsigned int *, unsigned int *);
extern void SeqPart_CopyDataPrimary(void);
extern unsigned int PartCtrl_ReadWord_Off1(unsigned int);
extern void Part_WriteWordAndByte(unsigned int, unsigned int);
extern void Part_CheckAndReallocVoices(unsigned int);
extern unsigned char PartCtrl_TestBit7(unsigned int);
extern void SeqPart_UndoAllocOnError(void);
void SeqPart_PositionBackward(void)
{
    unsigned long d;
    unsigned int n;

    d = ram_27e4 - ram_25da;
    if ((SEQ_EDIT_FLAGS & 0x10) && !(SEQ_EDIT_FLAGS & 0x08))
        d--;
    ram_25da = d;
    ram_27ec = ram_27e8;
    ram_27ee = ram_27ea;
    PartCtrl_FindActiveByLimit(&ram_27ec, &ram_27ee);
    if (SEQ_ERROR_CODE != 0) goto fail;
    ram_282c.block = ram_27e8;
    ram_282c.offset = ram_27ea;
    ram_2830.block = ram_27ec;
    ram_2830.offset = ram_27ee;
    ram_2834.block = ram_265c;
    ram_2834.offset = ram_265e;
    SeqPart_CopyDataPrimary();
    if (SEQ_ERROR_CODE != 0) goto fail;
    n = ram_2834.offset;
    if (n == 5) {
        ram_2834.block = PartCtrl_ReadWord_Off1(ram_2834.block);
        if (ram_2834.block == 0) goto fail;
        ram_2834.offset = 0xff;
    } else
        ram_2834.offset = n - 1;
    if (SEQ_EDIT_FLAGS & 0x08) {
        ram_265e = ram_27ee;
        ram_265c = ram_27ec;
    }
    Part_WriteWordAndByte(ram_265c, (unsigned char)ram_265e);
    Part_CheckAndReallocVoices(ram_265c);
    if (SEQ_ERROR_CODE != 0) goto fail;
    if ((SEQ_EDIT_FLAGS & 0x10) && !(SEQ_EDIT_FLAGS & 0x08)) {
        if (--ram_27ee < 5) {
            ram_27ec = PartCtrl_ReadWord_Off1(ram_27ec);
            if (ram_27ec == 0) {
                SEQ_ERROR_CODE = 10;
                goto fail;
            }
            if (PartCtrl_TestBit7(ram_27ec) == 0) {
                SEQ_ERROR_CODE = 11;
fail:
                SeqPart_UndoAllocOnError();
            }
        }
    }
}
