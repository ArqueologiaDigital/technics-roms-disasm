/* Functions of ui/ui_widget_defs.s.  Firmware C (cc900 phase 6), built with Toshiba V4.23; checked function by function
   against the ROM (notes/cc900-phase6-2026-11-16/staged_v423.tsv).
   Names are the tree's; ram_<hex> is a RAM cell the tree has not named yet.
   __near / __tiny: the cells the ROM reaches with 16 / 8-bit operands (V4.23 then declares them medium / small;
   a plain extern is large, 24-bit).  Each __near / __tiny declaration names one object: V4.23 applies the
   qualifier to the first declarator only.
   cc900-options: -O3 -Xr
*/

struct mode_ent { long func; long a; int b; char *name; };
extern char Mode_UnregisteredName[];
extern struct mode_ent ram_328fc[];

void RegisterMode(long id, long func, long a, int b, char *name)
{
	ram_328fc[id].func = func;
	ram_328fc[id].a = a;
	ram_328fc[id].b = b;
	ram_328fc[id].name = name;
}

void UnregisteredMode(long id)
{
	ram_328fc[id].func = 0x1200000;
	ram_328fc[id].a = -1;
	ram_328fc[id].b = -1;
	ram_328fc[id].name = Mode_UnregisteredName;
}

struct aptimer { unsigned int a; unsigned int b; unsigned int pad[2]; long c; unsigned char rest[12]; };
extern struct aptimer ram_2f844[];
extern long ram_30444;
extern unsigned int ram_30448;

void InitializeTimer(void)
{
	int i;

	ram_30444 = 0;
	ram_30448 = 0xffff;
	for (i = 0; i < 128; i++) {
		ram_2f844[i].a = 0xffff;
		ram_2f844[i].b = 0xffff;
		ram_2f844[i].c = -1;
	}
}
