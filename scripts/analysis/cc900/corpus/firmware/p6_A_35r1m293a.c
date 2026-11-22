/* Probe round 35r1, helper A, form a: audio/dsp_config_sysex.s (module 293), xr_screen family.
   DSPCfg_ClampAndExtract(id, slot, p): -1 when slot is not below block id's slot count; else read the slot's
   min / max (6-byte record of DSPCfg_LookupAndExtract_PtrTable[id]) and clamp *p into it: -2 raised to min,
   -3 lowered to max, 0 in range.  id is a `register` parameter (IZ); locals declared in reverse frame-slot
   order (V4.23 gives the last-declared local the lowest slot: SeMenu_SetupSoundBankPair). */
/* cc900-module: DSPCfg_ClampAndExtract DSPCfg_ExtractPairFromStruct DSPCfg_GetSlotCount DSPCfg_ReadParam_Map0 DSPCfg_ResolveParamToSlot DSPCfg_StoreByte_ReturnZero DSPCfg_ValidateSlotForWrite DSPCfg_WriteViaTableLookup */

struct dsp6 { unsigned char b[6]; };
extern struct dsp6 *DSPCfg_LookupAndExtract_PtrTable[];
extern unsigned int DSPCfg_GetSlotCount(int);
extern void DSPCfg_ExtractPairFromStruct(struct dsp6 *, int *, int *, int *, int *);
extern int DSPCfg_ClampAndExtract(int, unsigned int, int *);

int DSPCfg_ClampAndExtract(register int id, unsigned int slot, int *p)
{
    int r;
    int min;
    int max;
    int b;
    int a;
    int v;

    v = *p;
    if (slot < DSPCfg_GetSlotCount(id)) {
        DSPCfg_ExtractPairFromStruct(DSPCfg_LookupAndExtract_PtrTable[(unsigned int)id] + slot, &min, &max, &a, &b);
        if (v < min) {
            r = -2;
            v = min;
        } else if (v > max) {
            r = -3;
            v = max;
        } else
            r = 0;
    } else
        r = -1;
    *p = v;
    return r;
}

/* DSPCfg_WriteParamSimple(id, value, dst) / DSPCfg_WriteParamFull(id, value): resolve parameter id to its slot;
   kind 0 = a byte (validate, store), kind 1 = a table value (clamp, write through the table); for 0x491d (chorus
   type) notify 0x4003 when block 0x4900 reads 0x35 or 0x0f.  Full also re-sends the value to the tone generator
   (AssswbWr).  The result is a `register` local (IZ); the outputs of DSPCfg_ResolveParamToSlot are frame locals
   declared in reverse slot order; value's address is taken for the clamp. */
/* cc900-module: DSPCfg_ReadParam_Map0 DSPCfg_ResolveParamToSlot DSPCfg_StoreByte_ReturnZero DSPCfg_ValidateSlotForWrite DSPCfg_WriteViaTableLookup */

extern int DSPCfg_ResolveParamToSlot(unsigned long id, unsigned char **slot, int *grp, int *offs, int *kind, int *cnt);
extern int DSPCfg_ValidateSlotForWrite(int, int);
extern int DSPCfg_StoreByte_ReturnZero(int, unsigned char *);
extern int DSPCfg_WriteViaTableLookup(int, int, unsigned char *, unsigned char *, unsigned char *);
extern int DSPCfg_ReadParam_Map0(unsigned long);
extern void SoundParam_NotifyChange(long, int, int);
extern void AssswbWr();
extern unsigned char DspBlock_ObjectCode_Table[];
extern int DSPCfg_WriteParamSimple(unsigned long, int, unsigned char *);
extern int DSPCfg_WriteParamFull(unsigned long, int);

int DSPCfg_WriteParamFull(unsigned long id, int value)
{
    unsigned char *slot;
    unsigned char hi;
    unsigned char lo;
    int cnt;
    unsigned int grp;
    int offs;
    int kind;
    register int r;
    int t;

    if ((r = DSPCfg_ResolveParamToSlot(id, &slot, (int *)&grp, &offs, &kind, &cnt)) == 0) {
        switch (kind) {
        case 0:
            r = DSPCfg_ValidateSlotForWrite(value, grp);
            if (r != -1) {
                r = DSPCfg_StoreByte_ReturnZero(value, slot);
                AssswbWr(DspBlock_ObjectCode_Table[grp], 0, (unsigned char)(value & 0xff), 0xff);
            }
            break;
        case 1:
            r = DSPCfg_ClampAndExtract(cnt, offs, &value);
            if (r != -1) {
                if (r == 0)
                    r = DSPCfg_WriteViaTableLookup(offs, value, slot, &hi, &lo);
                else
                    DSPCfg_WriteViaTableLookup(offs, value, slot, &hi, &lo);
                AssswbWr(DspBlock_ObjectCode_Table[grp], (unsigned char)(hi + 1), (unsigned char)(value & 0xff), lo);
            }
            if (id == 0x491d) {
                if ((t = DSPCfg_ReadParam_Map0(0x4900)) == 0x35 || t == 0xf)
                    SoundParam_NotifyChange(0x4003, value, 3);
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
    unsigned char hi;
    unsigned char lo;
    int cnt;
    unsigned int grp;
    int offs;
    int kind;
    register int r;
    int t;

    if ((r = DSPCfg_ResolveParamToSlot(id, &slot, (int *)&grp, &offs, &kind, &cnt)) == 0) {
        switch (kind) {
        case 0:
            r = DSPCfg_ValidateSlotForWrite(value, grp);
            if (r != -1)
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
                if ((t = DSPCfg_ReadParam_Map0(0x4900)) == 0x35 || t == 0xf)
                    SoundParam_NotifyChange(0x4003, value, 3);
            }
            break;
        default:
            r = -1;
            break;
        }
    }
    return r;
}
