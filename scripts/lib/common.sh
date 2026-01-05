#!/bin/bash
# ============================================
# COMMON LIBRARY - Shared Utilities
# ============================================
# This library provides common utility functions
# used by all automation scripts
#
# Usage: source "${SCRIPT_DIR}/lib/common.sh"
# ============================================

# Prevent multiple inclusion
[[ -n "${COMMON_LIB_LOADED:-}" ]] && return 0
COMMON_LIB_LOADED=true

# --------------------------------------------
# Global Variables
# --------------------------------------------
readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly PROJECT_ROOT="$(cd "${SCRIPT_DIR}/../.." && pwd)"
readonly LIB_DIR="${SCRIPT_DIR}/lib"
readonly LOG_FILE="${PROJECT_ROOT}/logs/automation.log"

# ANSI color codes
readonly COLOR_RED='\033[0;31m'
readonly COLOR_GREEN='\033[0;32m'
readonly COLOR_YELLOW='\033[1;33m'
readonly COLOR_BLUE='\033[0;34m'
readonly COLOR_MAGENTA='\033[0;35m'
readonly COLOR_CYAN='\033[0;36m'
readonly COLOR_RESET='\033[0m'

# --------------------------------------------
# Logging Functions
# --------------------------------------------

# Log info message
log_info() {
  local message="$1"
  echo -e "${COLOR_BLUE}[INFO]${COLOR_RESET} ${message}" >&2
  echo "$(date '+%Y-%m-%d %H:%M:%S') [INFO] ${message}" >> "${LOG_FILE}"
}

# Log success message
log_success() {
  local message="$1"
  echo -e "${COLOR_GREEN}[✓]${COLOR_RESET} ${message}" >&2
  echo "$(date '+%Y-%m-%d %H:%M:%S') [SUCCESS] ${message}" >> "${LOG_FILE}"
}

# Log warning message
log_warning() {
  local message="$1"
  echo -e "${COLOR_YELLOW}[!]${COLOR_RESET} ${message}" >&2
  echo "$(date '+%Y-%m-%d %H:%M:%S') [WARNING] ${message}" >> "${LOG_FILE}"
}

# Log error message
log_error() {
  local message="$1"
  echo -e "${COLOR_RED}[✗]${COLOR_RESET} ${message}" >&2
  echo "$(date '+%Y-%m-%d %H:%M:%S') [ERROR] ${message}" >> "${LOG_FILE}"
}

# Log debug message (only if DEBUG mode enabled)
log_debug() {
  local message="$1"
  if [[ "${DEBUG:-false}" == "true" ]]; then
    echo -e "${COLOR_CYAN}[DEBUG]${COLOR_RESET} ${message}" >&2
    echo "$(date '+%Y-%m-%d %H:%M:%S') [DEBUG] ${message}" >> "${LOG_FILE}"
  fi
}

# --------------------------------------------
# Error Handling
# --------------------------------------------

# Exit with error message
die() {
  local message="$1"
  local exit_code="${2:-1}"
  log_error "${message}"
  exit "${exit_code}"
}

# Check if last command failed
check_fail() {
  local exit_code=$?
  if [[ ${exit_code} -ne 0 ]]; then
    local message="${1:-Command failed with exit code ${exit_code}}"
    die "${message}" "${exit_code}"
  fi
}

# --------------------------------------------
# Confirmation Prompts
# --------------------------------------------

# Ask user for confirmation (returns 0 for yes, 1 for no)
confirm() {
  local prompt="$1"
  local default="${2:-n}"

  if [[ "${AUTO_CONFIRM:-false}" == "true" ]]; then
    return 0
  fi

  local prompt_str="${prompt}"
  if [[ "${default}" == "y" ]]; then
    prompt_str="${prompt_str} [Y/n]"
  else
    prompt_str="${prompt_str} [y/N]"
  fi

  while true; do
    read -rp "${prompt_str}: " response
    response="${response:-${default}}"

    case "${response}" in
      [Yy]|[Yy][Ee][Ss])
        return 0
        ;;
      [Nn]|[Nn][Oo])
        return 1
        ;;
      *)
        echo "Please answer yes or no."
        ;;
    esac
  done
}

# --------------------------------------------
# String Utilities
# --------------------------------------------

# Trim whitespace from string
trim() {
  local var="$1"
  var="${var#"${var%%[![:space:]]*}"}"
  var="${var%"${var##*[![:space:]]}"}"
  printf '%s' "${var}"
}

# Convert string to lowercase
to_lower() {
  local str="$1"
  echo "${str}" | tr '[:upper:]' '[:lower:]'
}

# Convert string to uppercase
to_upper() {
  local str="$1"
  echo "${str}" | tr '[:lower:]' '[:upper:]'
}

# Generate slug from title
generate_slug() {
  local title="$1"
  # Convert to lowercase, replace spaces with hyphens, remove special chars
  echo "${title}" | tr '[:upper:]' '[:lower:]' | sed 's/[^a-z0-9]/-/g' | sed 's/-\+/-/g' | sed 's/^-\|-$//g'
}

# --------------------------------------------
# Array Utilities
# --------------------------------------------

# Check if array contains value
array_contains() {
  local needle="$1"
  shift
  local haystack=("$@")

  local item
  for item in "${haystack[@]}"; do
    [[ "${item}" == "${needle}" ]] && return 0
  done
  return 1
}

# --------------------------------------------
# File Utilities
# --------------------------------------------

# Check if file exists and is readable
file_exists() {
  local file="$1"
  [[ -f "${file}" && -r "${file}" ]]
}

# Check if directory exists
dir_exists() {
  local dir="$1"
  [[ -d "${dir}" ]]
}

# Create directory if it doesn't exist
ensure_dir() {
  local dir="$1"
  if [[ ! -d "${dir}" ]]; then
    mkdir -p "${dir}" || die "Failed to create directory: ${dir}"
    log_debug "Created directory: ${dir}"
  fi
}

# --------------------------------------------
# Command Utilities
# --------------------------------------------

# Check if command is available
command_exists() {
  command -v "$1" &>/dev/null
}

# Require a command to be available
require_command() {
  local cmd="$1"
  if ! command_exists "${cmd}"; then
    die "Required command not found: ${cmd}. Please install it first."
  fi
}

# --------------------------------------------
# Validation Utilities
# --------------------------------------------

# Validate category by checking if directory exists
validate_category() {
  local category="$1"
  local category_dir="${CONTENT_DIR}/${category}"

  if [[ -d "${category_dir}" ]]; then
    return 0
  else
    log_error "Invalid category: ${category}"
    log_error "Category directory does not exist: ${category_dir}"
    return 1
  fi
}

# Validate title (not empty, reasonable length)
validate_title() {
  local title="$1"

  if [[ -z "${title}" ]]; then
    log_error "Title cannot be empty"
    return 1
  fi

  local title_len=${#title}
  if [[ ${title_len} -lt 5 ]]; then
    log_error "Title too short (minimum 5 characters)"
    return 1
  fi

  if [[ ${title_len} -gt 100 ]]; then
    log_error "Title too long (maximum 100 characters)"
    return 1
  fi

  return 0
}

# --------------------------------------------
# Git Utilities
# --------------------------------------------

# Check if we're in a git repository
is_git_repo() {
  git rev-parse --git-dir >/dev/null 2>&1
}

# Get current git branch
get_git_branch() {
  git branch --show-current
}

# Check if git working directory is clean
is_git_clean() {
  git diff-index --quiet HEAD -- 2>/dev/null
}

# --------------------------------------------
# Hugo Utilities
# --------------------------------------------

# Check if Hugo is available
check_hugo() {
  require_command "hugo"

  local hugo_version
  hugo_version=$(hugo version | grep -oP 'v\K[0-9.]+' | head -1)
  log_debug "Hugo version: ${hugo_version}"
}

# Build site with Hugo
hugo_build() {
  local mode="${1:-production}"  # production|drafts
  local minify="${2:-true}"

  local hugo_cmd="hugo"

  if [[ "${mode}" == "drafts" ]]; then
    hugo_cmd="${hugo_cmd} -D"
  fi

  if [[ "${minify}" == "true" ]]; then
    hugo_cmd="${hugo_cmd} --minify"
  fi

  log_info "Building site: ${hugo_cmd}"
  ${hugo_cmd} || die "Hugo build failed"

  log_success "Site built successfully"
}

# --------------------------------------------
# Progress Indicators
# --------------------------------------------

# Show progress bar (simple text-based)
show_progress() {
  local current="$1"
  local total="$2"
  local width=50
  local percent=$((current * 100 / total))
  local filled=$((width * current / total))

  printf "\r["
  local i
  for ((i=0; i<filled; i++)); do
    printf "="
  done
  for ((i=filled; i<width; i++)); do
    printf " "
  done
  printf "] %d%% (%d/%d)" "${percent}" "${current}" "${total}"
}

# Complete progress bar
complete_progress() {
  local total="$1"
  show_progress "${total}" "${total}"
  echo ""
}

# --------------------------------------------
# Configuration Loader
# --------------------------------------------

# Load .env file if it exists
load_env() {
  local env_file="${PROJECT_ROOT}/.env"

  if [[ -f "${env_file}" ]]; then
    # Load .env file, but be careful with security
    set -a
    source "${env_file}"
    set +a
    log_debug "Loaded environment from ${env_file}"
  else
    log_warning "No .env file found at ${env_file}"
  fi
}

# Get config value (from .env or default)
get_config() {
  local key="$1"
  local default_value="${2:-}"

  # Check if variable is set
  if [[ -n "${!key:-}" ]]; then
    echo "${!key}"
  else
    echo "${default_value}"
  fi
}

# --------------------------------------------
# Cleanup Utilities
# --------------------------------------------

# Cleanup function for trap
cleanup() {
  local exit_code=$?

  # Remove lock file if it exists
  if [[ -f "${AUTOMATION_LOCK_FILE:-}" ]]; then
    rm -f "${AUTOMINATION_LOCK_FILE}"
    log_debug "Removed lock file"
  fi

  # Other cleanup can go here

  if [[ ${exit_code} -eq 0 ]]; then
    log_info "Script completed successfully"
  else
    log_error "Script failed with exit code ${exit_code}"
  fi

  exit ${exit_code}
}

# Set up trap for cleanup
trap cleanup EXIT INT TERM

# --------------------------------------------
# Initialization
# --------------------------------------------

# Ensure log directory exists
ensure_dir "${PROJECT_ROOT}/logs"

# Load environment
load_env

# Log script start
log_debug "Common library loaded successfully"
log_debug "Project root: ${PROJECT_ROOT}"
log_debug "Script directory: ${SCRIPT_DIR}"

# ============================================
# END OF COMMON LIBRARY
# ============================================
