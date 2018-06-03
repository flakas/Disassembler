# Disassembler

This is a toy disassembler for 16-bit Intel 8087 processor, made as an exercise for Computer Architecture class at Vilnius University.
It recognizes only a subset of available instructions in `.COM` executables.

## Running it

At this time I'm having trouble getting it to run again. Initially it was run on some different emulation environment, so that might affect things, but if you would like to give it a shot under DosBox, here's how you could do so.

To run it you have to install:

- DosBox emulator ([Downloads](https://www.dosbox.com/download.php?main=1))
- Borland Turbo Assembler ([Downloads](http://trimtab.ca/2010/tech/tasm-5-intel-8086-turbo-assembler-download/))

### DosBox startup

You can execute them manually each time you run DosBox, but I found it easier to add these commands to `~/.dosbox/dosbox-0.74.conf` at the end of the file:

```
MOUNT C ~/Downloads/tasm/tasm/BIN
MOUNT D ~/code/Disassembler/src
SET PATH=Z:\;C:\
```

Make sure to replace `~/Downloads/tasm/tasm/BIN` with where you actually put Turbo Assembler binaries, and `~/code/Disassembler/src` with where you cloned this repository.

### Building and running

Once in DosBox:

1. `build.bat` to build and link both disassembler and the test program
2. `disasm test.com disassembled.txt` to perform disassembly of the test program. The end result should look like `test.txt`

## How it works

It essentially is a primitive parser. It will read program bytes one by one, looking up the first byte in the opcode on the opcode table in `src/opcodes.asm`.
Once it finds a match, it will try to match the next few bytes based on signature of the instruction it found (e.g. `ADD(Register, Memory)` instruction), writing human-readable equivalents to file.
