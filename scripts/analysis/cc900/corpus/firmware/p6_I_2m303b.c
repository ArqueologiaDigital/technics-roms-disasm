/* FORM B of p6_I_2m303a.c: NoteMap_ConvergeMapA / B indexed as plain arrays.  Form a's notes follow.
   Phase 6, lane_p6 helper I, round 2, module 303 (audio/note_voice_mapping.s), form a.  New.
   SndParam_LookupByChannel(sel, b, c, d) and SndParam_OffsetHandler(sel, b, d): look up a parameter's row r with
   SndParam_LookupAndDispatch (called without a prototype: the ROM widens the byte arguments with extz); r == 0xff
   gives d back.  Otherwise a compiled switch on sel (1..6, tables SndParamChan_SwitchOffsets /
   SndParamOffs_SwitchOffsets, based at the functions' own first case labels): 1..4 read byte d of one of the
   pointers in r's 24-byte record of the __near table at 0xec11 (LookupByChannel: pointer 0..3, each case with its
   own r * 24 + 4k; OffsetHandler: the byte offset 0x10 / 0x14 / 8 / 0xc set per case, r * 24 + off in the shared
   tail), 5 / 6 read NoteMap_ConvergeMapA / B[d] (the ROM loads their address as an immediate: here a converted
   pointer), anything else gives d.  LookupByChannel's d is the 4th argument (on the stack, retd 2).
   Form b: the two maps indexed as plain arrays. */
/* cc900-module: SndParam_LookupAndDispatch */
/* cc900-data: SndParam_LookupByChannel 1 = SndParamChan_SwitchOffsets */
/* cc900-data: SndParam_OffsetHandler 1 = SndParamOffs_SwitchOffsets */

struct chrec { unsigned char *p[6]; };

extern struct chrec __near ram_ec11[];
extern unsigned char NoteMap_ConvergeMapA[];
extern unsigned char NoteMap_ConvergeMapB[];
extern unsigned char SndParam_LookupAndDispatch();
extern unsigned char SndParam_LookupByChannel(unsigned char sel, unsigned char b, unsigned char c, unsigned char d);
extern unsigned char SndParam_OffsetHandler(unsigned char sel, unsigned char b, unsigned char d);

unsigned char SndParam_LookupByChannel(unsigned char sel, unsigned char b, unsigned char c, unsigned char d)
{
    unsigned char r;

    r = SndParam_LookupAndDispatch(b, c);
    if (r == 0xff)
        return d;
    switch (sel) {
    case 1:
        return ram_ec11[r].p[0][d];
    case 2:
        return ram_ec11[r].p[1][d];
    case 3:
        return ram_ec11[r].p[2][d];
    case 4:
        return ram_ec11[r].p[3][d];
    case 5:
        return NoteMap_ConvergeMapA[d];
    case 6:
        return NoteMap_ConvergeMapB[d];
    }
    return d;
}

unsigned char SndParam_OffsetHandler(unsigned char sel, unsigned char b, unsigned char d)
{
    unsigned char r;
    int off;

    r = SndParam_LookupAndDispatch(b, 0);
    if (r == 0xff)
        return d;
    switch (sel) {
    case 1:
        off = 0x10;
        break;
    case 2:
        off = 0x14;
        break;
    case 3:
        off = 8;
        break;
    case 4:
        off = 0xc;
        break;
    case 5:
        return NoteMap_ConvergeMapA[d];
    case 6:
        return NoteMap_ConvergeMapB[d];
    default:
        return d;
    }
    return (*(unsigned char **)((char *)ram_ec11 + (r * 24 + off)))[d];
}
