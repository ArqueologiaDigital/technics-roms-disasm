/* FORM B of p6_I_4m264a.c (MemDraw_LswIdTable read as a plain extern array).  Form a's notes follow.
   Phase 6, lane_p6 helper I, round 4, module 264 (ui/drawbar_panel_ui.s), form a.  New.
   DemoMenu_BuildItemWorkspace(item, val): posts an EVT_LSW_DATA block {id, val} (12 bytes from Malloc, then
   EVT_AUTO_FREE) to -1.  The id is (part << 10) + MemDraw_LswIdTable[item]; val is also kept in the int table at
   0x247ce: items 0..8 through the index, 9..14 by a compiled switch (table DemoMenu_WorkspaceFunc_CaseTable, base
   at the function's own first case) with constant elements, and items 11..14 then take the bare table value as
   the id (the ROM reuses &MemDraw_LswIdTable[item] from the first read).
   Read from the hand assembly: the block in the frame (+2), item in the frame (+6), val in IZ; the item index
   doubled with add (32-bit) and the table base and 0x247ce loaded as immediates (here: converted / constant
   pointers).  Form b: the table read through a plain extern array. */
/* cc900-data: DemoMenu_BuildItemWorkspace 1 = DemoMenu_WorkspaceFunc_CaseTable */

#define EVT_LSW_DATA 0x1c0001cL
#define EVT_AUTO_FREE 0x1e00023L
#define WS ((unsigned int *)0x247ceL)

struct lswdata { unsigned long id; unsigned int val; unsigned int f6; long f8; };

extern unsigned int MemDraw_LswIdTable[];
extern void *__cdecl Malloc(unsigned int);
extern unsigned int GetPartSelect(void);
extern long ApPostEvent(long, long, void *);
extern void DemoMenu_BuildItemWorkspace(unsigned int item, unsigned int val);

void DemoMenu_BuildItemWorkspace(unsigned int item, unsigned int val)
{
    struct lswdata *p;

    p = (struct lswdata *)Malloc(12);
    p->id = ((unsigned long)GetPartSelect() << 10) + MemDraw_LswIdTable[item];
    p->val = val;
    if (item <= 8)
        WS[item] = val;
    else
        switch (item) {
        case 9:
            WS[9] = val;
            break;
        case 10:
            WS[10] = val;
            break;
        case 11:
            WS[11] = val;
            p->id = MemDraw_LswIdTable[item];
            break;
        case 12:
            WS[12] = val;
            p->id = MemDraw_LswIdTable[item];
            break;
        case 13:
            WS[13] = val;
            p->id = MemDraw_LswIdTable[item];
            break;
        case 14:
            WS[14] = val;
            p->id = MemDraw_LswIdTable[item];
            break;
        }
    ApPostEvent(-1, EVT_LSW_DATA, p);
    ApPostEvent(-1, EVT_AUTO_FREE, p);
}
