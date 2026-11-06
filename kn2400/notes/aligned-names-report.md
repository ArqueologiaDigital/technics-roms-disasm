# kn2400: KN7000 941 names carried along aligned call sites and RAM operands

- routine names carried: 249, 61 of them by mapped operands (rounds: 195, 36, 17, 0, 0, 0, 1, 0, 0, 0, 0)
- routine pairs both images leave unnamed, accepted by the same rule as anchors: 3186
- accepted pairs that a later round gave a rival: 0
- audit, callees both images name: 674 right, 3 wrong (of them paired by operand pointers alone: 19 right, 0 wrong; pairs by table words alone are audited below)
- paired data tables: {'audit: named word, table passes without it, right': 1684, 'audit: named word, table passes without it, wrong': 5, 'tables refused (named words disagree, or too few agree)': 2807, 'tables used': 90}
- routine names carried on pointer supports alone (an operand or a table word): 6
- audit, same-body routines B names already, picked by mapped operands: 201 right, 0 wrong
- RAM address pairs: 3147: 2284 by aligned operands (of 2292 B addresses seen in them), 863 between two of one delta (runs; the premise on the voted pairs: 1900 right, 2 wrong); named from A: 8; RAM audit 15 right, 0 wrong
- not carried (last reason per call-site pair):
  -   3186 A's callee is unnamed too (the pair anchors the next round)
  -    202 A's callee is unnamed too
  -     22 one aligned call site only
  -     11 the bodies' callees or strings disagree
  -     11 body skeleton similarity below 0.6

Audit, wrong pairs (B name, B address, A name, A address, call sites):

- `AcRcVolumeProc` 0x48657DCA / `AcMonitorOnProc` 0x484959ED (1)
- `FxCategoryGet` 0x4863DC81 / `DspPresetKeyKind` 0x48412BD8 (2)
- `TgGlobalRegWriteB` 0x5013CE27 / `TgGlobalRegWriteBoth` 0x4C037008 (8)
