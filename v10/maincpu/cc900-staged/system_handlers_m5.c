/* Functions of boot/system_handlers.s.  Firmware C (cc900 phase 6), STAGED: Toshiba V4.23 reproduces these functions' ROM bytes
   (notes/cc900-phase6-2026-11-16/staged_v423.tsv); they move into cc900/ once `make` compiles with V4.23.
   Names are the tree's; ram_<hex> is a RAM cell the tree has not named yet.
   __near / __tiny: the cells the ROM reaches with 16 / 8-bit operands (V4.23 then declares them medium / small;
   a plain extern is large, 24-bit).  Each __near / __tiny declaration names one object: V4.23 applies the
   qualifier to the first declarator only.
   cc900-options: -O3 -Xr
*/

typedef unsigned int *uip;
extern unsigned char __near ram_654;
extern unsigned char __near ram_62c[];
extern uip __near ram_656;
extern unsigned long __near ram_642;
extern void Flash_ProgramWord(int, unsigned int *, unsigned int);
extern unsigned long __near SYSTEM_TIMESTAMP;
extern void TableDataFlash_ChipErase(void);
extern int HDAE5000_Status_Check(void);
extern void VRAM_FillRect(int, int, int);
extern unsigned char HDAE5000_PPI__PORT_A;
extern unsigned int CUSTOM_DATA_FLASH__BASE_ADDR;
extern unsigned int ram_200000;
struct fdcp { unsigned int w0; unsigned int head; unsigned int side; unsigned int cyl; unsigned int sec; unsigned int n; long p; };
extern struct fdcp __near ram_62e;
extern unsigned long Math_DivideU32(unsigned long, unsigned long);
extern unsigned long Math_RemainderU32(unsigned long, unsigned long);

void Flash_AccumWrite_Word(unsigned char a)
{
    ram_62c[ram_654] = a;
    if (ram_654++ == 1) {
        Flash_ProgramWord(1, ram_656++, *(unsigned int *)ram_62c);
        ram_654 = 0;
    }
    ram_642 += 1;
}

void Flash_BurnWithProgress(void)
{
    int x = 0x32;
    SYSTEM_TIMESTAMP = 0;
    TableDataFlash_ChipErase();
    while (HDAE5000_Status_Check() == -1) {
        if (SYSTEM_TIMESTAMP > 500) {
            x += 8;
            VRAM_FillRect(x, 0xb4, 5);
            SYSTEM_TIMESTAMP = 0;
        }
    }
}

void HDAE5000_ProgramCustomDataFlash(void)
{
    unsigned int *src;
    unsigned int *dst = &CUSTOM_DATA_FLASH__BASE_ADDR;
    unsigned char bank;
    unsigned long i;
    bank = 0;
    do {
        HDAE5000_PPI__PORT_A = bank;
        src = &ram_200000;
        i = 0;
        do {
            Flash_ProgramWord(1, dst++, *src++);
            i++;
        } while (i < 0x40000);
        bank++;
    } while (bank < 2);
}

void FDC_SetupSectorParams(unsigned long lba, unsigned int n, long p)
{
    struct fdcp *f;
    unsigned int *sp;
    unsigned int t;
    t = Math_DivideU32(lba, 18);
    f = &ram_62e;
    f->head = 0;
    f->cyl = t >> 1;
    f->side = t & 1;
    sp = &f->sec;
    *sp = Math_RemainderU32(lba, 18) + 1;
    f->n = n;
    f->p = p;
}
