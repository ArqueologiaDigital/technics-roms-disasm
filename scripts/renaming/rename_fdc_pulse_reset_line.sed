# Port D bit 0 is the FDC's hardware reset line FDCRST (service manual p. 32: IC5 pin 12 PD0 -> FDCRST);
# open item T-kn5000-tabledata-todo-identify-what.
s/\bReset_Floppy_Disk_Controller\b/FDC_PulseResetLine/g
s/\bBoot_PulsePD0\b/FDC_PulseResetLine/g
