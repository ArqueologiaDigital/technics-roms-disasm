/* lane_p6 helper F, round 4, module 267 (demo/file_demo_proc.s), form a.
   FileIO_CompareFiles: copy one file to another through the 4 KB buffer at RAM 0x69800, which the ROM addresses
   as a symbol (`lda xwa,sym`, kept in a stack slot), so this form names it ram_69800.  Run 55 showed the while loop
   gives the ROM's layout; scalars are declared in the ROM's ascending slot order (fi +2, fo +6, r +10, buf +12).
   __near: 16-bit absolute operand; plain: 24-bit (or a ROM label).  One declarator per __near declaration. */

struct FileS { char pad[6]; int flag; };
typedef struct FileS *FileP;
extern FileP __cdecl FileOpen(char *, char *);
extern int __cdecl FileRead(char *, int, int, FileP);
extern int __cdecl FileWrite(char *, int, int, FileP);
extern int __cdecl FileClose(FileP);
struct Path16 { char s[16]; };
extern struct Path16 FileIO_CompareFiles_Path2Init;
extern struct Path16 FileIO_CompareFiles_PathInitB;
extern char FileIO_CompareFiles_Str_wb[];
extern char FileIO_Compare_Mismatch_Str_rb[];
extern int FILE_ERROR;
extern FileP __near ram_7f44;
extern char ram_69800[];
extern void FileIO_BuildFilePath(char *, char *);

int FileIO_CompareFiles(char *dst, char *src)
{
    struct Path16 pb;
    struct Path16 pa;
    FileP fi;
    FileP fo;
    int r;
    char *buf;
    int n;

    r = 0;
    pb = FileIO_CompareFiles_Path2Init;
    pa = FileIO_CompareFiles_PathInitB;
    FileIO_BuildFilePath(pa.s, dst);
    fo = FileOpen(pa.s, FileIO_CompareFiles_Str_wb);
    if (fo == 0) {
        if (FILE_ERROR == 31) return -11;
        return -3;
    }
    FileIO_BuildFilePath(pb.s, src);
    fi = FileOpen(pb.s, FileIO_Compare_Mismatch_Str_rb);
    if (fi == 0) {
        FileClose(fo);
        return -2;
    }
    buf = ram_69800;
    while ((n = FileRead(buf, 1, 0x1000, fi)) > 0) {
        if (FileWrite(buf, 1, n, fo) != n) {
            if ((ram_7f44->flag & 0x7fff) == 0x1f) r = -11;
            else r = -3;
            break;
        }
    }
    if (r >= 0 && !(fi->flag & 0x8000)) r = -2;
    FileClose(fi);
    FileClose(fo);
    return r;
}
