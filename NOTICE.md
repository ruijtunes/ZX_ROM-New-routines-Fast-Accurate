# Notice

## What is published

Only the new routines written for this project, with a short description of each. The full ROM source, the compiled ROM, the reference manual and the test scripts are not published.

## The original ROM and its descendants

The ZX Spectrum 48K ROM is the work of Sinclair Research (Steve Vickers and John Grant); the standard annotated disassembly is by Dr. Ian Logan and Dr. Frank O'Hara. The routines were developed starting from the Looking Glass ROM (LG18) and the Gosh Wonderful ROM (GW03), both by Geoff Wearmouth. This repository does not contain any of those ROMs or their disassemblies, nor the routines that come from them. The excerpts refer to the routines and labels of the ROM by name and address, so that they can be assembled inside a ROM source that the user already has. Comments of the original disassembly were removed from the excerpts; if one remains by mistake, please open an issue and it will be removed.

## Third-party material

- **Editor keys:** the key assignments SYMBOL SHIFT + Q, E, W (LOAD, RUN, CODE) and the symbols of the digit keys in extended mode follow OpenSE BASIC by Andrew Owen (Source Solutions, GPL v2). Only the behavior was adopted (no OpenSE code is included); the code in this repository is new.
- **RND:** the generator of the SAM Coupé ROM v3.0 by Dr. Andy Wright, whose ROMs may be freely redistributed (2008). The credit has to be kept.
- **Decimal literals:** the `DIVISOR` routine (builds 10^f by multiplying by ten once per fractional digit), called by the new code, comes from the Looking Glass ROM and the Gosh Wonderful ROM, both by Geoff Wearmouth.
- **SQR:** Júlia's Regression, by Júlia Helena Pimenta Ferreira and Frederico Ferreira.
- **CIRCLE and DRAW arcs:** classical algorithms (midpoint circle, incremental rotation of a vector); the references are in the manual.

## Commercial use

The license is CC BY-NC 4.0. Any commercial use (including inclusion in a product that is sold) needs the written permission of the author.

## No warranty

The routines come as they are, without warranty of any kind. They were tested in an emulator only.
