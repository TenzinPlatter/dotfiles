if [[ $- == *i* ]]; then
    # Cache pokego output for faster shell startup
    cached_pokego() {
        local cache_file="${XDG_CACHE_HOME:-$HOME/.cache}/pokego_cache"
        local cache_age_max=${POKEGO_CACHE_AGE:-60}  # Default: 60 seconds

        # Check if cache exists and is fresh
        if [[ -f "$cache_file" ]]; then
            local cache_age=$(($(date +%s) - $(stat -c %Y "$cache_file" 2>/dev/null || stat -f %m "$cache_file" 2>/dev/null)))
            if [[ $cache_age -lt $cache_age_max ]]; then
                cat "$cache_file"
                return
            fi
        fi

        # Generate new output and cache it
        pokego -r 1 --no-title 2>/dev/null | tee "$cache_file"
    }

    cached_pokego | fastfetch --file-raw - 2>/dev/null

    bindkey '^ ' autosuggest-accept

    zle -N set-cd
    bindkey '' set-cd

    zle -N prepend-sudo
    bindkey '\e\e' prepend-sudo
fi
