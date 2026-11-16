/* Functions of sequencer/smf_event_processor.s.  Firmware C (cc900 phase 6), STAGED: Toshiba V4.23 reproduces these functions' ROM bytes
   (notes/cc900-phase6-2026-11-16/staged_v423.tsv); they move into cc900/ once `make` compiles with V4.23.
   Names are the tree's; ram_<hex> is a RAM cell the tree has not named yet.
   __near / __tiny: the cells the ROM reaches with 16 / 8-bit operands (V4.23 then declares them medium / small;
   a plain extern is large, 24-bit).  Each __near / __tiny declaration names one object: V4.23 applies the
   qualifier to the first declarator only.
   cc900-options: -Xr
*/

struct buf;
struct file;
typedef int __cdecl SECFN(long, struct buf *);
typedef int __cdecl FILEFN(struct file *);
struct ops { char pad[20]; SECFN *wsec; char pad2[4]; FILEFN *f28; FILEFN *f32; };
struct file { char pad[14]; struct ops *ops; };
struct geom { char pad[48]; unsigned int spf; char pad2[8]; unsigned char nfat; char pad3; };
struct vol { char pad[14]; struct ops *ops; char pad2[8]; struct geom *geom; };
struct buf { struct vol *vol; long sec; long l8; char pad[6]; int age; int stat; unsigned char flags;
	unsigned char idx; unsigned char drv; char pad2; unsigned char data[512]; };
extern struct file *__cdecl FileOpen(char *, char *);
extern char FileOpenDefault_Str_w[];

int __cdecl FileOpenDefault(char *name)
{
	struct file *fp;

	fp = FileOpen(name, FileOpenDefault_Str_w);
	if (fp == 0)
		return -1;
	return fp->ops->f32(fp);
}
