#!/usr/bin/env bash

set -u

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SCRIPTS_DIR="$PROJECT_ROOT/scripts"

cd "$PROJECT_ROOT" || exit 1

pause() {
    echo
    read -r -p "Press Enter to continue..."
}

run_script() {
    local script="$1"

    echo
    echo "========================================"
    echo "Running: $script"
    echo "========================================"
    echo

    bash "$SCRIPTS_DIR/$script"

    local exit_code=$?

    echo
    echo "========================================"

    if [ "$exit_code" -eq 0 ]; then
        echo "Completed successfully."
    else
        echo "Command failed with exit code: $exit_code"
    fi

    echo "========================================"

    return "$exit_code"
}

show_menu() {
    clear

    echo "========================================"
    echo "          ThServer Developer"
    echo "========================================"
    echo
    echo "Project: $PROJECT_ROOT"
    echo
    echo "Build / Development"
    echo "  1. Build Rust Engine"
    echo "  2. Package Android Engine"
    echo "  3. Build Flutter APK"
    echo "  4. Build Everything"
    echo "  5. Run Android"
    echo
    echo "Runtime"
    echo "  6. Start Supervisor"
    echo "  7. Start Cloudflare Tunnel"
    echo
    echo "Git"
    echo "  8. Git Status"
    echo "  9. Git Commit"
    echo " 10. Git Commit + Push"
    echo
    echo "  0. Exit"
    echo
}

build_rust() {
    run_script "build_android_engine.sh"
}

package_android_engine() {
    run_script "build_android.sh"
}

build_flutter_apk() {
    echo
    echo "========================================"
    echo "Building Flutter APK"
    echo "========================================"
    echo

    (
        cd "$PROJECT_ROOT/flutter_app" || exit 1
        flutter build apk
    )

    local exit_code=$?

    echo

    if [ "$exit_code" -eq 0 ]; then
        echo "Flutter APK build completed."
    else
        echo "Flutter APK build failed."
    fi

    return "$exit_code"
}

build_everything() {
    echo
    echo "========================================"
    echo "Building Everything"
    echo "========================================"
    echo

    build_rust || return 1
    package_android_engine || return 1
    build_flutter_apk || return 1

    echo
    echo "========================================"
    echo "Everything built successfully."
    echo "========================================"
}

run_android() {
    run_script "run_android.sh"
}

start_supervisor() {
    run_script "supervisor.sh"
}

start_tunnel() {
    run_script "tunnel.sh"
}

git_status() {
    echo
    echo "========================================"
    echo "Git Status"
    echo "========================================"
    echo

    git status
}

git_commit() {
    echo
    read -r -p "Commit message: " commit_message

    if [ -z "$commit_message" ]; then
        echo "Commit message cannot be empty."
        return 1
    fi

    git add .

    echo
    git status --short
    echo

    git commit -m "$commit_message"
}

git_commit_push() {
    git_commit || return 1

    echo
    echo "Pushing to origin/main..."
    echo

    git push
}

while true; do
    show_menu

    read -r -p "Select: " choice

    case "$choice" in
        1)
            build_rust
            pause
            ;;
        2)
            package_android_engine
            pause
            ;;
        3)
            build_flutter_apk
            pause
            ;;
        4)
            build_everything
            pause
            ;;
        5)
            run_android
            pause
            ;;
        6)
            start_supervisor
            pause
            ;;
        7)
            start_tunnel
            pause
            ;;
        8)
            git_status
            pause
            ;;
        9)
            git_commit
            pause
            ;;
        10)
            git_commit_push
            pause
            ;;
        0)
            echo
            echo "Bye."
            exit 0
            ;;
        *)
            echo
            echo "Invalid selection."
            sleep 1
            ;;
    esac
done
