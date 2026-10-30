#!/usr/bin/env bash
# Narzędzia deweloperskie C/C++ / Java / Rust — opis w Obsidianie:
# Terminal/10 - Narzędzia deweloperskie.md (sekcja „C/C++, Java, Rust”)
set -euo pipefail

# --- oficjalne repo (extra) ---
sudo pacman -S --needed \
	clang lldb pwndbg valgrind strace ltrace perf heaptrack cppcheck ccache mold \
	visualvm \
	bacon cargo-nextest cargo-expand cargo-audit cargo-deny cargo-flamegraph sccache \
	hexyl

# --- AUR (yay pokaże PKGBUILD-y do przejrzenia) ---
yay -S --needed rr jdtls google-java-format async-profiler jbang hotspot-appimage

# Miri (cargo +nightly miri) potrzebuje toolchaina nightly
rustup toolchain install nightly --profile minimal --component miri,rust-src

# pwndbg ładuje się przez ~/.gdbinit (rust-gdb też z niego korzysta)
if ! grep -qs pwndbg ~/.gdbinit; then
	echo "source /usr/share/pwndbg/gdbinit.py" >>~/.gdbinit
	echo "→ dopisano pwndbg do ~/.gdbinit (zwykłe gdb: gdb -nx)"
fi

echo "Gotowe."
