# Add you own custom prompt here

#! As long as this file returns non-zero, HyDE will ignore this file!
#! return 0 will lead to no prompt being loaded

# ================================================================
# Your custom prompt goes here

eval "$(starship init zsh)"
export STARSHIP_CACHE=$XDG_CACHE_HOME/starship
export STARSHIP_CONFIG=$XDG_CONFIG_HOME/starship/starship.toml
