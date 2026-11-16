/* Functions of demo/file_demo_proc.s.  Firmware C (cc900 phase 6), STAGED: Toshiba V4.23 reproduces these functions' ROM bytes
   (notes/cc900-phase6-2026-11-16/staged_v423.tsv); they move into cc900/ once `make` compiles with V4.23.
   Names are the tree's; ram_<hex> is a RAM cell the tree has not named yet.
   __near / __tiny: the cells the ROM reaches with 16 / 8-bit operands (V4.23 then declares them medium / small;
   a plain extern is large, 24-bit).  Each __near / __tiny declaration names one object: V4.23 applies the
   qualifier to the first declarator only.
   cc900-options: -O3 -Xr
*/

extern unsigned char ram_25ec0[];
extern int ram_25ea8, ram_271ea, ram_271ec, ram_271ee, FILE_LIST_LAST, ram_272c8, ram_272ca;
extern char ram_25db6;
extern unsigned char ram_272d0;
extern unsigned char SEQ_SONG_SLOTS[];

unsigned char *Demo_GetPresetBaseForPartExt(unsigned char i)
{
    unsigned char *p;
    if (((long *)0x9c4000)[i] != 0) p = (unsigned char *)0x69800;
    else p = SEQ_SONG_SLOTS;
    return p + 208;
}

void FileIO_BuildFilePath(char *d, char *s)
{
    if (*d != 0) do d++; while (*d != 0);
    if (*s != 0) do *d++ = *s++; while (*s != 0);
    *d = 0;
}

unsigned char FileIO_GetRecordAttr_Check(void)
{
    int i = ram_25ea8;
    if (i < 0 || i >= 20) return 0;
    return ram_272d0;
}

void FileIO_GetRecordType_Extended(unsigned char *s)
{
    if (*s == 0) return;
    do {
        if (*s == 0x7e) *s = 0x5f;
        else if (*s < 0x20) *s = 0x20;
        s++;
    } while (*s != 0);
}

int ValidateFileRangeType5(int i)
{
    int b;
    if (ram_25db6 != 5 || i < 0 || i > ram_271ec) return -1;
    b = ram_271ee;
    if (i < b || i > FILE_LIST_LAST) return 1;
    if (ram_25ec0[(i - b) * 82] == 0) return 2;
    return 0;
}

int ValidateFileSelectionIndex(int i)
{
    char m = ram_25db6;
    if ((m != 2 && m != 3 && m != 4) || i < 0 || i >= 20) return -1;
    return 0;
}

unsigned char *Voice_GetPresetFieldAddr(unsigned char i)
{
    unsigned char *p;
    if (((long *)0x9c4000)[i] != 0) p = (unsigned char *)0x69800;
    else p = SEQ_SONG_SLOTS;
    return p + 32;
}

extern unsigned int ram_272cc, ram_272ce;

void FileIO_BuildRecordPath_Done(unsigned char a) { if (a < 10) ram_272ce |= (unsigned int)1 << a; }

void FileIO_BuildRecordPath_Return(unsigned char a) { if (a < 10) ram_272ce &= ((unsigned int)1 << a) ^ 0xffff; }

void FileIO_FormatName_Loop(unsigned char a) { if (a < 10) ram_272cc |= (unsigned int)1 << a; }

extern unsigned char ram_2723c[];
extern int ram_271ee;
extern int FILE_LIST_LAST;
extern int ram_272ca;

unsigned char *Demo_GetPresetBaseForPart(unsigned char i)
{
    unsigned char *p;
    if (((long *)0x9c4000)[i] != 0) p = (unsigned char *)0x69800;
    else p = SEQ_SONG_SLOTS;
    p += 2048;
    return p;
}

int FileIO_ValidateModeAndRange(int i)
{
    char m = ram_25db6;
    int b;
    if ((m != 2 && m != 3 && m != 4) || i < 0 || i > ram_272ca) return -1;
    b = ram_271ee;
    if (i < b || i > FILE_LIST_LAST) return 1;
    if (ram_2723c[(i - b) * 14] == 0) return 2;
    return 0;
}

int ParseTwoDigitFileNum(char *s)
{
    char c;
    int v;
    if (s[0] < '0' || s[0] > '2') return -1;
    c = s[1];
    if (c < '0' || c > '9') return -1;
    v = (char)(s[0] * 10 + c - 0x10);
    if (v < 1 || v > 20) return -1;
    return v - 1;
}

extern unsigned char __near SEQ_TRACK_ASSIGN[];
extern unsigned char __near SEQ_TRACK_TABLE[];
extern unsigned char __near ram_d56;
extern unsigned char __near ram_d54;
extern unsigned char __near SEQ_EDIT_FLAGS;
extern unsigned int Demo_PartBitMask[];
extern unsigned int __near SEQ_TRACK_MASK;

void Demo_ScanActivePartChannels(void)
{
    unsigned char i;
    i = 0;
    do {
        if (SEQ_TRACK_ASSIGN[i] == 16) {
            if ((Demo_PartBitMask[i] & SEQ_TRACK_MASK) != 0 && (SEQ_TRACK_TABLE[(int)i * 3] & 0x80) != 0) {
                ram_d56 = i + 1;
                ram_d54 |= 1;
                SEQ_EDIT_FLAGS |= 4;
                break;
            }
            i = 15;
        }
    } while (++i < 16);
    if (i == 16) {
        ram_d54 &= ~1;
        SEQ_EDIT_FLAGS &= ~4;
    }
}

unsigned int Voice_GetPresetFieldWord(unsigned char i)
{
    unsigned char *p;
    if (((long *)0x9c4000)[i] != 0) p = (unsigned char *)0x69800;
    else p = SEQ_SONG_SLOTS;
    p += 30;
    return *(unsigned int *)p;
}

extern unsigned char ram_25eb2[];
extern int ram_271ec;

void FileIO_CopyString(char *d, char *s)
{
    if (*s != 0) do *d++ = *s++; while (*s != 0);
    *d = 0;
}

int ValidateFileRange(int i)
{
    char m = ram_25db6;
    int b;
    if ((m != 2 && m != 3 && m != 4) || i < 0 || i > ram_271ec) return -1;
    b = ram_271ee;
    if (i < b || i > FILE_LIST_LAST) return 1;
    if (ram_25eb2[(i - b) * 82] == 0) return 2;
    return 0;
}

int ValidateFileRangeAlt(int i)
{
    char m = ram_25db6;
    int b;
    if ((m != 6 && m != 7) || i < 0 || i > ram_271ec) return -1;
    b = ram_271ee;
    if (i < b || i > FILE_LIST_LAST) return 1;
    if (ram_25eb2[(i - b) * 82] == 0) return 2;
    return 0;
}

struct frec { unsigned int w[6]; };
extern unsigned int ram_25db8[];

unsigned char *Demo_GetPresetBaseForPartAlt(unsigned char i)
{
    unsigned char *p;
    if (((long *)0x9c4000)[i] != 0) p = (unsigned char *)0x69800;
    else p = SEQ_SONG_SLOTS;
    p += 768;
    return p;
}

unsigned int FileIO_GetRecordFlags(unsigned int i)
{
    if (i >= 20) return 0;
    return ((struct frec *)ram_25db8)[i].w[0];
}
