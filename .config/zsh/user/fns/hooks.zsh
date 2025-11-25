sudo-command-line () {
    [[ -z $BUFFER ]] && LBUFFER="$(fc -ln -1)"
    local WHITESPACE=""
    if [[ ${LBUFFER:0:1} = " " ]]
    then
        WHITESPACE=" "
        LBUFFER="${LBUFFER:1}"
    fi
    {
        local EDITOR=${SUDO_EDITOR:-${VISUAL:-$EDITOR}}
        if [[ -z "$EDITOR" ]]
        then
            case "$BUFFER" in
                (sudo\ -e\ *) __sudo-replace-buffer "sudo -e" "" ;;
                (sudo\ *) __sudo-replace-buffer "sudo" "" ;;
                (*) LBUFFER="sudo $LBUFFER"  ;;
            esac
            return
        fi
        local cmd="${${(Az)BUFFER}[1]}"
        local realcmd="${${(Az)aliases[$cmd]}[1]:-$cmd}"
        local editorcmd="${${(Az)EDITOR}[1]}"
        if [[ "$realcmd" = (\$EDITOR|$editorcmd|${editorcmd:c}) || "${realcmd:c}" = ($editorcmd|${editorcmd:c}) ]] || builtin which -a "$realcmd" | command grep -Fx -q "$editorcmd"
        then
            __sudo-replace-buffer "$cmd" "sudo -e"
            return
        fi
        case "$BUFFER" in
            ($editorcmd\ *) __sudo-replace-buffer "$editorcmd" "sudo -e" ;;
            (\$EDITOR\ *) __sudo-replace-buffer '$EDITOR' "sudo -e" ;;
            (sudo\ -e\ *) __sudo-replace-buffer "sudo -e" "$EDITOR" ;;
            (sudo\ *) __sudo-replace-buffer "sudo" "" ;;
            (*) LBUFFER="sudo $LBUFFER"  ;;
        esac
    } always {
        LBUFFER="${WHITESPACE}${LBUFFER}"
        zle && zle redisplay
    }
}

set-cd() {
	if [[ -z $BUFFER ]]; then
		LBUFFER="cd "
	else
		BUFFER="cd $BUFFER"
		zle accept-line
	fi
}

resume() {
    fg
    zle push-input
    BUFFER=""
    zle accept-line
}

forward-word-dir () {
    local WORDCHARS='*?_-.[]~=/&;!#$%^(){}<>'
    zle forward-word
}
zle -N forward-word-dir

backward-word-dir () {
    local WORDCHARS='*?_-.[]~=/&;!#$%^(){}<>'
    zle backward-word
}
zle -N backward-word-dir

# Bind the custom functions
bindkey "^[[1;5C" forward-word-dir      # Ctrl+Right
bindkey "^[[1;5D" backward-word-dir     # Ctrl+Left

zle -N resume
bindkey '' resume

zle -N sudo-command-line
zle -N set-cd

bindkey '\e\e' sudo-command-line
bindkey  set-cd
