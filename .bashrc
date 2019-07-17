# Personal config for interactive shells

# Set vi keybindings
set -o vi
bind Space:magic-space
bind -m vi-insert "\C-l":clear-screen
bind -m vi-insert "\C-w":unix-filename-rubout

MAIL=~/local-mail

# Read aliases
if [[ -e ~/.bash_aliases ]]; then
	. ~/.bash_aliases
fi

# Set COLORTERM for high color
if [[ $TERM == st-256color ]]; then
  export COLORTERM=truecolor
fi

# Read 'global' functions
if [[ -d ~/.functions.d ]]; then
    for file in ~/.functions.d/*; do
        [[ -f ${file} ]] && source ${file}
    done
    # Read host-specific functions - file must be in ~/.functions.d/hosts.d/
    # and be named to match $HOSTNAME
    [[ -f $HOME/.functions.d/hosts.d/$HOSTNAME ]] && source ~/.functions.d/hosts.d/$HOSTNAME
fi

shopt -s cdspell
shopt -s nullglob
shopt -u failglob

# New SSH magic
if [[ -z $SSH_CLIENT ]]; then
  eval `keychain --eval --agents gpg,ssh id_dsa`
fi

# Recall last directory
if [[ -r ~/.bash_lastdir ]] && [[ -s ~/.bash_lastdir ]]; then
  cdto=$(cat ~/.bash_lastdir)
  if [[ -d $cdto ]] && [[ -x $cdto ]]; then
    if ! cd "$cdto"; then
      echo "Unable to cd into $cdto"
    fi
  fi
  rm ~/.bash_lastdir
fi

# Bash completion
. $HOME/.bash_completion
set show-all-if-ambiguous On
set show-all-if-unmodified On
set skip-completed-text On

### Host-specific stuff, like setting prompts
# First, make sure that  colors are loaded:
function __set_my_git_prompt
{
  # Detect git.  if the git completion file is loaded, then modify PS1
  if type __gitdir &> /dev/null; then
      export GIT_PS1_SHOWDIRTYSTATE="true"
      export GIT_PS1_SHOWSTASHSTATE="true"
      export GIT_PS1_SHOWUNTRACKEDFILES="true"
      export PS1="`echo $PS1 | sed 's/\\\$/\$\(__git_ps1 " \(%s\)"\)\\\$ /' `"
  fi
}

function __colorize_prompt_toggle()
{
  if ! grep -q colorize_pwd <<<"$PS1"; then
    export PS1="`echo $PS1 | sed 's/\\\w/\$colorprompt/'`"
    PROMPT_COMMAND=__colorize_pwd
  else
    export PS1="${PS1/\$colorprompt/\\w}"
  fi
}

if [[ $TERM == st-256color ]]; then
  export COLORTERM=truecolor
fi

if [[ $COLORTERM ]]; then
  usrclr=${txthi[$(( $(echo $USER | cksum - | cut -f1 -d' ') % 78 ))]}
  hstclr=${txthi[$(( $(echo $HOSTNAME | cksum - | cut -f1 -d' ') % 78 ))]}
  export PS1="[\[$usrclr\]\u\[$txtrst\]@\[$hstclr\]\h\[$txtrst\] \w]\[$bldwht\]\$\[$txtrst\] "
elif [[ $TERM ]] && (( "$(tput colors)" > 7 )); then
  usrclr=${txtlo[$(( $(echo $USER | cksum - | cut -f1 -d' ') % 22 ))]}
  hstclr=${txtlo[$(( $(echo $HOSTNAME | cksum - | cut -f1 -d' ') % 22 ))]}
  export PS1="[\[$usrclr\]\u\[$txtrst\]@\[$hstclr\]\h\[$txtrst\] \w]\[$bldwht\]\$\[$txtrst\] "
else # Fallback
    echo "fallback prompt for terminal $TERM"
    export PS1="[\u@\h \w]\$ "
fi

# Now that color is set, modify for git prompt
__set_my_git_prompt

[[ $COLORTERM ]] && __colorize_prompt_toggle

# Login Shell hello items
echo -en $txtred
cat /etc/redhat-release
echo -en $txtrst
cal
date
if [[ -e ~/.biffy ]]; then
  echo -en $txtred
  cat ~/.biffy
  echo -en $txtrst
fi

now=$(date +%s)
for chalrespfile in /var/lib/yubico/jagipson-69604*; do
  mtime=$(stat -c %Y "$chalrespfile")
  ser=${chalrespfile##*-}
  if (( now - mtime > 1209600 )); then
    printf "%sWarning: It has been over 2 weeks since you have used\n"
    printf "         your yubikey with serial number: %s%s\n" "$bldylw" "$ser" "$txtrst"
  fi
done
