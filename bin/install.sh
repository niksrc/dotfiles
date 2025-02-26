#!/bin/bash
set -e
set -o pipefail

# install.sh
#	This script installs my basic setup for a debian laptop

export DEBIAN_FRONTEND=noninteractive

check_is_sudo() {
	if [ "$EUID" -ne 0 ]; then
		echo "Please run as root."
		exit
	fi
}


setup_sources() {
	apt update || true
	apt install -y \
		apt-transport-https \
		ca-certificates \
		curl \
		dirmngr \
		gnupg2 \
		lsb-release \
		--no-install-recommends

	# turn off translations, speed up apt update
	mkdir -p /etc/apt/apt.conf.d
	echo 'Acquire::Languages "none";' > /etc/apt/apt.conf.d/99translations

	# Add the Google Chrome distribution URI as a package source
	cat <<-EOF > /etc/apt/sources.list.d/google-chrome.list
	deb [arch=amd64 signed-by=/usr/share/keyrings/google.gpg] http://dl.google.com/linux/chrome/deb/ stable main
	EOF

	# Import the Google Chrome public key
	curl https://dl.google.com/linux/linux_signing_key.pub | gpg --dearmor | sudo tee /usr/share/keyrings/google.gpg >/dev/null
}

base() {
	apt update || true
	apt -y upgrade

	apt install -y \
		ca-certificates \
		git \
		tzdata \
		bash-completion \
		coreutils \
		dnsutils \
		findutils \
		net-tools \
		file \
		bc \
		jq \
		fzf \
		silversearcher-ag \
		shellcheck \
		automake \
		cmake \
		build-essential \
		strace \
		tar \
		bzip2 \
		7zip \
		gzip \
		indent \
		unzip \
		xz-utils \
		zip \
		openssh-client \
		openssh-server \
		vim \
		stow \
		--no-install-recommends

	apt autoremove -y
	apt autoclean -y
	apt clean -y
}

# install rust

install_rust() {
	curl https://sh.rustup.rs -sSf | sh
	# Install clippy
	rustup component add clippy
}

# install/update golang from source
install_golang() {
	export GO_VERSION
	GO_VERSION=$(curl -sSL "https://go.dev/VERSION?m=text" | awk -Fgo '{ print $2 }')
	export GO_SRC=/usr/local/go

	# if we are passing the version
	if [[ -n "$1" ]]; then
		GO_VERSION=$1
	fi

	# purge old src
	if [[ -d "$GO_SRC" ]]; then
		sudo rm -rf "$GO_SRC"
		sudo rm -rf "$GOPATH"
	fi

	GO_VERSION=${GO_VERSION#go}

	# subshell
	(
	kernel=$(uname -s | tr '[:upper:]' '[:lower:]')
	curl -sSL "https://storage.googleapis.com/golang/go${GO_VERSION}.${kernel}-amd64.tar.gz" | sudo tar -v -C /usr/local -xz
	)
}

install_node() {
	curl https://get.volta.sh | bash -s -- --skip-setup
	volta install node@lts
}

install_python() {
	curl -LsSf https://astral.sh/uv/install.sh | sh
}

# install custom scripts/binaries
install_scripts() {
	# install speedtest
	curl -sSL https://raw.githubusercontent.com/sivel/speedtest-cli/master/speedtest.py  > /usr/local/bin/speedtest
	chmod +x /usr/local/bin/speedtest

	# install lolcat
	curl -sSL https://raw.githubusercontent.com/tehmaze/lolcat/master/lolcat > /usr/local/bin/lolcat
	chmod +x /usr/local/bin/lolcat
}

# install stuff for i3 window manager
install_wmapps() {
	sudo apt update || true
	sudo apt install -y \
		bluez \
		bluez-firmware \
		feh \
		google-chrome-stable \
		i3 \
		i3lock \
		i3status \
		pulseaudio \
		pulseaudio-module-bluetooth \
		pulsemixer \
		rofi \
		rxvt-unicode \
		scrot \
		usbmuxd \
		xclip \
		xcompmgr \
		--no-install-recommends

	# start and enable pulseaudio
	systemctl --user daemon-reload
	systemctl --user enable pulseaudio.service
	systemctl --user enable pulseaudio.socket
	systemctl --user start pulseaudio.service

	echo "Fonts file setup successfully now run:"
	echo "	dpkg-reconfigure fontconfig-config"
	echo "with settings: "
	echo "	Autohinter, Automatic, No."
	echo "Run: "
	echo "	dpkg-reconfigure fontconfig"
}

install_tools() {
	echo "Installing golang..."
	echo
	install_golang;

	echo
	echo "Installing rust..."
	echo
	install_rust;

	echo
	echo "Installing scripts..."
	echo
	sudo install.sh scripts;
}

usage() {
	echo -e "install.sh\\n\\tThis script installs my basic setup for a debian laptop\\n"
	echo "Usage:"
	echo "  base                                - setup sources & install base pkgs"
	echo "  wm                                  - install window manager/desktop pkgs"
	echo "  golang                              - install golang and packages"
	echo "  rust                                - install rust"
	echo "  python                              - install python (uv)"
	echo "  node                                - install node (volta)"
	echo "  scripts                             - install scripts"
	echo "  tools                               - install golang, rust, and scripts"
}

main() {
	local cmd=$1

	if [[ -z "$cmd" ]]; then
		usage
		exit 1
	fi

	if [[ $cmd == "base" ]]; then
		check_is_sudo
		setup_sources
		base
	elif [[ $cmd == "wm" ]]; then
		install_wmapps
	elif [[ $cmd == "rust" ]]; then
		install_rust
	elif [[ $cmd == "golang" ]]; then
		install_golang "$2"
	elif [[ $cmd == "python" ]]; then
		install_python
	elif [[ $cmd == "node" ]]; then
		install_node
	elif [[ $cmd == "scripts" ]]; then
		install_scripts
	elif [[ $cmd == "tools" ]]; then
		install_tools
	else
		usage
	fi
}

main "$@"
