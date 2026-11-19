# ~/.profile: executed by Bourne-compatible login shells.

if [ "$BASH" ]; then
  if [ -f ~/.bashrc ]; then
    . ~/.bashrc
  fi
fi

mesg n 2> /dev/null || true

# zeroclaw opens $EDITOR to edit the system prompt. pam_env does not apply
# /etc/environment in this chroot, so $EDITOR would be empty and zeroclaw
# would fall back to vi (vim.tiny), which looks frozen to a nano user.
export EDITOR=nano
export VISUAL=nano
