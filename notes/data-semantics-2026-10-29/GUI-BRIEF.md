# GUI addendum (owner, 2026-10-29), on top of COMMON-BRIEF.md

The owner's words: "The entire set of GUI data structures must also be semantically described. One should be
able to easily grasp all the menus, submenus, screens, GUI widgets, etc, just by glancing at the source code.
Use macros or high-level C data structures to represent them cleanly and effectively."

What "at a glance" means, concretely (your acceptance test):
- A reader opening one screen's source sees: the screen's name and title, its class by NAME, its geometry as
  named x/y/w/h, every child widget nested or listed under it by NAME (not by numeric index), each widget's
  class by name, label strings inline, the handler/callback procedures by symbol name, the bitmaps/icons by
  label, the event codes by EVT_* / MT_* name, and which menu/button leads to it and where EXIT goes.
- No raw class ids (0x0160xxxx), no numeric object indices for parent/child/sibling links, no numeric ROM
  addresses, no `field_XX` names where the firmware's own propname/propdata (class property tables) or the code
  that reads the field gives a name. Fields still unknown keep a neutral name AND a TODO with what was tried.
- Links between objects (super/sub/next/prev, parent/child) must be spelled with symbolic object names; prefer a
  representation where the tree is generated FROM the nesting (macros or C initializers that compute the indices),
  so the hierarchy is visible in the indentation itself. The bytes must stay identical (gate).
- Provide an index: a generated, committed Markdown "menu map" (screens -> children -> transitions) produced by
  a committed script from the source, so the whole GUI can be browsed. Regenerate it in the gate or a make target
  and check it is up to date.
- Add a small GUI-readability census script (or extend data_incbin_census.py with a separate report) that counts,
  per tree: raw numeric class ids, numeric object links, numeric code/data addresses, unnamed fields. Report the
  before/after numbers (commit the script; numbers in your notes).
- C is preferred where the tree already compiles C byte-exact (KN5000/HD-AE5000: clang -> generated .bin ->
  .incbin, see v10/maincpu/ui_widgets/ and the Makefile rules that build them); assembler macros elsewhere.
