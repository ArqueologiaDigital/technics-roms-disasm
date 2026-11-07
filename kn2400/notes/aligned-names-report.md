# kn2400: KN7000 941 names carried along aligned call sites and RAM operands

- routine names carried: 1649, 725 of them by mapped operands (rounds: 1191, 350, 78, 13, 9, 1, 2, 5, 0, 0, 0)
- routine pairs both images leave unnamed, accepted by the same rule as anchors: 2380
- accepted pairs that a later round gave a rival: 0
- audit, callees both images name: 1086 right, 3 wrong (of them paired by operand pointers alone: 20 right, 0 wrong; pairs by table words alone are audited below)
- paired data tables: {'audit: named word, table passes without it, right': 2068, 'audit: named word, table passes without it, wrong': 5, 'tables refused (named words disagree, or too few agree)': 2919, 'tables used': 126}
- routine names carried on pointer supports alone (an operand or a table word): 21
- audit, same-body routines B names already, picked by mapped operands: 518 right, 0 wrong
- RAM address pairs: 3362: 2535 by aligned operands (of 2547 B addresses seen in them), 827 between two of one delta (runs; the premise on the voted pairs: 2143 right, 2 wrong); named from A: 9; RAM audit 15 right, 0 wrong
- not carried (last reason per call-site pair):
  -   2380 A's callee is unnamed too (the pair anchors the next round)
  -    166 A's callee is unnamed too
  -     68 one aligned call site only
  -     15 body skeleton similarity below 0.6
  -     12 the bodies' callees or strings disagree

Audit, wrong pairs (B name, B address, A name, A address, call sites):

- `AcRcVolumeProc` 0x48657DCA / `AcMonitorOnProc` 0x484959ED (1)
- `FxCategoryGet` 0x4863DC81 / `DspPresetKeyKind` 0x48412BD8 (2)
- `TgGlobalRegWriteB` 0x5013CE27 / `TgGlobalRegWriteBoth` 0x4C037008 (8)
