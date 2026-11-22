/* Probe round 35r1, helper A, form b: audio/dsp_config_sysex.s (module 293), xr_screen family.
   DSPCfg_ClampAndExtract as form a, with id unsigned (no cast at the index) and the slot-count test written
   `>=` first (-1 as the then-arm). */
/* cc900-module: DSPCfg_ClampAndExtract DSPCfg_ExtractPairFromStruct DSPCfg_GetSlotCount DSPCfg_ReadParam_Map0 DSPCfg_ResolveParamToSlot DSPCfg_StoreByte_ReturnZero DSPCfg_ValidateSlotForWrite DSPCfg_WriteViaTableLookup */

struct dsp6 { unsigned char b[6]; };
extern struct dsp6 *DSPCfg_LookupAndExtract_PtrTable[];
extern unsigned int DSPCfg_GetSlotCount(unsigned int);
extern void DSPCfg_ExtractPairFromStruct(struct dsp6 *, int *, int *, int *, int *);
extern int DSPCfg_ClampAndExtract(unsigned int, unsigned int, int *);

int DSPCfg_ClampAndExtract(register unsigned int id, unsigned int slot, int *p)
{
    int r;
    int min;
    int max;
    int b;
    int a;
    int v;

    v = *p;
    if (slot >= DSPCfg_GetSlotCount(id))
        r = -1;
    else {
        DSPCfg_ExtractPairFromStruct(DSPCfg_LookupAndExtract_PtrTable[id] + slot, &min, &max, &a, &b);
        if (v < min) {
            r = -2;
            v = min;
        } else if (v > max) {
            r = -3;
            v = max;
        } else
            r = 0;
    }
    *p = v;
    return r;
}

/* DSPCfg_WriteParamSimple / DSPCfg_WriteParamFull as form a, with the two table outputs as int locals, AssswbWr
   prototyped with int parameters, and the 0x4900 test written as a switch (cases 0x0f, 0x35). */
/* cc900-module: DSPCfg_ReadParam_Map0 DSPCfg_ResolveParamToSlot DSPCfg_StoreByte_ReturnZero DSPCfg_ValidateSlotForWrite DSPCfg_WriteViaTableLookup */

extern int DSPCfg_ResolveParamToSlot(unsigned long id, unsigned char **slot, int *grp, int *offs, int *kind, int *cnt);
extern int DSPCfg_ValidateSlotForWrite(int, int);
extern int DSPCfg_StoreByte_ReturnZero(int, unsigned char *);
extern int DSPCfg_WriteViaTableLookup(int, int, unsigned char *, int *, int *);
extern int DSPCfg_ReadParam_Map0(unsigned long);
extern void SoundParam_NotifyChange(long, int, int);
extern void AssswbWr(int, int, int, int);
extern unsigned char DspBlock_ObjectCode_Table[];
extern int DSPCfg_WriteParamSimple(unsigned long, int, unsigned char *);
extern int DSPCfg_WriteParamFull(unsigned long, int);

int DSPCfg_WriteParamFull(unsigned long id, int value)
{
    unsigned char *slot;
    int hi;
    int lo;
    int cnt;
    int grp;
    int offs;
    int kind;
    register int r;

    r = DSPCfg_ResolveParamToSlot(id, &slot, &grp, &offs, &kind, &cnt);
    if (r == 0) {
        switch (kind) {
        case 0:
            r = DSPCfg_ValidateSlotForWrite(value, grp);
            if (r == -1)
                break;
            r = DSPCfg_StoreByte_ReturnZero(value, slot);
            AssswbWr(DspBlock_ObjectCode_Table[(unsigned int)grp], 0, (unsigned char)(value & 0xff), 0xff);
            break;
        case 1:
            r = DSPCfg_ClampAndExtract(cnt, offs, &value);
            if (r != -1) {
                if (r == 0)
                    r = DSPCfg_WriteViaTableLookup(offs, value, slot, &hi, &lo);
                else
                    DSPCfg_WriteViaTableLookup(offs, value, slot, &hi, &lo);
                AssswbWr(DspBlock_ObjectCode_Table[(unsigned int)grp], (unsigned char)(hi + 1),
                         (unsigned char)(value & 0xff), (unsigned char)lo);
            }
            if (id == 0x491d) {
                switch (DSPCfg_ReadParam_Map0(0x4900)) {
                case 0xf:
                case 0x35:
                    SoundParam_NotifyChange(0x4003, value, 3);
                    break;
                }
            }
            break;
        default:
            r = -1;
            break;
        }
    }
    return r;
}

int DSPCfg_WriteParamSimple(unsigned long id, int value, unsigned char *dst)
{
    unsigned char *slot;
    int hi;
    int lo;
    int cnt;
    int grp;
    int offs;
    int kind;
    register int r;

    r = DSPCfg_ResolveParamToSlot(id, &slot, &grp, &offs, &kind, &cnt);
    if (r == 0) {
        switch (kind) {
        case 0:
            r = DSPCfg_ValidateSlotForWrite(value, grp);
            if (r == -1)
                break;
            r = DSPCfg_StoreByte_ReturnZero(value, dst);
            break;
        case 1:
            r = DSPCfg_ClampAndExtract(cnt, offs, &value);
            if (r != -1) {
                if (r == 0)
                    r = DSPCfg_WriteViaTableLookup(offs, value, dst, &hi, &lo);
                else
                    DSPCfg_WriteViaTableLookup(offs, value, dst, &hi, &lo);
            }
            if (id == 0x491d) {
                switch (DSPCfg_ReadParam_Map0(0x4900)) {
                case 0xf:
                case 0x35:
                    SoundParam_NotifyChange(0x4003, value, 3);
                    break;
                }
            }
            break;
        default:
            r = -1;
            break;
        }
    }
    return r;
}
