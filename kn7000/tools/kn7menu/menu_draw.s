# (c) 2026 Felipe Correa da Silva Sanches <juca@members.fsf.org>
# Licensed under the terms of the GNU General Public License v3 or later
#
# menu_draw.s -- the program menu's screen (included by menu.s). The LCD is 640 x 240 RGB565 at FB
# (kn7cnv.inc). The layout follows the firmware's own screens: a title bar TITLE_H high, then five rows
# of ROW_H, each beside one of the buttons left and right of the display (LCDL 1..5, LCDR 1..5). A row of
# the list is a program; the right buttons' labels sit after LIST_W.

# Refresh: draw what V_REDRAW asks for; when nothing was asked, sample the LCD and draw everything again
# if it is no longer what we drew (the firmware painted over it).
Refresh:
    movm    [d2,d3,a2,a3], (sp)
    add     -0x20, sp
    mov     (V_STATE), d0
    cmp     ST_END, d0
    beq     rfh_ret
    mov     (V_REDRAW), d0
    cmp     0, d0
    bne     rfh_draw
    call    LcdSum, 0, 0
    mov     d0, (V_LCDSUM2)
    mov     (V_LCDSUM), d1
    cmp     d1, d0
    beq     rfh_ret
    mov     (V_NREDRAW), d0
    inc     d0
    mov     d0, (V_NREDRAW)
    mov     RD_ALL, d0
    mov     d0, (V_REDRAW)
rfh_draw:
    call    DrawScreen, 0, 0
    clr     d0
    mov     d0, (V_REDRAW)
    call    LcdSum, 0, 0
    mov     d0, (V_LCDSUM)
    mov     d0, (V_LCDSUM2)
rfh_ret:
    ret     [d2,d3,a2,a3], 0x30

# LcdSum -> d0: a checksum of 300 LCD pixels, every 32nd of every 16th row (Fletcher-like: the order
# matters, so a moved picture shows).
LcdSum:
    movm    [d2,d3,a2,a3], (sp)
    add     -0x20, sp
    clr     d2
    clr     d3
    mov     FB+4*FB_STRIDE+16, a2
    mov     15, d0
    mov     d0, (0x14, sp)
ls_row:
    mov     a2, a0
    mov     20, d1
ls_px:
    movhu   (a0), d0
    add     d0, d2
    add     d2, d3
    add     64, a0
    add     -1, d1
    bne     ls_px
    add     16*FB_STRIDE, a2
    mov     (0x14, sp), d0
    add     -1, d0
    mov     d0, (0x14, sp)
    bne     ls_row
    mov     d3, d0
    asl     16, d0
    add     d2, d0
    ret     [d2,d3,a2,a3], 0x30

# DrawScreen: the screen of the state we are in.
DrawScreen:
    movm    [d2,d3,a2,a3], (sp)
    add     -0x20, sp
    mov     1, d0
    mov     d0, (V_SCALE)
    mov     (V_STATE), d0
    cmp     ST_MENU, d0
    beq     dsc_menu
    cmp     ST_READ, d0
    beq     dsc_menu
    cmp     ST_FAIL, d0
    beq     dsc_fail
    cmp     ST_END, d0
    beq     dsc_ret
    call    DrawProgress, 0, 0
    bra     dsc_ret
dsc_menu:
    call    DrawMenu, 0, 0
    bra     dsc_ret
dsc_fail:
    call    DrawFail, 0, 0
dsc_ret:
    ret     [d2,d3,a2,a3], 0x30

# Title(a0 = the bar's right-hand text, or 0): the title bar.
Title:
    movm    [d2,d3,a2,a3], (sp)
    add     -0x20, sp
    mov     a0, a2
    mov     C_TITLE, d0
    call    SetColours, 0, 0
    clr     d0
    clr     d1
    mov     640, a0
    mov     TITLE_H, a1
    call    FillRect, 0, 0
    mov     C_TEXT, d0
    mov     d0, (V_FG)
    mov     2, d0
    mov     d0, (V_SCALE)
    mov     str_title, a0
    mov     8, d0
    mov     1, d1
    call    DrawText, 0, 0
    mov     1, d0
    mov     d0, (V_SCALE)
    cmp     0, a2
    beq     ti_ret
    mov     a2, a0
    mov     392, d0
    mov     8, d1
    call    DrawText, 0, 0
ti_ret:
    ret     [d2,d3,a2,a3], 0x30

# SetColours(d0 = background): V_BG = V_FG = d0 (FillRect draws in V_FG). Leaf.
SetColours:
    mov     d0, (V_BG)
    mov     d0, (V_FG)
    rets

# DrawProgress: while the menu looks for the panel and the programs.
DrawProgress:
    movm    [d2,d3,a2,a3], (sp)
    add     -0x20, sp
    mov     (V_REDRAW), d0
    btst    RD_ALL, d0
    beq     dpg_status
    mov     C_PANEL, d0
    call    SetColours, 0, 0
    clr     d0
    clr     d1
    mov     640, a0
    mov     240, a1
    call    FillRect, 0, 0
    mov     0, a0
    call    Title, 0, 0
dpg_status:
    mov     C_PANEL, d0
    call    SetColours, 0, 0
    clr     d0
    mov     56, d1
    mov     640, a0
    mov     48, a1
    call    FillRect, 0, 0
    mov     C_TEXT, d0
    mov     d0, (V_FG)
    mov     (V_STATE), d0
    mov     str_p_panel, a0
    cmp     ST_ROOT, d0
    bcs     dpg_line
    mov     str_p_root, a0
    cmp     ST_SCAN, d0
    bne     dpg_line
    mov     LINEBUF, a0             # "Looking into folder n of N: NAME"
    mov     str_p_scan, a1
    call    StrCpy, 0, 0
    mov     (V_SCANI), d0
    call    PutDec, 0, 0
    mov     str_p_of, a1
    call    StrCpy, 0, 0
    mov     (V_NCAND), d0
    call    PutDec, 0, 0
    mov     LINEBUF, a0
dpg_line:
    mov     16, d0
    mov     60, d1
    call    DrawText, 0, 0
    mov     (V_STATE), d0           # the folder just looked into
    cmp     ST_SCAN, d0
    bne     dpg_ret
    mov     (V_SCANI), d0
    cmp     0, d0
    beq     dpg_ret
    add     -1, d0
    call    RecAddr, 0, 0
    add     PR_NAME, a0
    mov     C_DIM, d0
    mov     d0, (V_FG)
    mov     16, d0
    mov     80, d1
    mov     76, a1
    call    DrawTextN, 0, 0
dpg_ret:
    ret     [d2,d3,a2,a3], 0x30

# DrawFail: why the menu cannot go on, and how it ends.
DrawFail:
    movm    [d2,d3,a2,a3], (sp)
    add     -0x20, sp
    mov     C_PANEL, d0
    call    SetColours, 0, 0
    clr     d0
    clr     d1
    mov     640, a0
    mov     240, a1
    call    FillRect, 0, 0
    mov     0, a0
    call    Title, 0, 0
    mov     C_PANEL, d0
    call    SetColours, 0, 0
    mov     C_TEXT, d0
    mov     d0, (V_FG)
    mov     str_f_head, a0
    mov     16, d0
    mov     52, d1
    call    DrawText, 0, 0
    mov     C_BAD, d0
    mov     d0, (V_FG)
    mov     (V_FAIL), a0
    mov     16, d0
    mov     76, d1
    mov     76, a1
    call    DrawTextN, 0, 0
    mov     C_TEXT, d0
    mov     d0, (V_FG)
    mov     str_f_exit, a0
    mov     (V_PANEL), d0
    cmp     0, d0
    bne     dfl_how
    mov     str_f_wait, a0
dfl_how:
    mov     16, d0
    mov     112, d1
    call    DrawText, 0, 0
    ret     [d2,d3,a2,a3], 0x30

# DrawMenu: the whole list screen: the title bar, five rows, the right buttons' labels.
DrawMenu:
    movm    [d2,d3,a2,a3], (sp)
    add     -0x20, sp
    mov     LINEBUF, a0             # "PAGE 1/2   7 PROGRAMS"
    mov     str_page, a1
    call    StrCpy, 0, 0
    mov     (V_TOP), d0
    clr     d1
    mov     d1, mdr
    mov     ROWS, d1
    divu    d1, d0
    inc     d0
    call    PutDec, 0, 0
    mov     0x2F, d0
    movbu   d0, (a0)
    inc     a0
    mov     (V_NPROG), d0
    add     ROWS-1, d0
    clr     d1
    mov     d1, mdr
    mov     ROWS, d1
    divu    d1, d0
    cmp     0, d0
    bne     dmn_pages
    inc     d0
dmn_pages:
    call    PutDec, 0, 0
    mov     str_spaces3, a1
    call    StrCpy, 0, 0
    mov     (V_NPROG), d0
    call    PutDec, 0, 0
    mov     str_programs, a1
    call    StrCpy, 0, 0
    mov     LINEBUF, a0
    call    Title, 0, 0
    clr     d2
dmn_row:
    mov     d2, d0
    call    DrawRow, 0, 0
    inc     d2
    cmp     ROWS, d2
    bcs     dmn_row
    call    DrawLabels, 0, 0
    ret     [d2,d3,a2,a3], 0x30

# DrawRow(d0 = row 0..ROWS-1): the program V_TOP + row, or what an empty list says.
DrawRow:
    movm    [d2,d3,a2,a3], (sp)
    add     -0x20, sp
    mov     d0, d2
    mov     ROW_H, d1               # d3 = the row's top
    mulu    d1, d0
    add     TITLE_H, d0
    mov     d0, d3
    mov     (V_TOP), d0             # 0x14(sp) = the program's index
    add     d2, d0
    mov     d0, (0x14, sp)
    mov     C_BG, d1                # the background: the selected one stands out
    mov     (V_NPROG), a0
    cmp     a0, d0
    bcc     drw_bg
    mov     (V_SEL), a0
    cmp     a0, d0
    bne     drw_bg
    mov     C_SEL, d1
drw_bg:
    mov     d1, d0
    mov     d0, (0x18, sp)
    call    SetColours, 0, 0
    clr     d0
    mov     d3, d1
    mov     LIST_W, a0
    mov     ROW_H-1, a1
    call    FillRect, 0, 0
    mov     C_LINE, d0              # the line under it
    mov     d0, (V_FG)
    clr     d0
    mov     d3, d1
    add     ROW_H-1, d1
    mov     LIST_W, a0
    mov     1, a1
    call    FillRect, 0, 0
    mov     (0x18, sp), d0
    call    SetColours, 0, 0
    mov     (0x14, sp), d0
    mov     (V_NPROG), d1
    cmp     d1, d0
    bcs     drw_prog
    cmp     0, d1                   # an empty list: say so on the first two rows
    bne     drw_ret
    cmp     0, d2
    bne     drw_empty2
    mov     C_WARN, d0
    mov     d0, (V_FG)
    mov     str_e_none, a0
    mov     12, d0
    mov     d3, d1
    add     6, d1
    call    DrawText, 0, 0
    mov     C_DIM, d0
    mov     d0, (V_FG)
    mov     str_e_how, a0
    mov     12, d0
    mov     d3, d1
    add     23, d1
    call    DrawText, 0, 0
    bra     drw_ret
drw_empty2:
    cmp     1, d2
    bne     drw_ret
    mov     C_DIM, d0
    mov     d0, (V_FG)
    mov     str_e_how2, a0
    mov     12, d0
    mov     d3, d1
    add     6, d1
    call    DrawText, 0, 0
    bra     drw_ret
drw_prog:
    asl     2, d0                   # a2 = the record
    mov     ORDER, a0
    add     d0, a0
    mov     (a0), a2
    mov     (PR_ICONP, a2), a0      # the icon
    mov     8, d0
    mov     d3, d1
    add     ICON_DY, d1
    call    DrawIcon, 0, 0
    mov     C_TEXT, d0              # the name
    mov     d0, (V_FG)
    mov     a2, a0
    add     PR_NAME, a0
    mov     52, d0
    mov     d3, d1
    add     5, d1
    mov     NAME_CHARS, a1
    call    DrawTextN, 0, 0
    mov     (V_MSGREC), d0          # under it: the message about it, or where it is
    cmp     a2, d0
    bne     drw_where
    mov     (V_MSG), d0
    cmp     0, d0
    beq     drw_where
    mov     (V_MSGCOL), d0
    mov     d0, (V_FG)
    mov     (V_MSG), a0
    bra     drw_line2
drw_where:
    mov     C_DIM, d0
    mov     d0, (V_FG)
    mov     a2, a0
    call    WhereLine, 0, 0         # a0 = LINEBUF
drw_line2:
    mov     52, d0
    mov     d3, d1
    add     23, d1
    mov     NAME_CHARS, a1
    call    DrawTextN, 0, 0
drw_ret:
    ret     [d2,d3,a2,a3], 0x30

# WhereLine(a0 = record) -> a0 = LINEBUF: "C:\AW\KN7APP.BIN  15260 bytes", and a note when its manifest
# or icon could not be used.
WhereLine:
    movm    [d2,d3,a2,a3], (sp)
    add     -0x20, sp
    mov     a0, a2
    mov     LINEBUF, a0
    mov     str_croot, a1
    call    StrCpy, 0, 0
    mov     a2, a1
    add     PR_DIR, a1
    call    StrCpy, 0, 0
    mov     str_w_app, a1
    call    StrCpy, 0, 0
    mov     (PR_APPSZ, a2), d0
    call    PutDec, 0, 0
    mov     str_w_bytes, a1
    call    StrCpy, 0, 0
    mov     (PR_FLAGS, a2), d2
    mov     str_w_noman, a1
    btst    PF_MANIFEST, d2
    beq     wl_note
    mov     str_w_manbad, a1
    btst    PF_MANBAD, d2
    bne     wl_note
    mov     str_w_iconbad, a1
    btst    PF_ICONBAD, d2
    beq     wl_ret
wl_note:
    call    StrCpy, 0, 0
wl_ret:
    mov     LINEBUF, a0
    ret     [d2,d3,a2,a3], 0x30

# DrawLabels: the right buttons: LCDR 1 PAGE UP and LCDR 2 PAGE DOWN when there is a page that way, LCDR 4
# LEAVE, LCDR 5 RUN (WAIT while a program is read and checked).
DrawLabels:
    movm    [d2,d3,a2,a3], (sp)
    add     -0x20, sp
    mov     C_BG, d0
    call    SetColours, 0, 0
    mov     LIST_W, d0
    mov     TITLE_H, d1
    mov     640-LIST_W, a0
    mov     240-TITLE_H, a1
    call    FillRect, 0, 0
    mov     C_LINE, d0
    mov     d0, (V_FG)
    mov     LIST_W, d0
    mov     TITLE_H, d1
    mov     1, a0
    mov     240-TITLE_H, a1
    call    FillRect, 0, 0
    mov     (V_TOP), d0             # LCDR 1
    cmp     0, d0
    beq     dl_r2
    mov     str_l_pgup, a0
    clr     d0
    mov     C_LABEL, d1
    call    Label, 0, 0
dl_r2:
    mov     (V_TOP), d0             # LCDR 2
    add     ROWS, d0
    mov     (V_NPROG), d1
    cmp     d1, d0
    bcc     dl_r4
    mov     str_l_pgdn, a0
    mov     1, d0
    mov     C_LABEL, d1
    call    Label, 0, 0
dl_r4:
    mov     str_l_leave, a0         # LCDR 4
    mov     3, d0
    mov     C_LABEL, d1
    call    Label, 0, 0
    mov     (V_NPROG), d0           # LCDR 5
    cmp     0, d0
    beq     dl_ret
    mov     str_l_run, a0
    mov     (V_STATE), d0
    cmp     ST_READ, d0
    bne     dl_r5
    mov     str_l_wait, a0
dl_r5:
    mov     4, d0
    mov     C_RUN, d1
    call    Label, 0, 0
dl_ret:
    ret     [d2,d3,a2,a3], 0x30

# Label(a0 = text, d0 = row 0..4, d1 = colour): a button's label box on that row, by the right edge, with
# the firmware's small marker pointing at the button.
Label:
    movm    [d2,d3,a2,a3], (sp)
    add     -0x20, sp
    mov     a0, a2
    mov     d1, d2
    mov     ROW_H, d1
    mulu    d1, d0
    add     TITLE_H, d0
    mov     d0, d3                  # the row's top
    mov     d2, d0
    call    SetColours, 0, 0
    mov     LABEL_X, d0
    mov     d3, d1
    add     6, d1
    mov     LABEL_W, a0
    mov     ROW_H-12, a1
    call    FillRect, 0, 0
    mov     C_MARK, d0
    mov     d0, (V_FG)
    mov     640-4, d0
    mov     d3, d1
    add     MARK_DY, d1
    mov     4, a0
    mov     10, a1
    call    FillRect, 0, 0
    mov     C_TEXT, d0
    mov     d0, (V_FG)
    mov     a2, a0
    mov     LABEL_X+8, d0
    mov     d3, d1
    add     TEXT_DY, d1
    mov     13, a1
    call    DrawTextN, 0, 0
    ret     [d2,d3,a2,a3], 0x30

# ================================================================================================
# Drawing primitives: in V_FG on V_BG, the text at V_SCALE (1 or 2), the 8x13 font of the loader.

# FillRect(d0 = x, d1 = y, a0 = width, a1 = height) in V_FG; two pixels per store when x and the width
# are even.
FillRect:
    movm    [d2,d3,a2,a3], (sp)
    add     -0x20, sp
    mov     d0, (0x14, sp)
    mov     d1, d2
    mov     FB_STRIDE, d3
    mulu    d3, d2
    add     d0, d0
    add     d0, d2
    mov     FB, a2
    add     d2, a2
    mov     (V_FG), d3
    cmp     0, a0
    beq     fr_ret
    cmp     0, a1
    beq     fr_ret
    mov     (0x14, sp), d0
    mov     a0, d1
    or      d1, d0
    btst    1, d0
    bne     fr_row16
    mov     d3, d0                  # two pixels a store
    asl     16, d0
    or      d0, d3
    mov     a0, d0
    lsr     1, d0
    mov     d0, a0
fr_row32:
    mov     a2, a3
    mov     a0, d2
fr_px32:
    mov     d3, (a3)
    add     4, a3
    add     -1, d2
    bne     fr_px32
    add     FB_STRIDE, a2
    add     -1, a1
    cmp     0, a1
    bne     fr_row32
    bra     fr_ret
fr_row16:
    mov     a2, a3
    mov     a0, d2
fr_px16:
    movhu   d3, (a3)
    add     2, a3
    add     -1, d2
    bne     fr_px16
    add     FB_STRIDE, a2
    add     -1, a1
    cmp     0, a1
    bne     fr_row16
fr_ret:
    ret     [d2,d3,a2,a3], 0x30

# DrawIcon(a0 = ICON_W x ICON_W RGB565 pixels, 4-aligned, d0 = x, even, d1 = y).
DrawIcon:
    movm    [d2,d3,a2,a3], (sp)
    add     -0x20, sp
    mov     a0, a3
    mov     d1, d2
    mov     FB_STRIDE, d3
    mulu    d3, d2
    add     d0, d0
    add     d0, d2
    mov     FB, a2
    add     d2, a2
    mov     ICON_W, d2
di_row:
    mov     a2, a0
    mov     ICON_W/2, d3
di_px:
    mov     (a3), d0
    mov     d0, (a0)
    add     4, a3
    add     4, a0
    add     -1, d3
    bne     di_px
    add     FB_STRIDE, a2
    add     -1, d2
    bne     di_row
    ret     [d2,d3,a2,a3], 0x30

# DrawText(a0 = text, d0 = x, d1 = y) -> d0 = x after; DrawTextN the same with at most a1 characters.
DrawText:
    mov     255, a1
DrawTextN:
    movm    [d2,d3,a2,a3], (sp)
    add     -0x20, sp
    mov     a0, a2
    mov     d0, d2
    mov     d1, d3
    mov     a1, (0x14, sp)
dt_char:
    movbu   (a2), d0
    cmp     0, d0
    beq     dt_done
    mov     (0x14, sp), d1
    cmp     0, d1
    beq     dt_done
    add     -1, d1
    mov     d1, (0x14, sp)
    inc     a2
    mov     d2, d1
    mov     d3, a1
    call    DrawChar, 0, 0
    mov     (V_SCALE), d0
    asl     3, d0
    add     d0, d2
    bra     dt_char
dt_done:
    mov     d2, d0
    ret     [d2,d3,a2,a3], 0x30

DrawChar:                           # d0 = character, d1 = x, a1 = y (loader.s DrawChar)
    movm    [d2,d3,a2,a3], (sp)
    add     -0x20, sp
    cmp     0x20, d0
    bcs     dc_other
    cmp     0x7F, d0
    bcs     dc_ok
dc_other:
    mov     0x3F, d0                # '?'
dc_ok:
    add     -0x20, d0
    mov     13, d2
    mulu    d2, d0
    mov     Font8x13, a3
    add     d0, a3
    mov     a1, d2
    mov     FB_STRIDE, d3
    mulu    d3, d2
    add     d1, d1
    add     d1, d2
    mov     FB, a2
    add     d2, a2
    mov     13, d0
    mov     d0, (0x14, sp)
dc_row:
    movbu   (a3), d2
    inc     a3
    mov     (V_SCALE), d0
    mov     d0, (0x18, sp)
dc_rep:
    mov     a2, a0
    mov     0x80, d3
dc_px:
    mov     (V_BG), d1
    mov     d2, d0
    and     d3, d0
    beq     dc_put
    mov     (V_FG), d1
dc_put:
    movhu   d1, (a0)
    add     2, a0
    mov     (V_SCALE), d0
    cmp     2, d0
    bne     dc_px1
    movhu   d1, (a0)
    add     2, a0
dc_px1:
    lsr     1, d3
    bne     dc_px
    add     FB_STRIDE, a2
    mov     (0x18, sp), d0
    add     -1, d0
    mov     d0, (0x18, sp)
    bne     dc_rep
    mov     (0x14, sp), d0
    add     -1, d0
    mov     d0, (0x14, sp)
    bne     dc_row
    ret     [d2,d3,a2,a3], 0x30
