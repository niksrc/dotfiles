#!/bin/bash
# ~/.bashrc: executed by bash(1) for non-login shells.
# see /usr/share/doc/bash/examples/startup-files (in the package bash-doc)
# for examples

# If not running interactively, don't do anything
case $- in
	*i*) ;;
	*) return;;
esac

# check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize

# Prevent file overwrite on stdout redirection
# Use `>|` to force redirection to an existing file
set -o noclobber

# If set, the pattern "**" used in a pathname expansion context will
# match all files and zero or more directories and subdirectories.
#shopt -s globstar

# make less more friendly for non-text input files, see lesspipe(1)
[ -x /usr/bin/lesspipe ] && export LESSOPEN="|lesspipe %s"

# set variable identifying the chroot you work in (used in the prompt below)
if [ -z "${debian_chroot:-}" ] && [ -r /etc/debian_chroot ]; then
	debian_chroot=$(cat /etc/debian_chroot)
fi

# set a fancy prompt (non-color, unless we know we "want" color)
case "$TERM" in
	xterm-color) color_prompt=yes;;
esac

# uncomment for a colored prompt, if the terminal has the capability; turned
# off by default to not distract the user: the focus in a terminal window
# should be on the output of commands, not on the prompt
force_color_prompt=yes

if [ -n "$force_color_prompt" ]; then
	if [ -x /usr/bin/tput ] && tput setaf 1 >&/dev/null; then
		# We have color support; assume it's compliant with Ecma-48
		# (ISO/IEC-6429). (Lack of such support is extremely rare, and such
		# a case would tend to support setf rather than setaf.)
		color_prompt=yes
	else
		color_prompt=
	fi
fi

if [ "$color_prompt" = yes ]; then
	PS1='${debian_chroot:+($debian_chroot)}\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '
else
	PS1='${debian_chroot:+($debian_chroot)}\u@\h:\w\$ '
fi
unset color_prompt force_color_prompt

# If this is an xterm set the title to user@host:dir
case "$TERM" in
	xterm*|rxvt*)
		PS1="\\[\\e]0;${debian_chroot:+($debian_chroot)}\\u@\\h: \\w\\a\\]$PS1"
		;;
	*)
		;;
esac

# enable color support of ls and also add handy aliases
if [ -x /usr/bin/dircolors ]; then
	# shellcheck disable=SC2015
	test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
	alias ls='ls --color=auto'
	alias dir='dir --color=auto'
	alias vdir='vdir --color=auto'

	alias grep='grep --color=auto'
	alias fgrep='fgrep --color=auto'
	alias egrep='egrep --color=auto'
fi

# Add an "alert" alias for long running commands.  Use like so:
#	sleep 10; alert
alias alert='notify-send --urgency=low -i "$([ $? = 0 ] && echo terminal || echo error)" "$(history|tail -n1|sed -e '\''s/^\s*[0-9]\+\s*//;s/[;&|]\s*alert$//'\'')"'

# We do this before the following so that all the paths work.
for file in ~/.{aliases,functions,path,exports,bash_prompt}; do
	if [[ -r "$file" ]] && [[ -f "$file" ]]; then
		if [[ -n $BASHRC_BENCH ]]; then
			TIMEFORMAT="$file: %R"
			# shellcheck source=/dev/null
			time source "$file"
			unset TIMEFORMAT
		else
			# shellcheck source=/dev/null
			source "$file"
		fi
	fi
done
unset file

# enable programmable completion features (you don't need to enable
# this, if it's already enabled in /etc/bash.bashrc and /etc/profile
# sources /etc/bash.bashrc).
if ! shopt -oq posix; then
	if [[ -f /usr/share/bash-completion/bash_completion ]]; then
		# shellcheck source=/dev/null
		. /usr/share/bash-completion/bash_completion
	elif [[ -f /etc/bash_completion ]]; then
		# shellcheck source=/dev/null
		. /etc/bash_completion
	elif [[ -f /usr/local/etc/bash_completion ]]; then
		# shellcheck source=/dev/null
		. /usr/local/etc/bash_completion
	fi
fi

if [[ -d /etc/bash_completion.d/ ]]; then
	for file in /etc/bash_completion.d/* ; do
		if [[ -n $BASHRC_BENCH ]]; then
			TIMEFORMAT="$file: %R"
			# shellcheck source=/dev/null
			time source "$file"
			unset TIMEFORMAT
		else
			# shellcheck source=/dev/null
			source "$file"
		fi
	done
fi

hbfile="/opt/homebrew/etc/profile.d/bash_completion.sh"
if [[ -f "$hbfile" ]]; then
	if [[ -n $BASHRC_BENCH ]]; then
		TIMEFORMAT="$hbfile: %R"
		# shellcheck source=/dev/null
		time . "$hbfile"
		unset TIMEFORMAT
	else
		# shellcheck source=/dev/null
		. "$hbfile"
	fi
fi
unset hbfile

# Case-insensitive globbing (used in pathname expansion)
shopt -s nocaseglob

# Append to the Bash history file, rather than overwriting it
shopt -s histappend

# Autocorrect typos in path names when using `cd`
shopt -s cdspell

# Save multi-line commands as one command
shopt -s cmdhist

# Enable some Bash 4 features when possible:
# * `autocd`, e.g. `**/qux` will enter `./foo/bar/baz/qux`
# * Recursive globbing, e.g. `echo **/*.txt`
for option in autocd globstar; do
	shopt -s "$option" 2> /dev/null
done

# Correct spelling errors during tab-completion
shopt -s dirspell 2> /dev/null
# Correct spelling errors in arguments supplied to cd
shopt -s cdspell 2> /dev/null

# Add tab completion for SSH hostnames based on ~/.ssh/config
# ignoring wildcards
[[ -e "$HOME/.ssh/config" ]] && complete -o "default" \
	-o "nospace" \
	-W "$(grep "^Host" ~/.ssh/config | \
	grep -v "[?*]" | cut -d " " -f2 | \
	tr ' ' '\n')" scp sftp ssh

# source kubectl bash completion
if hash kubectl 2>/dev/null; then
	# shellcheck source=/dev/null
	source <(kubectl completion bash)
fi

# get the gh completions
if hash gh 2>/dev/null; then
	eval "$(gh completion -s bash)"
fi

# get the rustup completions
if hash rustup 2>/dev/null; then
	eval "$(rustup completions bash)"
fi
