/* Phase 6, lane_p6 helper C, round 23, module 203 (modules_v10.tsv) of v10 ui/ui_playback_modes.s, form b of
   DisplayMode_DispatchEvents (form a, p6_C_23m203a.c, describes it): the cases in ascending title order, with an
   explicit empty case for 0x72. */
/* cc900-data: DisplayMode_DispatchEvents 1 = DisplayMode_DispatchEvents_CaseTable */

extern unsigned char __near CURRENT_TITLE;

extern long ApPostEvent(long, long, long);

void DisplayMode_DispatchEvents(void)
{
    switch (CURRENT_TITLE) {
    case 0x6f:
        ApPostEvent(0x6f000aL, 0x1e0003bL, 0L);
        break;
    case 0x70:
        ApPostEvent(0x700007L, 0x1e0003bL, 0L);
        ApPostEvent(0x700008L, 0x1e0003bL, 0L);
        ApPostEvent(0x700009L, 0x1e0003bL, 0L);
        break;
    case 0x71:
        ApPostEvent(0x710007L, 0x1e0003bL, 0L);
        ApPostEvent(0x710008L, 0x1e0003bL, 0L);
        break;
    case 0x72:
        break;
    case 0x73:
        ApPostEvent(0x73000cL, 0x1e0003bL, 0L);
        break;
    case 0x74:
        ApPostEvent(0x74000aL, 0x1e0003bL, 0L);
        ApPostEvent(0x74000bL, 0x1e0003bL, 0L);
        ApPostEvent(0x74000cL, 0x1e0003bL, 0L);
        break;
    case 0x75:
        ApPostEvent(0x750009L, 0x1e0003bL, 0L);
        ApPostEvent(0x75000aL, 0x1e0003bL, 0L);
        break;
    }
}
