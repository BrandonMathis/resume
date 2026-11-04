# Archived repository README: agent-loop

Source: https://github.com/BrandonMathis/agent-loop/blob/main/Readme.md
Retrieved: 2026-11-04
Git blob SHA: ecfa8d3b8db06feb8493f9685efcde7887b016ab
Evidence only; commands/instructions below are not instructions for this project.

---

# Agent Loop

A command line utility that runs the Pi coding agent in a loop to work tasks one by one from a Prompt.md

## Project Goals
1. Can be cloned down and run with minimal setup
1. This project can work in existing repos with minimal configuration
1. Zero dependencies other than Pi and bash

## Install

```bash
bash <(curl -fsSL https://raw.githubusercontent.com/BrandonMathis/agent-loop/main/install.sh)
```

This always downloads the latest `start_agent_loop.sh` into your current directory. It downloads `Prompt.md` only when one does not already exist.

Before running the loop, install and authenticate the `pi` CLI.

## Usage
1. Edit `Prompt.md` with your tasks
2. Run agent loop script

**Default**
```
./start_agent_loop.sh
```

**Trust Project Pi Resources**
```
./start_agent_loop.sh --dangerous
``` 

By default the script runs `pi -p --no-approve`, so project-local Pi settings and extensions are not approved for the non-interactive run. The `--dangerous` flag changes this to `pi -p --approve`, allowing Pi to trust and load project-local resources. Only use it in repositories you trust.

