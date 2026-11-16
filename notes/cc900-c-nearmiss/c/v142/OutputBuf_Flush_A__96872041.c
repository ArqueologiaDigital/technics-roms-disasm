/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of sub/v142/voice_params_and_tvf_a_11c.c (2026-11-16-101-sub-r14)
   sha256 96872041ebdd6011b20b77f457627abe51135139323cb73f11552bef4c787f2e (name+funcs); compiled at -Xr
   cc900-options: -Xr */
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
