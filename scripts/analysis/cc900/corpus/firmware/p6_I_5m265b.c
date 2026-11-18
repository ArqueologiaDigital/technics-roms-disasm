/* FORM B of p6_I_5m265a.c: the same C, the literals 3 / 4 numbered "<ACTION>" then "</ACTION>".  Form a's notes
   follow.
   Phase 6, lane_p6 helper I, round 5, module 265 (demo/fdemotext_routines.s, -O3 -Xr), form a.  New.
   Seq_LoadNamedResource(name): builds "<name, at most 8 characters>.ACT" in a 32-byte frame buffer filled with
   spaces, opens it ("rt"), seeks to its start, reads the whole file into a buffer (FileIO_SeekWriteBlock_Impl,
   FDemo_AllocBuffer, kept in ram_249d0), extracts the block between "<ACTION>" and "</ACTION>"
   (FDemoText_ReadTaggedBlock), closes it and, when the close succeeds, post-processes and runs the markup.
   Read from the hand assembly: name then the file data in XIZ; the buffer address reused for the terminator and
   Strcat (CSE); the deferred argument pops (22 bytes); the allocated buffer passed straight from the store.
   The four literals are f_const objects; their listing order is a guess: here source order with the call's
   arguments evaluated right to left (".ACT", "rt", "</ACTION>", "<ACTION>"); form b numbers the two tags the
   other way round. */
/* cc900-module: FDemoText_ProcessMarkupLoop FDemoText_ReadTaggedBlock FDemo_AllocBuffer Seq_PostProcessDisplay */
/* cc900-data: Seq_LoadNamedResource 1 = Seq_FillBufferLoop_Str_ACT */
/* cc900-data: Seq_LoadNamedResource 2 = Seq_FillBufferLoop_Str_rt */
/* cc900-data: Seq_LoadNamedResource 3 = Seq_FillBufferLoop_Str_ACTION_2 */
/* cc900-data: Seq_LoadNamedResource 4 = Seq_FillBufferLoop_Str_ACTION */

extern char *ram_249d0;
extern int __cdecl Strlen(char *);
extern char *__cdecl Strncpy(char *, char *, unsigned int);
extern char *__cdecl Strcat(char *, char *);
extern int FileIO_OpenWithMode(char *, char *);
extern void FileIO_SeekAndReadBlock(long, int);
extern long FileIO_SeekWriteBlock_Impl(void);
extern void FileIO_SeekRead_ExtReturn(void);
extern char *FDemo_AllocBuffer(long);
extern void FDemoText_ReadTaggedBlock(char *buf, long size, char *open, char *close);
extern int FileIO_CloseHandle(void);
extern void Seq_PostProcessDisplay(void);
extern void FDemoText_ProcessMarkupLoop(int);
extern void Seq_LoadNamedResource(char *name);

void Seq_LoadNamedResource(char *name)
{
    char buf[32];
    char *p;
    long n;

    for (p = buf; p < buf + 32; )
        *p++ = ' ';
    Strncpy(buf, name, Strlen(name));
    buf[8] = 0;
    Strcat(buf, ".ACT");
    if (FileIO_OpenWithMode(buf, "rt") < 0)
        return;
    FileIO_SeekAndReadBlock(0L, 2);
    n = FileIO_SeekWriteBlock_Impl();
    FileIO_SeekRead_ExtReturn();
    FDemoText_ReadTaggedBlock(ram_249d0 = FDemo_AllocBuffer(n), n, "<ACTION>", "</ACTION>");
    if (FileIO_CloseHandle() != 0)
        return;
    Seq_PostProcessDisplay();
    FDemoText_ProcessMarkupLoop(1);
}
