/* lane_sub probe round 10, helper C, form b: VoiceParam_CustomTone_Apply_Catalog80 (core/08_voice_noteon_and_tonegen.s,
   KN5000 sub-CPU payload v1.42), a calr caller of CustomTone_CopyToneRecord and CustomTone_CopySubUnitRecord.  In the
   ROM its locals live in a 14-byte frame (record pointer, table pointer, the selector byte, the loop byte) and the
   21-byte sub-record pointer in XIZ; both callees take zero-extended bytes, so they have no prototype here.

   cc900-module: CustomTone_CopyToneRecord CustomTone_CopySubUnitRecord */

extern unsigned char *ram_4531c;
extern unsigned char *ToneDB_RootPtr;
extern unsigned char *ToneDB_RelBase;

struct e16 { unsigned char pad[14]; unsigned char a; unsigned char b; };

extern void CustomTone_CopyToneRecord();
extern void CustomTone_CopySubUnitRecord();

/* cc900-name: CustomTone_Apply_Catalog80=VoiceParam_CustomTone_Apply_Catalog80 */
void CustomTone_Apply_Catalog80(unsigned int idx)
{
    unsigned char *rec;
    struct e16 *tbl;
    unsigned char e;
    unsigned char k;
    unsigned char *s;
    e = ram_4531c[29351];
    rec = ram_4531c + ((int)e * 80 + 19111);
    tbl = (struct e16 *)((unsigned long)ToneDB_RelBase + *(long *)(ToneDB_RootPtr + 128));
    CustomTone_CopyToneRecord(tbl[idx].a, tbl[idx].b, e);
    for (k = 0; k < 2; k++) {
        s = rec + ((int)k * 21 + 16);
        CustomTone_CopySubUnitRecord(k, s[1], s[2], e);
        s[2] &= 15;
        s[2] |= 80;
    }
    ram_4531c[(int)e * 2 + 18855] = tbl[idx].a;
    ((unsigned char *)(unsigned long)(ram_4531c + ((int)e * 2 + 18855)))[1] = (tbl[idx].b & 31) | 96;
}
