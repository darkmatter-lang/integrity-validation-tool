# Darkmatter LLVM-IR Integrity Validation Tool

A tool to validate the integrity of a Darkmatter-compiled LLVM-IR assembly file.

### Features
- Rudimentary integrity detection.
- Basic LLVM-IR metadata analysis.

### Usage

Requires Docker!

```sh
# Show assembly information and validate assembly integrity
./ivt.sh analyze test/exit_42.ll

# Perform a quick integrity check on all files in `test/`
./ivt.sh check test/*
```


