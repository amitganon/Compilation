# Compilation

## Project Description:

A working compiler that can compile a large subset of Scheme into Intel x86, 64-bit assembly language, and then, using the Newtide Assembler (NASM), assemble it into a standalone executable.

## The files of the project

• code-gen.ml: This is the additional code in OCaml. This code implements the constants table, the free-variables table, the interface for the Code_Generation module, the Code_Generation module itself, and many support functions.

• **compiler.ml**: code-gen.ml combines with my reader, tag-parser, and semantic analyzer code, into a single file called compiler.ml.

• prologue-1.asm: This is a template header for the assembly language generated by my compilers. It includes the definitions of run-time type information (RTTI), and various macros that make writing the compiler much easier.

• prologue-2.asm: This is some more boilerplate code that is sandwiched inside the start of my assembly-language output.

• epilogue.asm: This is the file that ends the main function, where compiled user code is located, followed by over 1600 lines of assembly-language routines.

• makefile: This is the makefile that I use to assemble the code generated by the compiler.

• init.scm: This is a Scheme source file that is loaded by my compiler, ahead of any user code, and provides some additional built-in procedures. The lower-level procedures are written in assembly language and are located in the epilogue.asm file. But anything that can be implemented practically in Scheme really should be, and this file contains over 90 procedures that were implemented in Scheme.
