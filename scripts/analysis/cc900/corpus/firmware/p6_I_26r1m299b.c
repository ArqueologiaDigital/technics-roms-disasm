/* lane_p6 helper I, round 26r1, form b: module 299 (audio/note_voice_mapping.s), family of 2 x 302 B (-Xr):
   SeqPart_EmitMelodicNote and SeqPart_EmitPercussionNote.  Two 164-byte nrec records in the frame (r at xsp+0, the
   lookup key s at +164 with its bytes 2 / 3 set before each NoteMap_LookupVoice), two identical two-layer bodies
   under `c != 0xff && e != 0xff` and `c == 0xff && e != 0xff`.  Form b declares r before s (form a: s before r).
   cc900-options: -Xr
*/

struct nrec { unsigned char b0, count, b2, b3; unsigned char ent[32][5]; };

extern unsigned char NoteMap_LookupVoice(struct nrec *, void *, unsigned int, unsigned int);
extern void Voice_BuildAndEmitNoteOnEvents(struct nrec *, unsigned int);
extern void SeqPart_EmitNoteOnMessages(struct nrec *, unsigned int);

void SeqPart_EmitMelodicNote(unsigned char a, unsigned char c, unsigned char e)
{
  struct nrec r;
  struct nrec s;
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

void SeqPart_EmitPercussionNote(unsigned char a, unsigned char c, unsigned char e)
{
  struct nrec r;
  struct nrec s;
  if (c != 0xff && e != 0xff) {
    s.b2 = 0;
    s.b3 = 0;
    if (NoteMap_LookupVoice(&r, &s, 0, a) != 0)
      SeqPart_EmitNoteOnMessages(&r, e);
    s.b2 = 1;
    s.b3 = 0xff;
    if (NoteMap_LookupVoice(&r, &s, 0, a) != 0)
      SeqPart_EmitNoteOnMessages(&r, e);
  } else if (c == 0xff && e != 0xff) {
    s.b2 = 0;
    s.b3 = 0;
    if (NoteMap_LookupVoice(&r, &s, 0, a) != 0)
      SeqPart_EmitNoteOnMessages(&r, e);
    s.b2 = 1;
    s.b3 = 0xff;
    if (NoteMap_LookupVoice(&r, &s, 0, a) != 0)
      SeqPart_EmitNoteOnMessages(&r, e);
  }
}
