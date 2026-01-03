#!/bin/bash
# ============================================
# PREVIEW - Enhanced with Phase 1 Libraries
# ============================================
# Start Hugo development server with drafts
# Usage: ./scripts/preview.sh [options]
# ============================================

set -o pipefail

# ============================================
# LIBRARY SETUP
# ============================================
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"

# Source Phase 1 libraries
source "${PROJECT_ROOT}/scripts/lib/common.sh"
source "${PROJECT_ROOT}/scripts/lib/logger.sh"
source "${PROJECT_ROOT}/scripts/lib/error-handler.sh"
source "${PROJECT_ROOT}/scripts/lib/config.sh"

# ============================================
# CONFIGURATION
# ============================================
BUILD_PREVIEW_PORT=$(get_config "BUILD_PREVIEW_PORT" "1313")
BUILD_PREVIEW_BIND=$(get_config "BUILD_PREVIEW_BIND" "127.0.0.1")
BUILD_OUTPUT_DIR=$(get_config "BUILD_OUTPUT_DIR" "public")

# ============================================
# FUNCTIONS
# ============================================

show_usage() {
  cat << EOF
Usage: ${0##*/} [options]

Options:
  --port PORT      Custom port (default: ${BUILD_PREVIEW_PORT})
  --validate       Validate all drafts before starting
  --category CAT   Preview only specific category
  --help           Show this help message

Examples:
  ${0##*/}
  ${0##*/} --port 8080
  ${0##*/} --validate
  ${0##*/} --category ospf

EOF
  exit 0
}

validate_drafts() {
  log_build "INFO" "Validating all draft posts..."

  local quality_gate_script="${PROJECT_ROOT}/scripts/quality-gate.sh"
  local validation_output

  if validation_output=$(bash "$quality_gate_script" validate-drafts 2>&1); then
    log_build "SUCCESS" "✓ All drafts validated successfully"
  else
    log_build "WARNING" "⚠ Some drafts have validation errors"
    log_build "INFO" "$validation_output"
  fi

  echo ""
}

start_server() {
  local port="$1"
  local validate="$2"
  local category="$3"

  log_build "INFO" "========================================"
  log_build "INFO" "Starting Hugo Development Server"
  log_build "INFO" "========================================"
  log_build "INFO" "Port: ${port}"
  log_build "INFO" "Bind: ${BUILD_PREVIEW_BIND}"
  log_build "INFO" "Drafts: Enabled"
  log_build "INFO" ""

  # Validate if requested
  if [[ "$validate" == "true" ]]; then
    validate_drafts
  fi

  log_build "INFO" "Server starting..."
  log_build "INFO" "URL: http://${BUILD_PREVIEW_BIND}:${port}"
  log_build "INFO" ""
  log_build "INFO" "Press Ctrl+C to stop"
  log_build "INFO" "========================================"
  log_build "INFO" ""

  # Build the hugo command
  local hugo_cmd="hugo server -D"
  hugo_cmd="${hugo_cmd} --bind ${BUILD_PREVIEW_BIND}"
  hugo_cmd="${hugo_cmd} --port ${port}"

  # Add minification flag if configured
  local minify
  minify=$(get_config "BUILD_MINIFY" "true")
  if [[ "$minify" == "true" ]]; then
    hugo_cmd="${hugo_cmd} --minify"
  fi

  # Start the server
  eval "$hugo_cmd"
}

# ============================================
# MAIN
# ============================================

main() {
  local port="$BUILD_PREVIEW_PORT"
  local validate="false"
  local category=""

  # Parse arguments
  while [[ $# -gt 0 ]]; do
    case "$1" in
      --port)
        port="$2"
        shift 2
        ;;
      --validate)
        validate="true"
        shift
        ;;
      --category)
        category="$2"
        shift 2
        ;;
      --help|-h)
        show_usage
        ;;
      *)
        log_build "ERROR" "Unknown option: $1"
        echo ""
        show_usage
        ;;
    esac
  done

  # Start server
  start_server "$port" "$validate" "$category"
}

# Run main
main "$@"

