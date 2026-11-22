/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_T_32r1m236a.c (2026-11-22-17-p6-r84)
   sha256 25134f9d686aebce966cfffd5a3e93730033a7733df5f468d0f30d8cba19b3b5 (tar-sha256); compiled at -O3 -Xr */
extern unsigned char __near SEQ_ERROR_CODE;
extern unsigned char __near SEQ_TRACK;
extern unsigned char __near SEQ_OP_DEST_TRACK;
extern unsigned char __near SEQ_TRACK_ASSIGN[];
extern unsigned char __near ram_ce5;
extern unsigned char __near ram_2873;
extern unsigned char __near ram_287c;
extern unsigned char SeqStep_ParseRhythm_ByteMap[];
extern void SeqPart_SetupWithDispatch(void);
extern void SeqError_MapViaTableA(void);
extern void SeqVoice_InitReturnZero(void);
int SeqPart_CheckBothCompatible(void)
{
    if (SEQ_TRACK_ASSIGN[(unsigned char)(SEQ_TRACK - 1)] == SEQ_TRACK_ASSIGN[(unsigned char)(SEQ_OP_DEST_TRACK - 1)])
        return 0;
    ram_ce5 = SEQ_OP_DEST_TRACK - 1;
    ram_2873 = SEQ_TRACK_ASSIGN[(unsigned char)(SEQ_OP_DEST_TRACK - 1)];
    ram_287c = SeqStep_ParseRhythm_ByteMap[SEQ_TRACK_ASSIGN[(unsigned char)(SEQ_TRACK - 1)]];
    SeqPart_SetupWithDispatch();
    if (SEQ_ERROR_CODE != 0) {
        SeqError_MapViaTableA();
        SeqVoice_InitReturnZero();
        return -1;
    }
    return 0;
}
