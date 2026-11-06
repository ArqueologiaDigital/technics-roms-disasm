/* accomp_screens_link.ld — Shared linker script for Accompaniment screen data files
 *
 * Provides absolute symbol addresses for extern references in accomp screen C files.
 * These addresses point to data tables in accompaniment_engine.s.
 * v7 COPY: every address is 0x404 below its v9/v10 value.
 * v5: each address is v5's own (scripts/converters/ported_c_rebase.py --own-values; v7's in the comment).
 */

ENTRY(0)

SECTIONS {
    .text : { *(.text*) }
    /DISCARD/ : { *(.comment) *(.note*) *(.eh_frame*) }
}

/* Accompaniment display string name tables */
Accomp_SectionParam_Names  = 0x00F6A565;  /* "CONTROL PITCH BEND =..." */  /* v7: 0x00F6A89C */
Accomp_PartOnOff_Names     = 0x00F6A5EC;  /* "OFF ON" */  /* v7: 0x00F6A923 */
Accomp_Articulation_Names  = 0x00F6A711;  /* "TENUNORMSTACCUTTACCOMP 1..." */  /* v7: 0x00F6AA48 */
