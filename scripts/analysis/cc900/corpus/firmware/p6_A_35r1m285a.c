/* Probe round 35r1, helper A, form a: midi/midi_dispatch_handlers.s (module 285), xr_screen family.
   FileData_AllocLoadAndParse(): read the 32-byte header into a Malloc'd buffer (-200 when none), keep its format in
   ram_b7ea and import by format (1 / 2: raw block then M4/M6 panel memories; 3: NN live panel then NN panel
   memories; else -102); stop at the first negative result; free the buffer.  The result is a `register` local
   (IZ), the buffer stays on the frame.  Cases in source order 1, 2, 3 (V4.23 compares them in reverse). */
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
    register int r;

    if ((buf = Malloc(32)) == 0)
        return -200;
    r = FileIO_ReadBlock(buf, 32);
    if (r >= 0) {
        switch (ram_b7ea = DataBuf_CheckFormatPair(buf)) {
        case 1:
        case 2:
            r = FileData_RawDataBlock();
            if (r >= 0)
                r = FileData_ImportM4M6PanelMemories();
            break;
        case 3:
            r = FileData_ImportNNLivePanel();
            if (r >= 0)
                r = FileData_ImportNNPanelMemories();
            break;
        default:
            r = -102;
            break;
        }
    }
    Free(buf);
    return r;
}
