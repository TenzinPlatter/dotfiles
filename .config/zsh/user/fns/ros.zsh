sr() {
    if ! command -v ros2 &> /dev/null; then
        source /opt/ros/kilted/setup.zsh
        echo "Sourced global overlay at /opt/ros/kilted"
    fi

    if [[ ! "$(which rosdep)" = "/home/tenzin/Repositories/rosdep/install/rosdep/bin/rosdep" ]]; then
        source /home/tenzin/Repositories/rosdep/install/setup.zsh
        echo "Sourced rosdep fork at /home/tenzin/Repositories/rosdep"
    fi

    local dir_name="${PWD:t}"
    if [[ -f /opt/greenroom/$dir_name/setup.zsh ]]; then
        source /opt/greenroom/$dir_name/setup.zsh
    fi

    if [[ -n "${PLATFORM_MODULE}" && "${PLATFORM_MODULE}" != "${dir_name}" && -f /opt/greenroom/${PLATFORM_MODULE}/setup.zsh ]]; then
        source /opt/greenroom/$dir_name/setup.zsh
    fi


    [[ -f /opt/greeroom/setup.zsh ]] && source /opt/greenroom/setup.zsh

    if [[ -f ./install/setup.zsh ]]; then
        source ./install/setup.zsh
        echo "Sourced local workspace"
    fi
}

