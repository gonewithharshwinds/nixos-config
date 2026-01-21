{ pkgs, ... }:


{
environment.systemPackages = with pkgs; [
# -----------------------------
# Core Languages & Runtimes
# -----------------------------


# python314 # Latest stable Python (3.12)
# python314Packages.pip
# python314Packages.virtualenv


nodejs_25 # Latest LTS Node.js (includes npm)
nodePackages.npm
nodePackages.pnpm
nodePackages.yarn


# go_1_22 # Modern Go toolchain
rustup # Rust toolchain manager


# -----------------------------
# Language Servers / Dev UX
# -----------------------------


pyright # Python LSP
ruff # Python linting / formatting
# nil # Nix LSP
# nixfmt-rfc-style


# -----------------------------
# Build & Infra Utilities
# -----------------------------


git
gh # GitHub CLI
gnumake
cmake
pkg-config


# -----------------------------
# Containers / Tooling
# -----------------------------


docker-compose
podman
skopeo


# -----------------------------
# Misc Dev Utilities
# -----------------------------


jq
yq
ripgrep
fd
unzip
];
}