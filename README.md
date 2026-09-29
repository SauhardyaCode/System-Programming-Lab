# 8086 MASM Lab Assignment Solutions

This folder contains simple and clean 8086 Assembly programs for the 5 assignment problems.

## Files
- `prob1.asm`: Boot-level password verification system using BIOS `INT 16h`.
- `prob2.asm`: Command-line shell emulator (`DIR`, `TYPE`, `COPY`, `EXIT`).
- `prob3.asm`: FCFS disk scheduling algorithm (calculates total head movement).
- `prob4.asm`: Sorts an array of N numbers using Bubble Sort.
- `prob5.asm`: Checks balanced brackets `()`, `{}`, `[]` using a simulated stack.

## How to Run in DOSBox
1. Open DOSBox.
2. Mount this directory:
   ```dos
   mount c c:\Users\WIN11\letuscode\MASM Codes
   c:
   ```
3. Assemble and Link any file (for example `prob1.asm`):
   ```dos
   masm prob1.asm;
   link prob1.obj;
   prob1.exe
   ```
*(Replace `prob1` with `prob2`, `prob3`, `prob4`, or `prob5` for other programs).*
