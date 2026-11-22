/* Probe round 36r1, helper B, form a: audio/note_voice_mapping.s (module 306, -O3 -Xr like the built
   note_voice_mapping_m306.c).
   SoundRam_ConvertKn1500Record(x, s): fill the record x with the defaults, then move a KN1500 record's fields in:
   the 16-byte name (a struct copy: ldirw), single bytes to their new offsets, 8 bytes 33.. to 94.., and four
   62-byte source blocks (from s + 41) into four 81-byte blocks (from x + 102), field by field (block byte 3
   masked with 0xcf, byte 7 set to 50, byte 0 bit 7 = source byte 12 bit 4).
   x is a `register` parameter (XIZ), s stays on the frame (+10); the 8-byte loop's counter is a `register` char
   (the ROM keeps it in QC, with a 16-bit copy of it in BC); the block loop's counter (+4) and its two running
   offsets (81 per block at +6, 62 per block at +8) are frame variables, the two block pointers `register` locals
   (XBC / XDE, no call in the loop). */
/* cc900-module: SoundRam_FillDefaultRecord */

struct name16 { unsigned char c[16]; };
extern void SoundRam_FillDefaultRecord(unsigned char *);
extern void SoundRam_ConvertKn1500Record(unsigned char *, unsigned char *);

void SoundRam_ConvertKn1500Record(register unsigned char *x, unsigned char *s)
{
    int o2;
    int o1;
    unsigned char k;
    register unsigned char i;
    register unsigned char *d;
    register unsigned char *p;

    SoundRam_FillDefaultRecord(x);
    *(struct name16 *)x = *(struct name16 *)s;
    x[16] = s[16];
    x[17] = s[17];
    x[18] = s[18];
    x[19] = s[19];
    x[24] = s[20];
    x[25] = s[21];
    x[36] = s[22];
    x[37] = s[23];
    x[41] = s[24];
    x[42] = s[25];
    x[43] = s[26];
    x[44] = s[27];
    x[45] = s[28];
    x[46] = s[29];
    x[92] = s[31];
    x[93] = s[32];
    for (i = 0; i < 8; i++)
        x[i + 94] = s[i + 33];
    for (k = 0, o2 = 0, o1 = 0; k < 4; k++, o1 += 81, o2 += 62) {
        d = &x[o1 + 102];
        p = &s[o2 + 41];
        d[1] = p[0];
        d[2] = p[1];
        d[3] = p[2];
        d[3] &= 0xcf;
        d[4] = p[3];
        d[5] = p[4];
        d[6] = p[5];
        d[7] = 50;
        d[8] = p[6];
        d[9] = p[7];
        d[10] = p[8];
        d[11] = p[9];
        d[23] = p[10];
        d[24] = p[11];
        d[25] = p[12];
        d[0] &= 0x7f;
        if ((p[12] & 0x10) == 0x10)
            d[0] |= 0x80;
        d[26] = p[13];
        d[27] = p[14];
        d[28] = p[15];
        d[29] = p[16];
        d[30] = p[17];
        d[31] = p[18];
        d[32] = p[19];
        d[33] = p[20];
        d[34] = p[21];
        d[35] = p[22];
        d[36] = p[23];
        d[37] = p[24];
        d[39] = p[25];
        d[41] = p[26];
        d[42] = p[27];
        d[43] = p[28];
        d[44] = p[29];
        d[45] = p[30];
        d[46] = p[31];
        d[47] = p[32];
        d[48] = p[33];
        d[49] = p[34];
        d[50] = p[35];
        d[51] = p[36];
        d[52] = p[37];
        d[53] = p[38];
        d[54] = p[39];
        d[55] = p[40];
        d[57] = p[42];
        d[58] = p[43];
        d[59] = p[44];
        d[60] = p[45];
        d[77] = p[41];
        d[61] = p[46];
        d[62] = p[47];
        d[63] = p[48];
        d[64] = p[49];
        d[65] = p[50];
        d[66] = p[51];
        d[67] = p[52];
        d[68] = p[53];
        d[69] = p[54];
        d[70] = p[55];
        d[71] = p[56];
        d[72] = p[57];
        d[73] = p[58];
        d[74] = p[59];
        d[75] = p[60];
        d[76] = p[61];
    }
}
