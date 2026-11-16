/* Functions of audio/sndparam_routines.s.  Firmware C (cc900 phase 6), STAGED: Toshiba V4.23 reproduces these functions' ROM bytes
   (notes/cc900-phase6-2026-11-16/staged_v423.tsv); they move into cc900/ once `make` compiles with V4.23.
   Names are the tree's; ram_<hex> is a RAM cell the tree has not named yet.
   __near / __tiny: the cells the ROM reaches with 16 / 8-bit operands (V4.23 then declares them medium / small;
   a plain extern is large, 24-bit).  Each __near / __tiny declaration names one object: V4.23 applies the
   qualifier to the first declarator only.
   cc900-options: -Xr
*/

struct SpRec12 { unsigned int w[6]; };
extern struct SpRec12 SndParam_ClearRecordTemplate;
extern struct SpRec12 __near ram_9638[];
extern unsigned int *SndParam_ResetDefaultTable(void);

unsigned int *SndParam_ResetDefaultTable(void)
{
    unsigned int *q;

    ram_9638[0] = SndParam_ClearRecordTemplate;
    q = &ram_9638[0].w[0];
    *q = 0xffff;
    return q;
}
