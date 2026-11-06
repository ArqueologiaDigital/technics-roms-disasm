# lane open12/kn5000-naka2: comments that quoted the audio state words by address now use their names
# (AUDIO_SEQ_TRACK_FLAGS 0xc598, AUDIO_VOICE_CHANGES 0xc59a, AUDIO_STATE_CHANGES 0xc59c;
# AUDIO_CONFIG_FLAGS 0xc596 and AUDIO_CONFIG_UPDATE 0xc594 from wave 11).  Comment lines only.
/^;/s/the status word 0xc598 (Audio_CheckInitStatus)/the status word AUDIO_SEQ_TRACK_FLAGS (Audio_CheckInitStatus)/
/^;/s/bits 0 and 8 of 0xc59c set/bits 0 and 8 of AUDIO_STATE_CHANGES set/
/^;/s/the change mask 0xc59c)/the change mask AUDIO_STATE_CHANGES)/
/^;/s/(0xC596, 0xC59A, 0xC5A0) and sets 0xC594 bit 2/(AUDIO_CONFIG_FLAGS, AUDIO_VOICE_CHANGES, 0xC5A0) and sets AUDIO_CONFIG_UPDATE bit 2/
/^;/s/(0xC59C bit 3, /(AUDIO_STATE_CHANGES bit 3, /
/^;/s/0xC598 \/ 0xC596 \/ 0xCEDE flags/AUDIO_SEQ_TRACK_FLAGS \/ AUDIO_CONFIG_FLAGS \/ 0xCEDE flags/
