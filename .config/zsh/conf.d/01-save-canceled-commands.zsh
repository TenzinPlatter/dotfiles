# Save commands to history even when canceled with Ctrl-C

# Custom widget to save current line to history before canceling
save-line-to-history-and-cancel() {
    # Only save if there's actual content (not just whitespace)
    if [[ -n "${BUFFER// }" ]]; then
        # Add the current line to history
        print -s -- "$BUFFER"
    fi
    # Clear the line and reset prompt
    BUFFER=""
    zle send-break
}

# Register the widget
zle -N save-line-to-history-and-cancel

# Bind Ctrl-C to our custom widget
bindkey '^C' save-line-to-history-and-cancel
