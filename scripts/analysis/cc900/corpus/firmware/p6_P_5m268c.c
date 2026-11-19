/* lane_p6 round 5 (2026-11-19): p6_I_3m268b.c (r36: +52, O3Xr) with the count widened before the multiply: the
   ROM sign-extends the char count and then shifts the word (exts bc; sla bc,5); V4.23 shifted the byte first.
   FORM B of p6_I_3m268a.c (the inner loop as goto test + do-while).  Form a's notes follow.
   Phase 6, lane_p6 helper I, round 3, module 268 (demo/file_demo_proc.s), form a.  New.
   FileIO_BuildFileIndex(s): splits the comma-separated list s (at most 128 characters) into 32-byte names in the
   table at 0x27312, counting them in 0x27412 (0x27414 cleared too); every position is first checked with
   FileIO_Search_SkipEntry(&s[i], "***", 3) (two literals, one per call: cc900-data 1 and 2); a 0 ends the scan
   (outer) or the name (inner).  Read from the hand assembly: s in the frame, i in IZ, the name index j in QIZ, the
   character in E; the name slot indexed as count * 32 + j (exts, sla 5: an explicit multiply on a signed char
   count); the outer loop's test folded at entry (-O3), the inner loop entered at its test (a compound condition).
   Form b: the inner loop as `goto test` + do-while. */
/* cc900-module: FileIO_Search_SkipEntry */
/* cc900-data: FileIO_BuildFileIndex 1 = BuildIndex_ScanLoop_Str_Star_Star_Star */
/* cc900-data: FileIO_BuildFileIndex 2 = BuildIndex_CheckSubEntry_Str_Star_Star_Star */

extern signed char ram_27412;
extern signed char ram_27414;
extern char ram_27312[];
extern int FileIO_Search_SkipEntry(char *, char *, int);
extern void FileIO_BuildFileIndex(char *s);

void FileIO_BuildFileIndex(char *s)
{
    int i;
    int j;
    char c;

    ram_27412 = 0;
    ram_27414 = 0;
    for (i = 0; i < 128; i++) {
        if (FileIO_Search_SkipEntry(&s[i], "***", 3) == 0)
            return;
        j = 0;
        goto test;
        do {
            ram_27312[(int)ram_27412 * 32 + j] = c;
            if (FileIO_Search_SkipEntry(&s[i], "***", 3) == 0)
                break;
            j++;
            i++;
test:       ;
        } while ((c = s[i]) != ',' && c != 0 && j < 32);
        ram_27312[(int)ram_27412 * 32 + j] = 0;
        ram_27412++;
    }
}
