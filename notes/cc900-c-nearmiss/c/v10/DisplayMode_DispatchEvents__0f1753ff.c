/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_C_23m203b.c (2026-11-18-1-p6-r33)
   sha256 0f1753ffd25b20ef95d2c02e2425fe6162ae9b67b004c3034e8eaf2ce94079d2 (tar-sha256); compiled at -O3 -Xr */
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
