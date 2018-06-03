@echo off
TASM disasm.asm
TLINK disasm.obj
TASM test.asm
TLINK.EXE /t test.obj
