/* Functions of hdae5000_ui_display.s.  (hdae5000_fd_file_select.c)
   Firmware C (cc900 phase 6), built by Toshiba V4.23; promoted from cc900-staged/hdae5000_fd_file_select.c (checked in
   notes/cc900-c-hdae5000-2026-11-16/staged_v423.tsv).
   cc900-options: -Xr
   cc900-module: HDAE5000_FdLyricList_Scan
   cc900-data: HDAE5000_FDFileSelectProc 1 = HDAE5000_FDFileSelectProc_KeyCaseMap
   cc900-data: HDAE5000_FDFileSelectProc 2 = HDAE5000_FDFileSelectProc_KeyCaseTable
*/
#include "hdae_ws.h"
#include "hdae_ids.h"

extern void *__cdecl HDAE5000_MemFill(void *, int, unsigned int);
extern unsigned int __cdecl HDAE5000_StrLen(char *);
extern char *__cdecl HDAE5000_StrCpy(char *, char *);
extern char *__cdecl HDAE5000_StrCat(char *, char *);
extern int __cdecl HDAE5000_SPrintf(char *, char *, ...);

extern long HDAE5000_FdLyricList_Scan(void);

struct Box { unsigned int x0; unsigned int y0; unsigned int x1; unsigned int y1; };
struct Pt { unsigned int x; unsigned int y; };

extern unsigned char HDAE5000_RAM_FdLyricNames[][9];
extern char HDAE5000_RAM_FdLyricTitles[][27];
extern unsigned char HDAE5000_RAM_FdLyricHasMid[];
extern unsigned int HDAE5000_RAM_FdLyricCount;
extern char HDAE5000_RAM_FdVolumeLabel[];
extern unsigned char HDAE5000_RAM_LyricBuffer[];
extern unsigned int ram_230e74;     /* the cursor's row on the page, 0..11 */
extern unsigned int ram_230e76;     /* the selected entry */
extern unsigned int ram_230e78;     /* the entry in the page's first row */
extern struct Pt ram_22a0bc;        /* where the status line's text goes */
extern struct Box ram_22a0c0;       /* the cursor frame */
extern struct Box ram_22a0c8;       /* the status line */

extern char HDAE5000_Str_Empty_FDFileSelectProc[];
extern char HDAE5000_Str_Blank27[];
extern char HDAE5000_Str_Blank27_FDFileSelectProc[];
extern char HDAE5000_Str_Mid[];
extern char HDAE5000_Str_Blank3[];
extern char HDAE5000_Str_Blank49[];
extern char HDAE5000_Fmt_s_s[];
extern char HDAE5000_Fmt_s_s_FDFileSelectProc[];
extern char HDAE5000_Str_TLX_FDFileSelectProc[];
extern char HDAE5000_Str_Rb_FDFileSelectProc[];

long HDAE5000_FDFileSelectProc(long obj, long ev, long arg)
{
    struct Pt pt;
    struct Box box;
    char buf[100];
    unsigned int i;
    unsigned char *v;

    switch (ev) {
    case EVT_DRAW:
        CALLV(ROOT->InheritedProc)(obj, ev, arg);
        v = CALLR(unsigned char *, ROOT->GetViewInstance)(obj);
        CALLV(ROOT->SendEvent)(obj, EVT_HDAE_DRAW_FD_TEXT, 0L);
        CALLV(ROOT->SendEvent)(obj, EVT_PARA_DRAW, 0L);
        return 0;
    case EVT_SHOW:
        CALLV(ROOT->InheritedProc)(obj, ev, arg);
        v = CALLR(unsigned char *, ROOT->GetViewInstance)(obj);
        CALLV(ROOT->SetDialUp)(obj, EVT_INDEXSW_DOWN, 0L);
        CALLV(ROOT->SetDialDown)(obj, EVT_INDEXSW_UP, 0L);
        CALLV(ROOT->SetDialEnable)(1);
        HDAE5000_StrCpy(HDAE5000_RAM_FdVolumeLabel, HDAE5000_Str_Empty_FDFileSelectProc);
        CALLV(ROOT->SendEvent)(obj, EVT_HDAE_FD_FRESH_UP, 0L);
        ram_22a0c8.x0 = 0x21;
        ram_22a0c8.x1 = 0x118;
        ram_22a0c8.y0 = 0xc5;
        ram_22a0c8.y1 = 0xd1;
        ram_22a0bc.x = ram_22a0c8.x0 + 2;
        ram_22a0bc.y = ram_22a0c8.y0 + 3;
        return 0;
    case EVT_HIDE:
        CALLV(ROOT->InheritedProc)(obj, ev, arg);
        return 0;
    case EVT_HDAE_DRAW_FD_TEXT:
        box.x1 = (box.x0 = 0x16) + 0x37;
        pt.x = box.x0 + 2;
        for (i = 0; i < 12; i++) {
            box.y1 = (box.y0 = i * 12 + 0x28) + 12;
            pt.y = box.y0 + 3;
            CALLV(ROOT->DrawString)((long)&box, (long)&pt, (long)HDAE5000_Str_Blank27, 3L, 0xff, 0xf5);
            CALLV(ROOT->DrawString)((long)&box, (long)&pt, HDAE5000_RAM_FdLyricNames[ram_230e78 + i],
                                    3L, 0xff, 0xf5);
        }
        box.x1 = (box.x0 = 0x5c) + 0xa2;
        pt.x = box.x0 + 2;
        for (i = 0; i < 12; i++) {
            box.y1 = (box.y0 = i * 12 + 0x28) + 12;
            pt.y = box.y0 + 3;
            CALLV(ROOT->DrawString)((long)&box, (long)&pt, (long)HDAE5000_Str_Blank27_FDFileSelectProc,
                                    3L, 0xff, 0xf5);
            CALLV(ROOT->DrawString)((long)&box, (long)&pt, HDAE5000_RAM_FdLyricTitles[ram_230e78 + i],
                                    3L, 0xff, 0xf5);
        }
        box.x1 = (box.x0 = 0x10c) + 0x1f;
        pt.x = box.x0 + 2;
        for (i = 0; i < 12; i++) {
            box.y1 = (box.y0 = i * 12 + 0x28) + 12;
            pt.y = box.y0 + 3;
            if (HDAE5000_RAM_FdLyricHasMid[(unsigned long)(ram_230e78 + i)] != 0)
                CALLV(ROOT->DrawString)((long)&box, (long)&pt, (long)HDAE5000_Str_Mid, 3L, 0xff, 0xf5);
            else
                CALLV(ROOT->DrawString)((long)&box, (long)&pt, (long)HDAE5000_Str_Blank3, 3L, 0xff, 0xf5);
        }
        return 0;
    case EVT_PARA_DRAW:
        box.y1 = (box.y0 = ram_230e74 * 12 + 0x28) + 12;
        box.x0 = 0x14;
        ram_22a0c0.x0 = 0x14;
        ram_22a0c0.x1 = box.x1 = box.x0 + 0x39;
        CALLV(ROOT->DrawFrame)(&ram_22a0c0, 0xf5);
        CALLV(ROOT->DrawFrame)(&box, 0xf2);
        box.x0 = 0x5c;
        ram_22a0c0.x0 = 0x5c;
        ram_22a0c0.x1 = box.x1 = box.x0 + 0xa2;
        CALLV(ROOT->DrawFrame)(&ram_22a0c0, 0xf5);
        CALLV(ROOT->DrawFrame)(&box, 0xf2);
        box.x0 = 0x10c;
        ram_22a0c0.x0 = 0x10c;
        ram_22a0c0.x1 = box.x1 = box.x0 + 0x1f;
        CALLV(ROOT->DrawFrame)(&ram_22a0c0, 0xf5);
        CALLV(ROOT->DrawFrame)(&box, 0xf2);
        ram_22a0c0.y0 = box.y0;
        ram_22a0c0.y1 = box.y1;
        CALLV(ROOT->DrawString)((long)&ram_22a0c8, (long)&ram_22a0bc, (long)HDAE5000_Str_Blank49, 3L, 0xff, 0xf5);
        if (HDAE5000_StrLen(HDAE5000_RAM_FdLyricTitles[ram_230e76]) != 0)
            HDAE5000_SPrintf(buf, HDAE5000_Fmt_s_s, HDAE5000_RAM_FdVolumeLabel,
                             HDAE5000_RAM_FdLyricTitles[ram_230e76]);
        else
            HDAE5000_SPrintf(buf, HDAE5000_Fmt_s_s_FDFileSelectProc, HDAE5000_RAM_FdVolumeLabel,
                             HDAE5000_RAM_FdLyricNames[ram_230e76]);
        CALLV(ROOT->DrawString)((long)&ram_22a0c8, (long)&ram_22a0bc, (long)buf, 3L, 0xff, 0xf5);
        return 0;
    case EVT_HDAE_FD_FRESH_UP:
        ram_230e76 = 0;
        ram_230e78 = 0;
        HDAE5000_RAM_FdLyricCount = 0;
        ram_230e74 = 0;
        HDAE5000_MemFill(HDAE5000_RAM_FdLyricNames, 0, 0x171);
        HDAE5000_MemFill(HDAE5000_RAM_FdLyricTitles, 0, 0x453);
        HDAE5000_MemFill(HDAE5000_RAM_FdLyricHasMid, 0, 0x28);
        HDAE5000_FdLyricList_Scan();
        return 0;
    case EVT_HDAE_FD_INFO:
        return 0;
    case EVT_HDAE_FD_LOAD_LYRIC:
        return 0;
    case EVT_HDAE_FD_SAVE_LYRIC:
        return 0;
    case EVT_INDEXSW_UP:
        CALLV(ROOT->InheritedProc)(obj, ev, arg);
        CALLV(ROOT->SendEvent)(obj, EVT_SW_IN, 3L);
    default:
    inherit:
        return CALLR(long, ROOT->InheritedProc)(obj, ev, arg);
    case EVT_INDEXSW_DOWN:
        CALLV(ROOT->InheritedProc)(obj, ev, arg);
        CALLV(ROOT->SendEvent)(obj, EVT_SW_IN, 0x83L);
        goto inherit;
    case EVT_SW_IN:
        switch ((unsigned long)arg) {
        case 2:
        case 3:
        case 4:
        case 5:
            if (ram_230e76 == 0)
                return -1;
            ram_230e76--;
            if (ram_230e74 == 0) {
                if (ram_230e78 == 0)
                    return -1;
                ram_230e78--;
                CALLV(ROOT->SendEvent)(obj, EVT_DRAW, 0L);
            } else {
                ram_230e74--;
                CALLV(ROOT->SendEvent)(obj, EVT_PARA_DRAW, 0L);
            }
            CALLV(ROOT->SetAutoInc)(obj, ev, arg);
            break;
        case 0x82:
        case 0x83:
        case 0x84:
        case 0x85:
            if (ram_230e76 >= HDAE5000_RAM_FdLyricCount - 1)
                return -1;
            ram_230e76++;
            if (ram_230e74 >= 11) {
                ram_230e78++;
                CALLV(ROOT->SendEvent)(obj, EVT_DRAW, 0L);
            } else {
                ram_230e74++;
                CALLV(ROOT->SendEvent)(obj, EVT_PARA_DRAW, 0L);
            }
            CALLV(ROOT->SetAutoInc)(obj, ev, arg);
            break;
        case 6:
        case 7:
        case 0x86:
        case 0x87:
            switch (CALLR(unsigned char, HAMA->GetMediaType)()) {
            case 2:
            case 3:
                CALLV(ROOT->SleepMainTask)();
                HDAE5000_StrCpy(buf, (char *)HDAE5000_RAM_FdLyricNames[ram_230e76]);
                HDAE5000_StrCat(buf, HDAE5000_Str_TLX_FDFileSelectProc);
                CALLV(HAMA->fopen_ext)(buf, HDAE5000_Str_Rb_FDFileSelectProc);
                CALLV(HAMA->fread_ext)(HDAE5000_RAM_LyricBuffer, 0x5000L);
                CALLV(HAMA->fclose_ext)();
                CALLV(ROOT->WakeUpMainTask)();
            }
            CALLV(ROOT->ApPostEvent)(OBJ_Tech_lyrics, EVT_SHOW, 0L);
        case 0:
        case 1:
        case 0x80:
        case 0x81:
            break;
        }
        return 0;
    }
}
