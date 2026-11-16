/* Phase 6, lane_p6 helper A, round 10, form a: SoundRam_IdentifyImage (audio/note_voice_mapping.s).  V4.23 loads
   the right-hand operand of the compare and evaluates the left one's address first; the ROM computes p + i first
   and loads the id-table byte, so the compare is written p[i] != q[i], with i set before the table pointer. */
extern unsigned char SoundRam_Id_KN5000[];
extern unsigned char SoundRam_Id_KN1500[];
extern unsigned char SoundRam_Id_KN3000[];
extern unsigned char SoundRam_Id_KN2000[];
extern unsigned char SoundRam_Id_MKA[];
extern unsigned char SoundRam_Id_MKB[];

unsigned char SoundRam_IdentifyImage(unsigned char *p)
{
    unsigned int i;
    unsigned char *q;
    i = 0;
    q = SoundRam_Id_KN5000;
    do {
        if (p[i] != q[i])
            break;
        i++;
    } while (i < 16);
    if (i == 16)
        return 6;
    i = 0;
    q = SoundRam_Id_KN1500;
    do {
        if (p[i] != q[i])
            break;
        i++;
    } while (i < 16);
    if (i == 16)
        return 5;
    i = 0;
    q = SoundRam_Id_KN3000;
    do {
        if (p[i] != q[i])
            break;
        i++;
    } while (i < 16);
    if (i == 16)
        return 4;
    i = 0;
    q = SoundRam_Id_KN2000;
    do {
        if (p[i + 5] != q[i])
            break;
        i++;
    } while (i < 6);
    if (i == 6)
        return 1;
    i = 0;
    q = SoundRam_Id_MKA;
    do {
        if (p[i + 5] != q[i])
            break;
        i++;
    } while (i < 3);
    if (i == 3)
        return 2;
    i = 0;
    q = SoundRam_Id_MKB;
    do {
        if (p[i + 5] != q[i])
            break;
        i++;
    } while (i < 3);
    if (i == 3)
        return 3;
    return 0;
}
