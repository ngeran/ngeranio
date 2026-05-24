#!/bin/bash
set -e

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PORT=1313
IMAGE="klakegg/hugo:ext"
CONTAINER_NAME="ngeranio-dev"

show_help() {
  cat << EOF
ngeran[io] Dev Environment

Usage: ${0##*/} <command> [options]

Commands:
  start     Start Hugo dev server (Docker)
  stop      Stop the dev container
  status    Check if dev container is running
  build     Build CSS (Tailwind)
  shell     Open a shell inside the dev container
  logs      Tail container logs
  clean     Remove dev container and rebuild

Options:
  --port PORT    Port for dev server (default: 1313)
  --theme NAME   Theme to use (default: current hugo.toml setting)
  --help         Show this help

Examples:
  ${0##*/} start
  ${0##*/} start --port 8080
  ${0##*/} start --theme vector
  ${0##*/} stop
  ${0##*/} build
  ${0##*/} shell

EOF
}

check_docker() {
  if ! command -v docker &>/dev/null; then
    echo "ERROR: Docker is not installed or not in PATH."
    echo "       Install it: https://docs.docker.com/get-docker/"
    exit 1
  fi
  if ! docker info &>/dev/null 2>&1; then
    echo "ERROR: Docker daemon is not running."
    echo "       Start it: sudo systemctl start docker"
    exit 1
  fi
}

get_current_theme() {
  awk -F"'" '/^theme/{print $2}' "$REPO_ROOT/hugo.toml" 2>/dev/null || echo "unknown"
}

switch_theme() {
  local theme="$1"
  if [ -n "$theme" ]; then
    sed -i "s/^theme = .*/theme = '$theme'/" "$REPO_ROOT/hugo.toml"
    echo "Switched theme to: $theme"
  fi
}

cmd_start() {
  check_docker

  if docker ps -a --format '{{.Names}}' | grep -q "^${CONTAINER_NAME}$"; then
    echo "Container already exists. Stopping and removing..."
    docker rm -f "$CONTAINER_NAME" &>/dev/null
  fi

  echo ""
  echo "========================================="
  echo "  ngeran[io] Dev Server"
  echo "========================================="
  echo "  Theme:    $(get_current_theme)"
  echo "  Port:     $PORT"
  echo "  URL:      http://localhost:$PORT"
  echo "========================================="
  echo ""

  docker run -d \
    --name "$CONTAINER_NAME" \
    -v "$REPO_ROOT:/src" \
    -p "$PORT:1313" \
    "$IMAGE" \
    server -D --bind 0.0.0.0

  echo ""
  echo "Waiting for server..."
  for i in $(seq 1 15); do
    if curl -s "http://localhost:$PORT" >/dev/null 2>&1; then
      echo ""
      echo "Server is live at http://localhost:$PORT"
      echo ""
      echo "Commands:"
      echo "  ./dev.sh stop    - Stop the server"
      echo "  ./dev.sh logs    - View live logs"
      echo "  ./dev.sh shell   - Open shell in container"
      echo ""
      return 0
    fi
    sleep 1
    printf "."
  done

  echo ""
  echo "Server may still be starting. Check logs: ./dev.sh logs"
}

cmd_stop() {
  if docker ps -a --format '{{.Names}}' | grep -q "^${CONTAINER_NAME}$"; then
    docker rm -f "$CONTAINER_NAME" &>/dev/null
    echo "Dev container stopped and removed."
  else
    echo "No dev container running."
  fi
}

cmd_status() {
  if docker ps --format '{{.Names}}' | grep -q "^${CONTAINER_NAME}$"; then
    echo "Dev container is RUNNING"
    echo "  URL:   http://localhost:$PORT"
    echo "  Theme: $(get_current_theme)"
    echo "  Image: $IMAGE"
  elif docker ps -a --format '{{.Names}}' | grep -q "^${CONTAINER_NAME}$"; then
    echo "Dev container is STOPPED"
    echo "  Start it: ./dev.sh start"
  else
    echo "No dev container found."
    echo "  Start one: ./dev.sh start"
  fi
}

cmd_build() {
  echo "Building Tailwind CSS..."
  cd "$REPO_ROOT"

  if [ ! -d "node_modules/tailwindcss" ]; then
    echo "Installing Tailwind CSS..."
    npm install -D tailwindcss@3 @tailwindcss/typography
  fi

  local theme_dir="$REPO_ROOT/themes/$(get_current_theme)"
  if [ -f "$theme_dir/tailwind.config.js" ]; then
    cd "$theme_dir"
    npx tailwindcss -i src/input.css -o assets/css/styles.css --minify
    echo "CSS built: $theme_dir/assets/css/styles.css"
  else
    echo "No tailwind.config.js found for theme: $(get_current_theme)"
    exit 1
  fi
}

cmd_shell() {
  check_docker
  if docker ps --format '{{.Names}}' | grep -q "^${CONTAINER_NAME}$"; then
    docker exec -it "$CONTAINER_NAME" /bin/sh
  else
    echo "Dev container is not running. Start it first: ./dev.sh start"
    exit 1
  fi
}

cmd_logs() {
  if docker ps --format '{{.Names}}' | grep -q "^${CONTAINER_NAME}$"; then
    docker logs -f "$CONTAINER_NAME"
  else
    echo "Dev container is not running."
    exit 1
  fi
}

cmd_clean() {
  cmd_stop
  echo "Pulling latest Hugo image..."
  docker pull "$IMAGE"
  echo "Done. Run ./dev.sh start to begin."
}

# ============================================
# Parse Arguments
# ============================================

if [ $# -eq 0 ]; then
  show_help
  exit 0
fi

COMMAND=""
while [[ $# -gt 0 ]]; do
  case "$1" in
    start|stop|status|build|shell|logs|clean)
      COMMAND="$1"
      shift
      ;;
    --port)
      PORT="$2"
      shift 2
      ;;
    --theme)
      switch_theme "$2"
      shift 2
      ;;
    --help|-h)
      show_help
      exit 0
      ;;
    *)
      echo "Unknown option: $1"
      show_help
      exit 1
      ;;
  esac
done

case "$COMMAND" in
  start)   cmd_start   ;;
  stop)    cmd_stop    ;;
  status)  cmd_status  ;;
  build)   cmd_build   ;;
  shell)   cmd_shell   ;;
  logs)    cmd_logs    ;;
  clean)   cmd_clean   ;;
  "")      show_help   ;;
esac
