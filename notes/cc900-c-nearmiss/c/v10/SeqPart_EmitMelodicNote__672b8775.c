/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_I_26r1m299a.c (2026-11-22-5-p6-r72)
   sha256 672b87756327b21ea7bccb7c01abaacb2da5f927195e82d4850a9865fcbd5451 (tar-sha256); compiled at -Xr
   cc900-options: -Xr */
struct nrec { unsigned char b0, count, b2, b3; unsigned char ent[32][5]; };
extern unsigned char NoteMap_LookupVoice(struct nrec *, void *, unsigned int, unsigned int);
extern void Voice_BuildAndEmitNoteOnEvents(struct nrec *, unsigned int);
void SeqPart_EmitMelodicNote(unsigned char a, unsigned char c, unsigned char e)
{
  struct nrec s;
  struct nrec r;
  if (c != 0xff && e != 0xff) {
    s.b2 = 0;
    s.b3 = 0;
    if (NoteMap_LookupVoice(&r, &s, 0, e) != 0)
      Voice_BuildAndEmitNoteOnEvents(&r, a);
    s.b2 = 1;
    s.b3 = 0xff;
    if (NoteMap_LookupVoice(&r, &s, 0, e) != 0)
      Voice_BuildAndEmitNoteOnEvents(&r, a);
  } else if (c == 0xff && e != 0xff) {
    s.b2 = 0;
    s.b3 = 0;
    if (NoteMap_LookupVoice(&r, &s, 0, e) != 0)
      Voice_BuildAndEmitNoteOnEvents(&r, a);
    s.b2 = 1;
    s.b3 = 0xff;
    if (NoteMap_LookupVoice(&r, &s, 0, e) != 0)
      Voice_BuildAndEmitNoteOnEvents(&r, a);
  }
}
