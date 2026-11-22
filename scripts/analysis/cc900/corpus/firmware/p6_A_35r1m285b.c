/* Probe round 35r1, helper A, form b: midi/midi_dispatch_handlers.s (module 285), xr_screen family.
   FileData_AllocLoadAndParse as form a, with the buffer assigned before the test, the result a plain local and the
   format dispatch written as an if / else-if chain (3, 2 || 1) instead of a switch. */
/* cc900-module: DataBuf_CheckFormatPair FileData_ImportM4M6PanelMemories FileData_ImportNNLivePanel FileData_ImportNNPanelMemories FileData_RawDataBlock */

extern void *__cdecl Malloc(unsigned int);
extern void __cdecl Free(void *);
extern int FileIO_ReadBlock(void *, long);
extern int DataBuf_CheckFormatPair(void *);
extern int FileData_RawDataBlock(void);
extern int FileData_ImportM4M6PanelMemories(void);
extern int FileData_ImportNNLivePanel(void);
extern int FileData_ImportNNPanelMemories(void);
extern int __near ram_b7ea;
extern int FileData_AllocLoadAndParse(void);

int FileData_AllocLoadAndParse(void)
{
    void *buf;
    int r;
    int t;

    buf = Malloc(32);
    if (buf == 0)
        return -200;
    r = FileIO_ReadBlock(buf, 32);
    if (r >= 0) {
        t = ram_b7ea = DataBuf_CheckFormatPair(buf);
        if (t == 3) {
            r = FileData_ImportNNLivePanel();
            if (r >= 0)
                r = FileData_ImportNNPanelMemories();
        } else if (t == 2 || t == 1) {
            r = FileData_RawDataBlock();
            if (r >= 0)
                r = FileData_ImportM4M6PanelMemories();
        } else
            r = -102;
    }
    Free(buf);
    return r;
}
