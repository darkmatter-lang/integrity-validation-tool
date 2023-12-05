FROM debian:bullseye-20231120-slim
LABEL name="darkmatter-ivt"
LABEL description="Darkmatter LLVM-IR Integrity Validation Tool"
LABEL maintainer="Anthony Waldsmith <awaldsmith@protonmail.com>"

# Install dependencies
RUN apt update -yq && apt install -yq git curl gcc lua5.3 lua-bit32 zip llvm-13-dev lld-13

# Create user
RUN useradd -s /bin/bash -m llvm

WORKDIR /home/llvm

# Switch to user
USER llvm
