# (c) 2026 Felipe Correa da Silva Sanches <juca@members.fsf.org>
# Licensed under the terms of the GNU General Public License v3 or later
#
# kn_panel_extra.inc -- the two panel-memory macros of floppy/tools/kn_panel.inc that
# kn7000/src/include/panel_memory.inc does not have, for the lines floppy/tools/kd/kn_panel.py
# writes: a record whose tag / length no PMR_* macro covers, and the end mark.
.macro kp_tlv tag, len
	.byte	\tag, \len
.endm
.macro kp_end
	.byte	0xff, 0xff
.endm
