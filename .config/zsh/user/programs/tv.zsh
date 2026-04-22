[[ -f ~/.fzf.zsh ]] && source ~/.fzf.zsh

eval "$(tv init zsh)"

tvcd() {
    local selected_dir
    selected_dir=$(tv dirs)
    if [[ -n "$selected_dir" && -d "$selected_dir" ]]; then
        cd "$selected_dir" || return 1
    else
        return 1
    fi
}

tve() {
    local selected_file
    selected_file=$(tv files)
    if [[ -n "$selected_file" && -f "$selected_file" ]]; then
        "${EDITOR:-vim}" "$selected_file"
    else
        return 1
    fi
}

tvec() {
    local selected
    selected=$(tv vim-grep)
    if [[ -n "$selected" ]]; then
        local file="${selected%%:*}"
        local line="${selected#*:}"
        line="${line%%:*}"
        "${EDITOR:-vim}" "+$line" "$file"
    else
        return 1
    fi
}

bindkey '' tv-file-widget

alias tvd='tv dirs'
