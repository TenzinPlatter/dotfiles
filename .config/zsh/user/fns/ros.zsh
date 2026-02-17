sr() {
    distro="kilted"

    if ! command -v ros2 &> /dev/null; then
        source /opt/ros/$distro/setup.zsh
        echo "Sourced global overlay at /opt/ros/$distro"
    fi

    if [[ ! "$(which rosdep)" = "/home/tenzin/Repositories/rosdep/install/rosdep/bin/rosdep" ]]; then
        source /home/tenzin/Repositories/rosdep/install/setup.zsh
        echo "Sourced rosdep fork at /home/tenzin/Repositories/rosdep"
    fi

    local dir_name="${PWD:t}"
    if [[ -f /opt/greenroom/$dir_name/install/setup.bash ]]; then
        source /opt/greenroom/$dir_name/install/setup.bash
    fi

    [[ -f /opt/greeroom/setup.zsh ]] && source /opt/greenroom/setup.zsh

    if [[ -f ./install/setup.zsh ]]; then
        source ./install/setup.zsh
        echo "Sourced local workspace"
    fi
}

