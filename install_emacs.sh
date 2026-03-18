#!/usr/bin/env bash
set -euo pipefail

detect_os() {
    if [[ "$(uname -s)" == "Darwin" ]]; then
        echo "macos"
    elif [[ -f /etc/os-release ]]; then
        . /etc/os-release
        echo "${ID}"
    else
        echo "unknown"
    fi
}

check_existing() {
    if command -v emacs &>/dev/null; then
        local current
        current=$(emacs --version | head -1)
        echo "Emacs is already installed: ${current}"
        read -rp "Do you want to continue with installation/upgrade? [y/N] " answer
        if [[ ! "$answer" =~ ^[Yy]$ ]]; then
            echo "Aborted."
            exit 0
        fi
    fi
}

install_macos() {
    if ! command -v brew &>/dev/null; then
        echo "Error: Homebrew is required. Install from https://brew.sh"
        exit 1
    fi

    echo "Installing Emacs via Homebrew..."
    brew install --cask emacs
}

install_ubuntu() {
    local version="${1:-28}"
    echo "Installing Emacs ${version} on Ubuntu..."

    # Remove old emacs packages that conflict with PPA versions
    if dpkg -l emacs-common 2>/dev/null | grep -q ^ii; then
        echo "Removing old emacs-common to avoid conflicts..."
        sudo apt remove -y emacs-common emacs-bin-common emacs-el 2>/dev/null || true
    fi

    if [[ "$version" -le 29 ]]; then
        # kelleyk PPA covers emacs 28 and 29
        if ! grep -q "kelleyk/emacs" /etc/apt/sources.list.d/*.list 2>/dev/null; then
            echo "Adding kelleyk/emacs PPA..."
            sudo add-apt-repository -y ppa:kelleyk/emacs
        fi
        sudo apt update
        sudo apt install -y "emacs${version}-nox"
    else
        # Emacs 30+: build from source
        echo "Emacs ${version} not in PPA, building from source..."
        sudo apt install -y build-essential libgnutls28-dev libncurses-dev \
            libjansson-dev libgccjit-12-dev autoconf texinfo
        local build_dir="/tmp/emacs-${version}-build"
        rm -rf "$build_dir"
        git clone --branch "emacs-${version}" --depth 1 \
            https://git.savannah.gnu.org/git/emacs.git "$build_dir"
        cd "$build_dir"
        ./autogen.sh
        ./configure --with-native-compilation --without-x
        make -j"$(nproc)"
        sudo make install
        echo "Installed to /usr/local/bin/emacs"
    fi
}

OS=$(detect_os)
echo "Detected OS: ${OS}"

check_existing

case "$OS" in
    macos)  install_macos ;;
    ubuntu) install_ubuntu "${1:-28}" ;;
    *)
        echo "Error: Unsupported OS '${OS}'"
        exit 1
        ;;
esac

echo "Done. Emacs version:"
emacs --version | head -1
