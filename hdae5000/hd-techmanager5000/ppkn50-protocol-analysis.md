# ppkn50.dll Parallel Port Protocol Analysis

This document describes the parallel port communication protocol between the HD-TechManager5000 PC software (ppkn50.dll) and the HDAE5000 expansion board, as reverse-engineered from the DLL disassembly.

## Physical Interface

### PC Parallel Port Registers

| Port Address | Register | Direction | Function |
|--------------|----------|-----------|----------|
| base+0 (0x378) | Data | Bidirectional | 8-bit data byte |
| base+1 (0x379) | Status | Input | Status signals from HDAE5000 |
| base+2 (0x37A) | Control | Output | Control signals to HDAE5000 |

### HDAE5000 PPI Registers (Intel 8255)

| Address | Port | Direction | Function |
|---------|------|-----------|----------|
| 0x160000 | Port A | Bidirectional | Data byte to/from PC |
| 0x160002 | Port B | Input | Status from PC |
| 0x160004 | Port C | Output | Control signals to PC |
| 0x160006 | Control | Write | PPI mode configuration |

## Signal Mapping

### Status Port (base+1) Bit Definitions

| Bit | Name | Description |
|-----|------|-------------|
| 7 | BUSY | Inverted by PC; 0=HDAE5000 busy, 1=ready |
| 6 | ACK | Acknowledge signal |
| 5 | PAPER_OUT | Not used |
| 4 | SELECT | HDAE5000 online indicator |
| 3 | ERROR | Error condition |
| 2:0 | - | Reserved |

**Note:** Bit 7 (BUSY) is inverted in hardware by the PC parallel port. The ppkn50.dll XORs with 0x80 after reading to compensate.

### Control Port (base+2) Bit Definitions

| Bit | Name | Description |
|-----|------|-------------|
| 7:4 | - | Reserved |
| 3 | SELECT_IN | Select printer |
| 2 | INIT | Initialize/reset |
| 1 | AUTOFEED | Auto linefeed / Strobe acknowledge |
| 0 | STROBE | Data strobe signal |

## Low-Level I/O Primitives

### Read Status Port (0x10001160)

```c
uint8_t ReadStatusPort(uint16_t base_port) {
    cli();                          // Disable interrupts
    uint8_t status = inb(base_port + 1);  // Read status
    status ^= 0x80;                 // Invert BUSY bit
    sti();                          // Enable interrupts
    return status;
}
```

### Strobe Pulse (0x10001180)

```c
void StrobePulse(uint16_t base_port) {
    cli();
    uint8_t ctrl = inb(base_port + 2);
    outb(base_port + 2, (ctrl & 0xFC) | 0x08);  // Set bit 3
    delay(50);  // ~50 iterations
    ctrl = inb(base_port + 2);
    outb(base_port + 2, ctrl & 0xF7);           // Clear bit 3
    sti();
    delay(50);
}
```

### Set Control Bit 3 (0x100011C0)

```c
void SetControlBit3(uint16_t base_port) {
    cli();
    uint8_t ctrl = inb(base_port + 2);
    outb(base_port + 2, ctrl | 0x08);
    sti();
}
```

## Byte Transfer Protocol

### Send Byte to HDAE5000 (0x100011E0)

1. Clear control bits for output mode: `ctrl &= 0x5E`
2. Write data byte to data port (base+0)
3. Set strobe (control bit 1): `ctrl |= 0x02`
4. Wait for acknowledge (status bit 7 = 0) with timeout
5. Clear strobe: `ctrl &= 0xFD`
6. Wait for acknowledge release (status bit 7 = 1) with timeout
7. Return success/failure

```
PC                          HDAE5000
 |                              |
 |-- Write Data to Port A ----->|
 |-- Assert Strobe (bit 1) ---->|
 |                              |
 |<---- BUSY goes LOW ----------|  (data received)
 |                              |
 |-- Deassert Strobe ---------->|
 |                              |
 |<---- BUSY goes HIGH ---------|  (ready for next)
 |                              |
```

### Receive Byte from HDAE5000 (0x10001360)

1. Set control bits for input mode: `ctrl |= 0xA1`
2. Wait for data ready (status bit 7 = 0) with timeout
3. Set acknowledge (control bit 1): `ctrl |= 0x02`
4. Read data byte from data port (base+0)
5. Wait for data removed (status bit 7 = 1) with timeout
6. Return data byte or timeout error

```
PC                          HDAE5000
 |                              |
 |<---- BUSY goes LOW ----------|  (data available)
 |                              |
 |-- Read Data from Port A ---->|
 |-- Assert ACK (bit 1) ------->|
 |                              |
 |<---- BUSY goes HIGH ---------|  (ready for next)
 |                              |
 |-- Deassert ACK ------------->|
 |                              |
```

## Command Protocol

### Connection Test (0x100021E0)

Tests if HDAE5000 is connected and responding:

1. Read status port
2. Check bit 3 = 0 (no error)
3. Check bit 4 = 1 (online)
4. Retry up to 5 times with 1000ms delay
5. Return 1 if connected, 0 if not

### Send Command (0x10002810)

Core function for sending protocol commands:

1. Check DLL initialized
2. Call OpenThePortNumber to select LPT port
3. Send strobe pulse to get attention
4. Call connection test (0x100021E0)
5. If connected, send command byte (first byte of buffer at 0x10012400)
6. Return success/failure

## PPORT Command Codes

Corrected 2026-10-31 (notes/open4-kn5000-b/hdae/README.md, kn5000-qnf / kn5000-t8n).  The command byte is
packet byte 0, in **decimal** 1-20; the HD-AE5000 handler names are the firmware's status records
(`HDAE5000_PPORT_Cmd01_SendInfosAboutHd` ... `Cmd20_SendXapFileFlash`).  The earlier table here had 02 as a
connection test and wrote the decimal commands 10, 11, 16, 17, 18 as 0x10 ... 0x18.

| Command | HD-AE5000 handler           | Sent by (ppkn50.dll export)                                          |
|---------|-----------------------------|----------------------------------------------------------------------|
| 1       | `Cmd01_SendInfosAboutHd`    | `PP50TestTheKNPP`                                                    |
| 2       | `Cmd02_ExitPport`           | `PP50EscapeKeyboardToPlay`                                           |
| 3       | `Cmd03_ReadFsbFromHd`       | `PP50ReadFsbFromKnHdToKnMem`                                         |
| 4       | `Cmd04_SendFsbToPc`         | `PP50SendFsbFromKnMemToPC`                                           |
| 5       | `Cmd05_RcvFsbFromPc`        | `PP50SendFsbFromPCToKnMem`                                           |
| 6       | `Cmd06_WriteFsbToHd`        | `PP50WriteFsbFromKnMemToKnHd`, `PP50SendSeveralFileDirectToKNHD`     |
| 7       | `Cmd07_LoadHdToMemory`      | `PP50LoadFileFromKnHdToKnMem`                                        |
| 8       | `Cmd08_SendDataToPc`        | `PP50LoadFileFromKnHdToPC`                                           |
| 9       | `Cmd09_SendFilesToPc`       | `PP50LoadFileFromKnHdDirectToPC`                                     |
| 10      | `Cmd10_RcvDataFromPc`       | `PP50SendFileFromPCToKNMem`, `PP50SendFileFromPCToKNHD`              |
| 11      | `Cmd11_SaveMemoryToHd`      | `PP50SaveFileFromKNMemToKNHd`                                        |
| 12      | `Cmd12_Nothing`             | -                                                                    |
| 13      | `Cmd13_RcvDataFromPc`       | `PP50SaveFileFromPCDirectToKNHd`, `PP50SavePCMemDirectToKNHd`, `PP50SendSeveralFileDirectToKNHD` |
| 14      | `Cmd14_SendInfosToPc`       | `PP50TestSongInfoFromKnHd`                                           |
| 15      | `Cmd15_Nothing`             | -                                                                    |
| 16      | `Cmd16_DeleteFiles`         | `PP50DeleteFileOnKnHd`                                               |
| 17      | `Cmd17_FormatHd`            | `PP50FormatTheKn50HardDisk`                                          |
| 18      | `Cmd18_SwitchHdMotorOff`    | `PP50TurnOffTheKn50HdMotor`                                          |
| 19      | `Cmd19_Nothing`             | -                                                                    |
| 20      | `Cmd20_SendXapFileFlash`    | - (no export of this DLL sends it)                                   |

Measured with `notes/open4-kn5000-b/hdae/probes/ppkn50_command_map.py` (the `push <command>; push <port>;
call 0x10002810` before each transaction).  `PP50InitializeTheDll`, `PP50OpenThePortNumber`,
`PP50CloseThePort`, `PP50TestParallelModus`, `AskTheConvMem`, `OpenThisFile` and `SaveThisFile` send no command.
The reply's byte 255 (DLL 0x100121BF) is the HD-AE5000's failure flag (`HDAE5000_PPORT_FlagPacketError`); the
exports that read it return -5 when it is set.

## Timeout Values

- Byte transfer timeout: 10,000ms (0x2710)
- Polling iterations: 512 (0x200) before checking time
- Connection test retries: 5 times
- Connection test delay: 1000ms (0x3E8)

## Data Buffer Addresses

Key internal DLL data buffers:

| Address | Size | Description |
|---------|------|-------------|
| 0x10012020 | - | Port status |
| 0x100120A0 | - | Window handle storage |
| 0x100120BC | 1 | Last error code |
| 0x100120BE | 2 | Current port base address |
| 0x100120C0 | 256 | FSB receive buffer |
| 0x10012400 | 256 | Command/data buffer |

## Error Codes

Return values from DLL functions:

| Code | Meaning |
|------|---------|
| 0 | Success |
| -1 (0xFFFFFFFF) | DLL not initialized |
| -2 (0xFFFFFFFE) | Port not open / connection failed |
| -3 (0xFFFFFFFD) | Handshake timeout |
| -4 (0xFFFFFFFC) | Transfer error |
| -5 (0xFFFFFFFB) | Port busy |
| -10 (0xFFFFFFF6) | Escape pressed |
| -20 (0xFFFFFFEC) | Invalid port number |
| -40 (0xFFFFFFD8) | Invalid filename |

## Protocol State Machine

```
IDLE
  |
  v
[PC sends strobe pulse]
  |
  v
HDAE5000 sees strobe, prepares for command
  |
  v
[PC sends command byte]
  |
  v
HDAE5000 processes command, may request/send data
  |
  v
[PC sends/receives data bytes as needed]
  |
  v
Operation complete, return to IDLE
```

## Correlation with HDAE5000 Firmware

The PPI handler in the HDAE5000 firmware (at 0x160000 area) receives these commands and dispatches to the appropriate handlers. The firmware command table at the PPI handler matches the command codes documented above.

See also:
- `hdae5000/hd-ae5000_v2_06i.asm` - HDAE5000 firmware disassembly
- `../technics-docs/hdae5000-disk-interface.md` - Disk interface documentation

## References

- Intel 8255 PPI Datasheet
- IEEE 1284 Parallel Port Standard
- ppkn50.dll disassembly (ppkn50.disasm)
