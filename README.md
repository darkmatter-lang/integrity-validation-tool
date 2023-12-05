# Darkmatter LLVM-IR Validation Tool

A tool to validate the integrity of a Darkmatter-compiled LLVM-IR assembly file.

### Features
- Rudementary integrity detection.
- Basic LLVM-IR metadata analysis.

### Usage

Requires Docker!

```sh
# Show assembly information and validate assembly integrity
./dmv.sh analyze test/exit_42.ll

# Perform a quick integrity check on all files in `test/`
./dmv.sh check test/*
```


