if command -v twiggle 2>&1 >/dev/null; then
    walk() {
        cd $(twiggle)
    }
fi
