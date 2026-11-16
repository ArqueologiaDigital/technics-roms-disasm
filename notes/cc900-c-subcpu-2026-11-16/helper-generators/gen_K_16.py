"""helper K, round 16: derive sub_K_16b.c and sub_K_16c.c from sub_K_16a.c by exact text replacements
(each must hit exactly the stated number of times).  Usage: python3 gen16.py"""
import sys
D = '/home/fsanches/compartilhado/disasm-lanes/csub/scripts/analysis/cc900/corpus/firmware/'
src = open(D + 'sub_K_16a.c').read()


def rep(t, old, new, n=1):
    if t.count(old) != n:
        sys.exit('expected %d of %r, found %d' % (n, old[:60], t.count(old)))
    return t.replace(old, new)


def cut(t, a, b):
    i = t.index(a); j = t.index(b, i)
    return t[:i], t[i:j], t[j:]


K = '        k = ((unsigned int)m[3] << 8) | (unsigned int)m[4];\n'

# the five functions of form a
head, rest = src.split('void Audio_Cmd_ToneEdit_Dispatch', 1)
audio, rest = rest.split('void VoiceParam_Set_Tone_Option', 1)
tone, rest = rest.split('void TVF_Emit_Registers(', 1)
tvf1, rest = rest.split('void TVF_Emit_Registers_Type2(', 1)
tvf2, route = rest.split('void DSP_VoiceCoeffRoute2(', 1)
audio = 'void Audio_Cmd_ToneEdit_Dispatch' + audio
tone = 'void VoiceParam_Set_Tone_Option' + tone
tvf1 = 'void TVF_Emit_Registers(' + tvf1
tvf2 = 'void TVF_Emit_Registers_Type2(' + tvf2
route = 'void DSP_VoiceCoeffRoute2(' + route
head_body = head[head.index('*/') + 3:]
head_body = rep(head_body, 'extern void Set_Tone_Option_CharV(unsigned int part, unsigned int idx, char v);\n', '')
names = ''.join(l + '\n' for l in head.split('\n') if 'cc900-' in l and 'Set_Tone_Option_CharV' not in l)


def audio_block(t, typ, expr):
    t = rep(t, '    unsigned int k;\n', '')
    t = rep(t, 'Set_Tone_Option_CharV(', 'VoiceParam_Set_Tone_Option(')
    out = []
    lines = t.split('\n')
    i = 0
    while i < len(lines):
        l = lines[i]
        if l.startswith('    case ') and i + 1 < len(lines):
            # a case whose body sets k: wrap the body in a block with its own k
            j = i + 1
            while not lines[j].startswith('        break;'):
                j += 1
            body = lines[i + 1:j]
            if any(b.strip().startswith('k = ') for b in body):
                out.append(l + ' {')
                out.append('        %s k;' % typ)
                for b in body:
                    out.append(b if not b.strip().startswith('k = ') else '        k = %s;' % expr)
                out.append('        break;')
                out.append('    }')
                i = j + 1
                continue
        out.append(l)
        i += 1
    return '\n'.join(out)


def tone_charv(t, ret, test, body):
    t = rep(t, 'void VoiceParam_Set_Tone_Option(unsigned char part, unsigned char idx, unsigned char v)',
            '%s VoiceParam_Set_Tone_Option(unsigned char part, unsigned char idx, char v)' % ret)
    t = rep(t, '    int t = idx;\n    unsigned int o = t;\n    o += 472;\n    ram_44fce[(int)o] = v;\n', body)
    return rep(t, 'if (v != 0xf5)', 'if (%s)' % test)


# ---- form b
b_audio = audio_block(audio, 'int', '((int)m[3] << 8) | (int)m[4]')
b_tone = tone_charv(tone, 'void', 'v != (char)0xf5',
                    '    int o = (unsigned int)idx;\n    o += 472;\n    ram_44fce[o] = v;\n')
b_tvf1 = rep(tvf1, '    int e;\n', '    volatile int e;\n')
b_tvf2 = rep(tvf2, '    unsigned int e;\n', '    unsigned int e[1];\n')
b_tvf2 = rep(b_tvf2, '                e = ', '                e[0] = ', 2)
b_tvf2 = rep(b_tvf2, 'TVF_Clamp_Cutoff(e)', 'TVF_Clamp_Cutoff(e[0])')
b_route = rep(route, '    unsigned int d;\n', '    unsigned int d;\n    unsigned char *src;\n')
b_route = rep(b_route, '    tbl = ToneDB_RelBase + tbl;\n', '    src = (unsigned char *)(ToneDB_RelBase + tbl);\n')
b_route = rep(b_route, '((unsigned char *)tbl)[(unsigned long)d * 16 + i]', 'src[(unsigned long)d * 16 + i]')
b_route = rep(b_route, '((unsigned char *)tbl + (unsigned long)d * 16)[13]', '(src + (unsigned long)d * 16)[13]')
b_route = rep(b_route, '(unsigned char)(d & 0xff)', 'd % 256')
b_route = rep(b_route, '(unsigned char)(d >> 8)', 'd / 256')
b_head = '''/* lane_sub helper K, round 16, form b (KN5000 sub-CPU payload v1.42): second spellings of sub_K_16a.c's functions.
   - Audio_Cmd_ToneEdit_Dispatch: the catalog index a block-scope int local of each case, built from int casts;
     VoiceParam_Set_Tone_Option is called through this file's own definition (plain char third parameter).
   - VoiceParam_Set_Tone_Option: sub_H_15c's index (`int o = (unsigned int)idx`), the value parameter a plain char
     compared with `(char)0xf5`.
   - TVF_Emit_Registers: form a with the second offset volatile (to keep it out of IZ: the ROM has it in the frame
     and the record pointer in XIZ).
   - TVF_Emit_Registers_Type2: form a's with the second offset a one-element array.
   - DSP_VoiceCoeffRoute2: the source table's offset read into the table variable, then a separate pointer
     `src = (unsigned char *)(ToneDB_RelBase + tbl)`; the low and high byte as `d % 256` and `d / 256`.

'''
open(D + 'sub_K_16b.c', 'w').write(b_head + ''.join('   ' + l.strip() + '\n' for l in names.split('\n') if l.strip())
                                   + '*/\n' + head_body + b_tone + b_audio + b_tvf1 + b_tvf2 + b_route)

# ---- form c
c_audio = audio_block(audio, 'unsigned int', '((unsigned int)m[3] << 8) | (unsigned int)m[4]')
c_tone = tone_charv(tone, 'int', '(unsigned char)v != 0xf5',
                    '    int o = (unsigned int)idx;\n    o += 472;\n    ram_44fce[o] = v;\n')
c_tvf1 = rep(tvf1, '        break;\n    }\n}\n', '        break;\n    }\n    (void)e;\n}\n')
c_tvf2 = rep(tvf2, '            ram_451d6 = *(int *)(v + 68);\n        }\n        break;\n',
             '            ram_451d6 = *(int *)(v + 68);\n        }\n        (void)e;\n        break;\n')
c_route = rep(route, '    unsigned char s;\n    unsigned char z;\n    unsigned int x;\n    unsigned int y;\n    unsigned long tbl;\n    unsigned int d;\n    unsigned int n;\n    unsigned int i;\n',
              '    unsigned int n;\n    unsigned int d;\n    unsigned char *tbl;\n    unsigned char s;\n    unsigned char z;\n    unsigned int x;\n    unsigned int y;\n    unsigned int i;\n')
for k in ('22', '24', '23'):
    c_route = rep(c_route, 'tbl = ToneDB_RootPtr[%s];' % k, 'tbl = (unsigned char *)ToneDB_RootPtr[%s];' % k,
                  2 if k == '22' else 1)
c_route = rep(c_route, '+ tbl + ToneDB_RelBase);', '+ (unsigned long)tbl + ToneDB_RelBase);')
c_route = rep(c_route, '    tbl = ToneDB_RootPtr[25];\n    tbl = ToneDB_RelBase + tbl;\n',
              '    tbl = (unsigned char *)ToneDB_RootPtr[25];\n    tbl = (unsigned char *)(ToneDB_RelBase + (unsigned long)tbl);\n')
c_route = rep(c_route, '((unsigned char *)tbl)[(unsigned long)d * 16 + i]', 'tbl[(unsigned long)d * 16 + i]')
c_route = rep(c_route, '((unsigned char *)tbl + (unsigned long)d * 16)[13]', '(tbl + (unsigned long)d * 16)[13]')
c_route = rep(c_route, '(unsigned char)(d & 0xff)', '(int)d & 0xff')
c_route = rep(c_route, '(unsigned char)(d >> 8)', '(int)(d >> 8)')
c_head = '''/* lane_sub helper K, round 16, form c (KN5000 sub-CPU payload v1.42): third spellings of sub_K_16a.c's functions.
   - Audio_Cmd_ToneEdit_Dispatch: the catalog index a block-scope unsigned int local of each case;
     VoiceParam_Set_Tone_Option is called through this file's own definition (plain char third parameter).
   - VoiceParam_Set_Tone_Option: form b's with an int return type and no return statement (a probe: does a
     function that returns a value keep its locals out of HL?  The ROM has the index in DE), the value compared
     as `(unsigned char)v != 0xf5`.
   - TVF_Emit_Registers: form a with a reference to the second offset that makes no code after the switch (a probe
     of the register choice: does a longer span keep it out of IZ?).
   - TVF_Emit_Registers_Type2: form a's with such a reference at the end of case 5.
   - DSP_VoiceCoeffRoute2: the table variable a char pointer used for both tables, the count and the entry index
     declared first; the low and high byte through int expressions.

'''
open(D + 'sub_K_16c.c', 'w').write(c_head + ''.join('   ' + l.strip() + '\n' for l in names.split('\n') if l.strip())
                                   + '*/\n' + head_body + c_tone + c_audio + c_tvf1 + c_tvf2 + c_route)
print('ok')
