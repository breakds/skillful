---
name: nix-scaffolding
description: Use when creating a new project from scratch that needs Nix flake setup with devshell
---

# Nix Project Scaffolding

Create new projects with `flake.nix` and devshell for Python, Rust, or webapp stacks.

## Workflow

1. **Gather basic info:**
   - Project name (used for directory and shell name)
   - Short description (for flake description)
   - Project type: Python / Python+ML / Rust / Webapp

2. **Gather project-specific details:**
   - **Python/Python+ML:** Initial Python dependencies to include (e.g., `pandas`, `pytest`, `fastapi`)
   - **Rust:** Additional system dependencies for `buildInputs` (e.g., `libva`, `glib.dev`)
   - **Webapp:** Any additional tools beyond Node.js + pnpm
   - **All:** Custom shellHook commands, environment variables, or special configurations

3. **Ask for nixpkgs pin:**
   - Ask user which nixpkgs commit to pin in `flake.lock`
   - User may provide a commit hash or reference another project's lock

4. **Create and customize project:**
   - Create project directory
   - Copy appropriate template from `templates/`
   - Replace `{{PROJECT_NAME}}` and `{{PROJECT_DESCRIPTION}}` placeholders
   - **Customize based on gathered details:**
     - Add specified dependencies to packages list
     - Add any custom buildInputs or environment variables
     - Modify shellHook if needed
   - Run `git init`
   - Run `nix flake lock --override-input nixpkgs github:NixOS/nixpkgs/<commit>`

## Templates

| Template | Use when |
|----------|----------|
| `basic-python` | Pure Python projects without ML/CUDA needs |
| `basic-python-ml` | ML/robotics projects needing CUDA and ml-pkgs overlay |
| `basic-rust` | Rust projects (uses crane with full checks) |
| `basic-webapp` | Frontend apps with Node.js + pnpm |
| `pyo3-python` | Python library with Rust backend via PyO3/maturin |
| `esp32` | ESP32 embedded projects with ESP-IDF (C/C++) |

## Template Structure

All templates create:
```
<project>/
  flake.nix           # flake-parts based
  .envrc              # direnv integration (watch_dir nix, use flake)
  nix/
    development.nix   # devShell definition
```

The `pyo3-python` template additionally creates:
```
<project>/
  Cargo.toml          # Rust crate config with pyo3 dependency
  pyproject.toml      # Python project config with maturin build
  nix/
    package.nix       # buildPythonPackage definition
```

The `esp32` template uses flat structure (no nix/ subdirectory):
```
<project>/
  flake.nix           # Re-exports devShells from nixpkgs-esp-dev
  .envrc              # Also sources .envrc.local if exists
  .gitignore          # Ignores build/, sdkconfig, etc.
  CMakeLists.txt      # ESP-IDF project config
  main/
    CMakeLists.txt    # ESP-IDF component config
    main.c            # Entry point with app_main()
```

## Placeholder Reference

| Placeholder | Replace with |
|-------------|--------------|
| `{{PROJECT_NAME}}` | Project name (lowercase, hyphens ok) |
| `{{PROJECT_NAME_UNDERSCORE}}` | Project name with underscores (for Python module names) |
| `{{PROJECT_DESCRIPTION}}` | Short description for flake |

## After Scaffolding

Remind user to:
- Enter the directory and run `direnv allow` (or `nix develop` to verify manually)
- Add project-specific dependencies to `nix/development.nix`
- For Rust: run `cargo init` to create Cargo.toml
- For Webapp: run `pnpm create vite .` or similar to initialize the app
- For PyO3: create `src/lib.rs` with pyo3 module, create `python/<module>/__init__.py`, update hash in `nix/package.nix` after first build
- For ESP32: run `idf.py set-target esp32s3` (or target chip), then `idf.py build` to compile
