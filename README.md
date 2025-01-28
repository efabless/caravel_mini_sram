# Caravel User Mini

This repository contains an example caravel_mini project that demonstrates how to integrate the [EF_SRAM_1024X32](https://platform.efabless.com/design_catalog/ip_block/40) macro inside the caravel Mini.

## Installation

To install all dependencies and start working on your project, follow these steps:

1. Press the "Use this template" button to create your own repository.
2. Clone the repository:
   ```bash
   git clone https://github.com/efabless/caravel_mini_sram.git
   cd caravel_mini_sram
   ```

3. Set up the environment:
   ```bash
   make setup
   ```

This will download all necessary dependencies.

## Install the EF_SRAM macro
   ```bash
   pip install ipmgr
   ipm install EF_SRAM_1024x32
   ```

## Hardening Your Design

To start the hardening process, run:
```bash
make SRAM_1024x32_wb_wrapper
```

To harden the top level `user_project_wrapper_mini4` macro run
```bash
make user_project_wrapper_mini4
```
