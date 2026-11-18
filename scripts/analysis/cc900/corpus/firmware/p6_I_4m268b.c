/* FORM B of p6_I_4m268a.c (the loop as an explicit entry test + do-while).  Form a's notes follow.
   Phase 6, lane_p6 helper I, round 4, module 268 (demo/file_demo_proc.s, -O3 -Xr), form a.  New.
   ParseSMFTrackName(): scans the open SMF track's events (delta times from ReadVariableLengthInt, which also ends
   the scan) for a meta event 3 (track name) and reads its text into the buffer at 0x25b90 (ReadFieldToBuffer);
   every other event's data is skipped by length (sysex / meta lengths, 1-3 bytes for channel messages, running
   status from the last status byte).  Returns the buffer, or NULL when the file reports an error.
   Read from the hand assembly: the length in IZ, the running status / meta type in QIZ, the byte in HL; the delta
   test copied to the loop entry (-O3); the running-status data byte cases jump straight to the skip call (the
   length is known to be positive). */
/* cc900-module: ReadFieldToBuffer ReadVariableLengthInt */

extern char ram_25b90[];
extern int ReadVariableLengthInt(void);
extern int FileIO_ReadByte(void);
extern void ReadFieldToBuffer(int len, char *buf);
extern void FileIO_SeekAndReadBlock(long, int);
extern int FileIO_ReturnError(void);
extern char *ParseSMFTrackName(void);

char *ParseSMFTrackName(void)
{
    int len;
    int status;
    int c;

    len = 0;
    ram_25b90[0] = 0;
    status = 0;
    if (ReadVariableLengthInt() != 0)
        return ram_25b90;
    do {
        c = FileIO_ReadByte();
        if (c == 0xff) {
            status = FileIO_ReadByte();
            len = ReadVariableLengthInt();
            if (status == 3) {
                ReadFieldToBuffer(len, ram_25b90);
                len = 0;
            }
            status = 0;
        } else if (c == 0xf0 || c == 0xf7) {
            len = ReadVariableLengthInt();
            status = 0;
        } else if (c >= 0xc0 && c <= 0xdf) {
            len = 2;
            status = c;
        } else if (c >= 0x80 && c <= 0xef) {
            len = 3;
            status = c;
        } else if (c <= 0x7f) {
            if (status >= 0xc0 && status <= 0xdf)
                len = 1;
            else
                len = 2;
        }
        if (len > 0)
            FileIO_SeekAndReadBlock(len, 1);
        if (FileIO_ReturnError() < 0)
            return 0;
    } while (ReadVariableLengthInt() == 0);
    return ram_25b90;
}
