# Setup fzf
# ---------
if [[ ! "$PATH" == */home/cyril/.fzf/bin* ]]; then
  export PATH="${PATH:+${PATH}:}/home/cyril/.fzf/bin"
fi

# Auto-completion
# ---------------
[[ $- == *i* ]] && source "/home/cyril/.fzf/shell/completion.bash" 2> /dev/null

# Key bindings
# ------------
source "/home/cyril/.fzf/shell/key-bindings.bash"
