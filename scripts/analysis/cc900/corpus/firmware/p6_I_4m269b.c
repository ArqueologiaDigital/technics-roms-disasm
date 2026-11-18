/* FORM B of p6_I_4m269a.c (both loops as if + do-while).  Form a's notes follow.
   Phase 6, lane_p6 helper I, round 4, module 269 (file_io/medley.s), form a.  New.
   SmfMed_FormatSlotList(obj, total): the medley list page of 10 rows around the selected file (FmmSmfFileNameFunc
   with EVT_GET_SELECTED_FILE_NUMBER, rounded down to a multiple of 10): each visible row's 8-byte text at 0x83e0 is
   formatted from the file number at 0x88a0[base + row] (FormatMedleyNumber, called without a prototype: the ROM
   widens the byte with extz), the rest with 0xff (blank), and each row is posted as EVT_PARA_DRAW to obj.
   Read from the hand assembly: obj in the frame, total then the row in IZ, base in QIZ (divided then multiplied in
   place: two statements), the visible count in the frame (`n = total - base` as store + sub in memory); both loops
   test at entry (form a: for loops; form b: if + do-while). */
/* cc900-module: FmmSmfFileNameFunc FormatMedleyNumber */

#define EVT_GET_SELECTED_FILE_NUMBER 0x1e50003L
#define EVT_PARA_DRAW 0x1c0000fL

struct mtxt { unsigned char s[8]; };

extern struct mtxt __near ram_83e0[];
extern unsigned char __near ram_88a0[];
extern long FmmSmfFileNameFunc(long, long, long);
extern void FormatMedleyNumber();
extern long ApPostEvent(long, long, void *);
extern void SmfMed_FormatSlotList(long obj, unsigned int total);

void SmfMed_FormatSlotList(long obj, unsigned int total)
{
    unsigned int n;
    unsigned int base;
    unsigned int i;

    base = FmmSmfFileNameFunc(0, EVT_GET_SELECTED_FILE_NUMBER, 0);
    base /= 10;
    base *= 10;
    n = 10;
    if (base + 10 >= total)
        n = total - base;
    i = 0;
    if (i < n)
        do {
            FormatMedleyNumber(ram_83e0[i].s, ram_88a0[base + i], i);
            ApPostEvent(obj, EVT_PARA_DRAW, ram_83e0[i].s);
        } while (++i < n);
    if (i < 10)
        do {
            FormatMedleyNumber(ram_83e0[i].s, 0xff, i);
            ApPostEvent(obj, EVT_PARA_DRAW, ram_83e0[i].s);
        } while (++i < 10);
}
