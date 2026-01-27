# >>> conda lazy initialize >>>
conda() {
    unfunction conda
    __conda_setup="$('/home/tenzin/anaconda3/bin/conda' 'shell.zsh' 'hook' 2> /dev/null)"
    if [ $? -eq 0 ]; then
        eval "$__conda_setup"
    else
        if [ -f "/home/tenzin/anaconda3/etc/profile.d/conda.sh" ]; then
            . "/home/tenzin/anaconda3/etc/profile.d/conda.sh"
        else
            export PATH="/home/tenzin/anaconda3/bin:$PATH"
        fi
    fi
    unset __conda_setup
    conda "$@"
}
# <<< conda lazy initialize <<<
