/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_H_2m265a.c (2026-11-16-53-p6-r11)
   sha256 8ccb606a15dd3ec0a11b00c993c1d121ee364ca21e4e3189f99bf524fdea9166 (tar-sha256); compiled at -O3 -XS -Xr */
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
        switch (t) {
        case 2:
            DemoMenu_BuildItemWorkspace(6, ch);
            DemoMenu_BuildItemWorkspace(2, (ram_20c33.b6 >> 4) & 0xf);
            DemoMenu_BuildItemWorkspace(0, ram_20c33.b6 & 0xf);
            break;
        case 0x82:
            DemoMenu_BuildItemWorkspace(8, ch);
            DemoMenu_BuildItemWorkspace(5, (ram_20c33.b6 >> 4) & 0xf);
            DemoMenu_BuildItemWorkspace(3, ram_20c33.b6 & 0xf);
            break;
        }
    }
    switch (ram_20c33.type) {
    case 2:
        DemoMenu_BuildItemWorkspace(7, ram_20c33.b7 & 0xf);
        DemoMenu_BuildItemWorkspace(4, (ram_20c33.b6 >> 4) & 0xf);
        DemoMenu_BuildItemWorkspace(1, ram_20c33.b6 & 0xf);
        break;
    case 0x82:
        DemoMenu_BuildItemWorkspace(10, ram_20c33.b6 & 1);
        DemoMenu_BuildItemWorkspace(9, (ram_20c33.b6 >> 1) & 1);
        break;
    }
}
