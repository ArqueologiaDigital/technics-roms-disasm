/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of sub/sub_A_11c.c (2026-11-16-94-sub-r11)
   sha256 289f70d23c2e7948707c019c386ce0ddb32ebe52b97624c696c04b7ae0fbf151 (name+funcs); compiled at -Xr */
void OutputBuf_Flush_A(unsigned char **pp, unsigned char *head, unsigned char key, char all)
{
    unsigned char *n;
    if (head != 0) {
        n = head;
        do {
            if (all != 0 || n[35] == key) {
                **pp = n[36];
                *pp += 1;
            }
            n = (*(unsigned char **)((n) + (8)));
        } while (n != head);
    }
    **pp = 0xff;
}
