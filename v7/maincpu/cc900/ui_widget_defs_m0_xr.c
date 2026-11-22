/* Functions of ui/ui_widget_defs.s.  Firmware C (cc900 phase 6), built with Toshiba V4.23; checked function by function
   against the ROM (notes/cc900-phase6-2026-11-16/staged_v423.tsv).
   Names are the tree's; ram_<hex> is a RAM cell the tree has not named yet.
   __near / __tiny: the cells the ROM reaches with 16 / 8-bit operands (V4.23 then declares them medium / small;
   a plain extern is large, 24-bit).  Each __near / __tiny declaration names one object: V4.23 applies the
   qualifier to the first declarator only.
   cc900-options: -Xr
*/
/* cc900-module: GetNextView GetPrevView GetSubView GetSuperView GetViewInstance SetChange */   /* staged module names, repair_module_lines.py */

extern unsigned int ram_30464;
extern void VGA_ScreenUnblank(void);
extern void VGA_ScreenBlank(void);

void LcdOff_Done(void)
{
    if (ram_30464 != 0)
        VGA_ScreenUnblank();
}

void LcdOff_Return(void)
{
    if (ram_30464 != 0)
        VGA_ScreenBlank();
}

struct box { int x, y, w, h; };
struct viewable { char hdr[4]; int super, sub, next, prev; unsigned int flags; struct box box; };
extern struct viewable *GetViewInstance(unsigned long id);
extern int GetChange(unsigned long id);
extern int GetMovable(unsigned long id);
extern void SetMovable(unsigned long id, int f);

int GetChange(unsigned long id)
{
    return (GetViewInstance(id)->flags & 0x4) != 0;
}
int GetMovable(unsigned long id)
{
    return (GetViewInstance(id)->flags & 0x2) == 0;
}
void SetMovable(unsigned long id, int f)
{
    struct viewable *v;
    unsigned int *p;
    v = GetViewInstance(id);
    p = &v->flags;
    if (f != 0)
        *p &= 0xfffd;
    else
        *p |= 0x2;
}

/* cc900-module: DrawQueue_Alloc DrawRing_Post IS_XSP_INSIDE_4K_REGION_AT_1C032 InitGraphics_SetupVRAM InitGraphics_SetupVRAM_Loop IsDrawTask LcdOff_Done2 LcdOn_Return */
struct wcmd { void (*fn)(struct wcmd *); };
extern void InitGraphics_SetupVRAM_Loop(void);
void InitGraphics_SetupVRAM(struct wcmd *q);
extern void InitGraphics_SetupVRAM(struct wcmd *q);
extern void LcdOn_Return(void);
void LcdOff_Done2(struct wcmd *q);
extern void LcdOff_Done2(struct wcmd *q);

void InitGraphics_SetupVRAM(struct wcmd *q)
{
	InitGraphics_SetupVRAM_Loop();
}
void LcdOff_Done2(struct wcmd *q)
{
	LcdOn_Return();
}
