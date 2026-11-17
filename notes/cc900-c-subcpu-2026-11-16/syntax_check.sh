#!/bin/bash
# Does each probe file pass a C89 syntax check before it goes into a VM run?
#
# QUESTION ANSWERED: a file V4.23 refuses loses all its functions; gcc -fsyntax-only with the cc900 keywords
# defined away catches most of that first.  Prints BAD <file> for each failure and the number of files checked.
#
#   bash notes/cc900-c-subcpu-2026-11-16/syntax_check.sh FILE.c ...      (repository root)
n=0
for f in "$@"; do
    n=$((n + 1))
    gcc -fsyntax-only -w -std=c89 -D__near= -D__tiny= -D__cdecl= -D'__asm(x)=' -D'__ASM(x)=' \
        -D__WA=__wa -D__A=__a -D__HL=__hl -D__DE=__de -D__IZ=__iz "$f" 2>/dev/null || echo "BAD $f"
done
echo "$n files checked"
