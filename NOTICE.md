# Notice

## What is published

Only the new routines written for this project, with a short description of each. The full ROM source, the compiled ROM, the reference manual and the test scripts are not published.

## The original ROM and its descendants

The ZX Spectrum 48K ROM is the work of Sinclair Research (Steve Vickers and John Grant); the standard annotated disassembly is by Dr. Ian Logan and Dr. Frank O'Hara.
Some of the routines in this repository were inspired by routines found in Geoff Wearmouth's Looking Glass ROM (LG18) and Gosh Wonderful ROM (GW03).
This repository does not contain any of those ROMs, their disassemblies, or copies of their routines. The excerpts refer to the original ROM routines and labels by name and address, allowing them to be assembled within a ROM source that the user already has.

## Third-party material

- **RND:** the generator of the SAM Coupé ROM v3.0 by Dr. Andy Wright, whose ROMs may be freely redistributed (2008). The credit has to be kept.
- **Decimal literals:** the `DIVISOR` routine (builds 10^f by multiplying by ten once per fractional digit), called by the new code, comes from the Looking Glass ROM and the Gosh Wonderful ROM, both by Geoff Wearmouth.
- **SQR:** Júlia's Regression, by Júlia Helena Pimenta Ferreira and Frederico Ferreira.
- **CIRCLE and DRAW arcs:** classical algorithms (midpoint circle, incremental rotation of a vector); the references are in the manual.

## Commercial use

Most of this routines are free to use. For the others the license is CC BY-NC 4.0. Any commercial use (including inclusion in a product that is sold) needs the written permission of the author.

## No warranty

The routines come as they are, without warranty of any kind.
