# Probes of lane kn5000-a (2026-10-31)

| script                    | question it answers                                                                   | run (repository root)                                               |
|---------------------------|---------------------------------------------------------------------------------------|---------------------------------------------------------------------|
| `fontid_table_writers.py` | Does any code write FontIDProc's font-name list in RAM (FONTID_NAME_TABLE) after boot? | `make all`, then `python3 notes/kn5000-a-2026-10-31/probes/fontid_table_writers.py` |
| `sm_pd0_net.py`           | Which board signal does the main CPU's Port D bit 0 drive (service manual p. 32)?      | `python3 notes/kn5000-a-2026-10-31/probes/sm_pd0_net.py [PDF] [OUTDIR]` |

Each docstring records the signal read and the result of the 2026-10-31 run.
