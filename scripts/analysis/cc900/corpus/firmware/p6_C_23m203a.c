/* Phase 6, lane_p6 helper C, round 23, module 203 (modules_v10.tsv) of v10 ui/ui_playback_modes.s, form a:
   DisplayMode_DispatchEvents (new, poolnew_C, 225 B).  For the display titles 0x6f..0x75 (CURRENT_TITLE) posts the
   title's redraw events (object 0x00tt00nn, event 0x01e0003b) through ApPostEvent; 0x72 and every other title do
   nothing.  The switch reads the tree's DisplayMode_DispatchEvents_CaseTable; the case bodies are in the ROM's
   order (0x6f, 0x73, 0x70, 0x74, 0x71, 0x75), each ending in the shared last ApPostEvent call.
   Form b (p6_C_23m203b.c): the cases in ascending order (V4.23 may place the bodies by value). */
/* cc900-data: DisplayMode_DispatchEvents 1 = DisplayMode_DispatchEvents_CaseTable */

extern unsigned char __near CURRENT_TITLE;

extern long ApPostEvent(long, long, long);

void DisplayMode_DispatchEvents(void)
{
    switch (CURRENT_TITLE) {
    case 0x6f:
        ApPostEvent(0x6f000aL, 0x1e0003bL, 0L);
        break;
    case 0x73:
        ApPostEvent(0x73000cL, 0x1e0003bL, 0L);
        break;
    case 0x70:
        ApPostEvent(0x700007L, 0x1e0003bL, 0L);
        ApPostEvent(0x700008L, 0x1e0003bL, 0L);
        ApPostEvent(0x700009L, 0x1e0003bL, 0L);
        break;
    case 0x74:
        ApPostEvent(0x74000aL, 0x1e0003bL, 0L);
        ApPostEvent(0x74000bL, 0x1e0003bL, 0L);
        ApPostEvent(0x74000cL, 0x1e0003bL, 0L);
        break;
    case 0x71:
        ApPostEvent(0x710007L, 0x1e0003bL, 0L);
        ApPostEvent(0x710008L, 0x1e0003bL, 0L);
        break;
    case 0x75:
        ApPostEvent(0x750009L, 0x1e0003bL, 0L);
        ApPostEvent(0x75000aL, 0x1e0003bL, 0L);
        break;
    }
}
