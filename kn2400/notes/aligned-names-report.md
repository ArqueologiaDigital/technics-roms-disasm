# kn2400: KN7000 941 names carried along aligned call sites and RAM operands

- routine names carried: 228, 46 of them by mapped operands (rounds: 178, 30, 19, 1, 0, 0, 0, 0, 0, 0, 0)
- routine pairs both images leave unnamed, accepted by the same rule as anchors: 3110
- accepted pairs that a later round gave a rival: 0
- audit, callees both images name: 650 right, 3 wrong
- audit, same-body routines B names already, picked by mapped operands: 190 right, 0 wrong
- RAM address pairs: 2258 (of 2266 B addresses seen in aligned operands); named from A: 8; RAM audit 14 right, 0 wrong
- not carried (last reason per call-site pair):
  -   3110 A's callee is unnamed too (the pair anchors the next round)
  -    189 A's callee is unnamed too
  -     22 one aligned call site only
  -     11 body skeleton similarity below 0.6
  -     10 the bodies' callees or strings disagree

Audit, wrong pairs (B name, B address, A name, A address, call sites):

- `AcRcVolumeProc` 0x48657DCA / `AcMonitorOnProc` 0x484959ED (1)
- `FxCategoryGet` 0x4863DC81 / `DspPresetKeyKind` 0x48412BD8 (2)
- `TgGlobalRegWriteB` 0x5013CE27 / `TgGlobalRegWriteBoth` 0x4C037008 (8)
