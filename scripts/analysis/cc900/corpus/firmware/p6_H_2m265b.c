/* lane_p6 helper H, round 2, module 265 (demo/fdemotext_routines.s), form b: as form a, but if/else chains testing
   0x82 first and the second half's type byte in a local. */

struct dmsg { unsigned char st, part, type, b3, b4, b5, b6, b7; };
extern struct dmsg ram_20c33;
extern unsigned char __near PART_SELECT;
extern unsigned char __near ACTIVE_TITLE;
extern void DemoMenu_BuildItemWorkspace(int, int);

void FDemoText_ParseControlMessage(void)
{
    unsigned char s, t;
    int ch;

    if (ram_20c33.part != PART_SELECT)
        return;
    if (ACTIVE_TITLE != 234)
        return;
    s = ram_20c33.st;
    if (s != 0x83) {
        if (s != 0x82)
            return;
        t = ram_20c33.type;
        ch = ram_20c33.b7 & 0xf;
        if (t == 0x82) {
            DemoMenu_BuildItemWorkspace(8, ch);
            DemoMenu_BuildItemWorkspace(5, (ram_20c33.b6 >> 4) & 0xf);
            DemoMenu_BuildItemWorkspace(3, ram_20c33.b6 & 0xf);
        } else if (t == 2) {
            DemoMenu_BuildItemWorkspace(6, ch);
            DemoMenu_BuildItemWorkspace(2, (ram_20c33.b6 >> 4) & 0xf);
            DemoMenu_BuildItemWorkspace(0, ram_20c33.b6 & 0xf);
        }
    }
    t = ram_20c33.type;
    if (t == 0x82) {
        DemoMenu_BuildItemWorkspace(10, ram_20c33.b6 & 1);
        DemoMenu_BuildItemWorkspace(9, (ram_20c33.b6 >> 1) & 1);
    } else if (t == 2) {
        DemoMenu_BuildItemWorkspace(7, ram_20c33.b7 & 0xf);
        DemoMenu_BuildItemWorkspace(4, (ram_20c33.b6 >> 4) & 0xf);
        DemoMenu_BuildItemWorkspace(1, ram_20c33.b6 & 0xf);
    }
}
