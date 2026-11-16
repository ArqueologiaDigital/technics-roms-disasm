/* Phase 6, lane_p6 helper A, round 10, form b: SoundRam_IdentifyImage (audio/note_voice_mapping.s).  V4.23 loads
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
    for (; i < 16; i++)
        if (p[i] != q[i])
            break;
    if (i == 16)
        return 6;
    i = 0;
    q = SoundRam_Id_KN1500;
    for (; i < 16; i++)
        if (p[i] != q[i])
            break;
    if (i == 16)
        return 5;
    i = 0;
    q = SoundRam_Id_KN3000;
    for (; i < 16; i++)
        if (p[i] != q[i])
            break;
    if (i == 16)
        return 4;
    i = 0;
    q = SoundRam_Id_KN2000;
    for (; i < 6; i++)
        if (p[i + 5] != q[i])
            break;
    if (i == 6)
        return 1;
    i = 0;
    q = SoundRam_Id_MKA;
    for (; i < 3; i++)
        if (p[i + 5] != q[i])
            break;
    if (i == 3)
        return 2;
    i = 0;
    q = SoundRam_Id_MKB;
    for (; i < 3; i++)
        if (p[i + 5] != q[i])
            break;
    if (i == 3)
        return 3;
    return 0;
}
