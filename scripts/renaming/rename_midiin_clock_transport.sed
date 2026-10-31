# MidiThru_Enable / MidiThru_Disable set / clear bit 6 of 0xb7e2, which makes MIDI_SYSTEM_MESSAGE_HANDLER
# ignore received clock and transport bytes (0xf8..0xfc); nothing there is MIDI thru (open item
# T-kn5000-v10-todo-the-name).
s/\bMidiThru_Enable\b/MidiIn_IgnoreClockTransport/g
s/\bMidiThru_Disable\b/MidiIn_AcceptClockTransport/g
s/and turns MIDI thru off$/and accepts received MIDI clock and transport again/
s/^; (MidiThru_Disable, tail jump)\.$/; (MidiIn_AcceptClockTransport, tail jump)./
s/^; tables are initialised\.  TODO: the name is not supported by the code; nothing here is MIDI thru\.$/; tables are initialised./
