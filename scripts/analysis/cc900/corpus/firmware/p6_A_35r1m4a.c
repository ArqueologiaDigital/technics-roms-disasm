/* Probe round 35r1, helper A, form a: boot/system_handlers.s (module 4), xr_screen family.
   SLIDE_Parse_Header(p, dst): 0xffff unless p starts with "SLIDE"; then the window letter after it ('4' / '8')
   picks the 4K or 8K SLIDE decompressor for the data two bytes further on; 0 otherwise.
   p is a `register` parameter (XIZ), dst stays on the frame; the signature is an initialised auto array. */
/* cc900-data: SLIDE_Parse_Header 1 = SLIDE_STRING */
/* cc900-module: SLIDE_Decompress_4K_Init SLIDE_Decompress_8K_Init */

extern int __cdecl String_Compare(void *, void *, int);
extern void SLIDE_Decompress_4K_Init(unsigned char *, void *);
extern void SLIDE_Decompress_8K_Init(unsigned char *, void *);
extern int SLIDE_Parse_Header(unsigned char *, void *);

int SLIDE_Parse_Header(register unsigned char *p, void *dst)
{
    char sig[6] = "SLIDE";

    if (String_Compare(p, sig, 5) == 0) {
        p += 5;
        if (*p == '4') {
            p += 2;
            SLIDE_Decompress_4K_Init(p, dst);
        } else if (*p == '8') {
            p += 2;
            SLIDE_Decompress_8K_Init(p, dst);
        }
        return 0;
    }
    return -1;
}
