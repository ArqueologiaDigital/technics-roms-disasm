# Chord types 29 and 30 voice like 12 and 28 (a voicing record holds four notes) but are recognised from
# held sets with one more tension: 29 from 0 2 4 8 10 (9(#5)), 30 from 0 1 4 9 10 (7(b9,13)).
# notes/open4-kn5000-b/engine/probes/chord_table_check.py --types shows the held sets.
s/; type 29: 7(#5)$/; type 29: 9(#5), voiced as 7(#5)/
s/; type 30: 7(13)$/; type 30: 7(b9,13), voiced as 7(13)/
