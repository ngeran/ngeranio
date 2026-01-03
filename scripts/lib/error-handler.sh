#!/bin/bash
# ============================================
# ERROR HANDLER LIBRARY - Error Management
# ============================================
# Provides error trapping, handling, and recovery
# mechanisms for robust automation scripts
#
# Usage: source "${SCRIPT_DIR}/lib/error-handler.sh"
# ============================================

# Prevent multiple inclusion
[[ -n "${ERROR_HANDLER_LIB_LOADED:-}" ]] && return 0
ERROR_HANDLER_LIB_LOADED=true

# Source common library for base functions
source "$(dirname "${BASH_SOURCE[0]}")/common.sh"

# --------------------------------------------
# Error Codes
# --------------------------------------------
readonly E_SUCCESS=0
readonly E_GENERAL_ERROR=1
readonly E_INVALID_INPUT=2
readonly E_FILE_NOT_FOUND=3
readonly E_PERMISSION_DENIED=4
readonly E_COMMAND_NOT_FOUND=5
readonly E_BUILD_FAILED=10
readonly E_VALIDATION_FAILED=11
readonly E_GIT_ERROR=20
readonly E_DEPLOYMENT_FAILED=30
readonly E_ROLLBACK_FAILED=31

# --------------------------------------------
# Error Context
# --------------------------------------------
ERROR_CONTEXT=""
ERROR_LINE=0
ERROR_COMMAND=""
ERROR_BACKTRACE=""

# --------------------------------------------
# Error Handler Function
# --------------------------------------------

# Main error handler (called by trap)
error_handler() {
  local line_number=$1
  local error_code=$2
  local error_command="$3"

  # Don't handle EXIT (error code 0)
  if [[ ${error_code} -eq 0 ]]; then
    return 0
  fi

  # Store error context
  ERROR_LINE=${line_number}
  ERROR_COMMAND="${error_command}"

  # Build backtrace
  ERROR_BACKTRACE=$(get_backtrace)

  # Log the error
  log_error_to "ErrorHandler" "Script failed at line ${line_number}"
  log_error_to "ErrorHandler" "Exit code: ${error_code}"
  log_error_to "ErrorHandler" "Command: ${error_command}"
  log_error_to "ErrorHandler" "Backtrace: ${ERROR_BACKTRACE}"

  # Attempt cleanup
  cleanup_on_error

  # Suggest recovery
  suggest_recovery "${error_code}"

  # Exit with original error code
  exit ${error_code}
}

# Get backtrace information
get_backtrace() {
  local backtrace=""

  # Get function call stack
  local frame=0
  while caller ${frame} >/dev/null 2>&1; do
    local info
    info=$(caller ${frame})
    local line_no=${info%% *}
    local func=${info#* }
    func=${func#* }
    local file=${info#* }
    file=${file#* }
    file=${file%% *}

    backtrace="${backtrace}  at ${file}:${line_no} in ${func}()"
    ((frame++))
  done

  echo "${backtrace}"
}

# --------------------------------------------
# Cleanup on Error
# --------------------------------------------

# Cleanup function called when error occurs
cleanup_on_error() {
  log_info_to "ErrorHandler" "Cleaning up after error..."

  # Remove lock file if exists
  local lock_file="${AUTOMATION_LOCK_FILE:-/tmp/ai-automation.lock}"
  if [[ -f "${lock_file}" ]]; then
    rm -f "${lock_file}"
    log_debug "Removed lock file: ${lock_file}"
  fi

  # Kill any background processes
  # (Add specific cleanup as needed)

  # Note: Don't exit here, let error_handler do that
}

# --------------------------------------------
# Recovery Suggestions
# --------------------------------------------

# Suggest recovery actions based on error code
suggest_recovery() {
  local error_code="$1"

  log_info_to "ErrorHandler" "Suggested recovery actions:"

  case ${error_code} in
    ${E_INVALID_INPUT})
      echo "  → Check your input parameters"
      echo "  → Verify file paths are correct"
      echo "  → Ensure all required fields are provided"
      ;;

    ${E_FILE_NOT_FOUND})
      echo "  → Check if the file exists"
      echo "  → Verify the file path is correct"
      echo "  → Check file permissions"
      ;;

    ${E_PERMISSION_DENIED})
      echo "  → Check file/directory permissions"
      echo "  → Ensure you have write access"
      echo "  → Try running with appropriate privileges"
      ;;

    ${E_COMMAND_NOT_FOUND})
      echo "  → Install the missing command"
      echo "  → Check your PATH environment variable"
      ;;

    ${E_BUILD_FAILED})
      echo "  → Check Hugo version compatibility"
      echo "  → Review build error messages above"
      echo "  → Verify content file syntax (frontmatter, markdown)"
      echo "  → Try: hugo build --verbose for more details"
      ;;

    ${E_VALIDATION_FAILED})
      echo "  → Review validation errors in quality-gate.log"
      echo "  → Fix frontmatter syntax errors"
      echo "  → Ensure all required fields are present"
      echo "  → Check image paths and link references"
      ;;

    ${E_GIT_ERROR})
      echo "  → Check git status: git status"
      echo "  → Verify GitHub authentication"
      echo "  → Check network connectivity"
      echo "  → Review git configuration"
      ;;

    ${E_DEPLOYMENT_FAILED})
      echo "  → Check Cloudflare dashboard for build logs"
      echo "  → Verify environment variables are set"
      echo "  → Consider rollback if site is broken"
      echo "  → Review recent commits"
      ;;

    ${E_ROLLBACK_FAILED})
      echo "  → Manual rollback may be required"
      echo "  → Check git log: git log --oneline -5"
      echo "  → Use Cloudflare dashboard to rollback"
      ;;

    *)
      echo "  → Review logs in logs/ directory"
      echo "  → Check system resources and permissions"
      echo "  → Try running with DEBUG=true for more details"
      ;;
  esac
}

# --------------------------------------------
# Error Trapping Setup
# --------------------------------------------

# Enable error trapping
enable_error_trapping() {
  set -Eeuo pipefail
  trap 'error_handler ${LINENO} $? "$BASH_COMMAND"' ERR
  trap 'error_handler ${LINENO} $? "$BASH_COMMAND"' INT
  trap 'error_handler ${LINENO} $? "$BASH_COMMAND"' TERM
  log_debug "Error trapping enabled"
}

# Disable error trapping (for specific operations)
disable_error_trapping() {
  set +Eeuo pipefail
  trap - ERR
  trap - INT
  trap - TERM
  log_debug "Error trapping disabled"
}

# --------------------------------------------
# Safe Execution Wrappers
# --------------------------------------------

# Run command safely with error handling
run_safe() {
  local cmd="$1"
  local error_msg="${2:-Command failed}"

  log_debug "Running command: ${cmd}"

  if eval "${cmd}"; then
    log_debug "Command succeeded: ${cmd}"
    return 0
  else
    local exit_code=$?
    log_error "${error_msg} (exit code: ${exit_code})"
    log_error "Command was: ${cmd}"
    return ${exit_code}
  fi
}

# Run command with retry
run_with_retry() {
  local max_attempts="$1"
  shift
  local cmd="$@"
  local attempt=1

  while [[ ${attempt} -le ${max_attempts} ]]; do
    log_debug "Attempt ${attempt}/${max_attempts}: ${cmd}"

    if eval "${cmd}"; then
      log_info "Command succeeded on attempt ${attempt}"
      return 0
    fi

    ((attempt++))
    if [[ ${attempt} -le ${max_attempts} ]]; then
      local wait_time=$((attempt * 2))
      log_warning "Command failed, retrying in ${wait_time}s..."
      sleep "${wait_time}"
    fi
  done

  log_error "Command failed after ${max_attempts} attempts"
  return 1
}

# --------------------------------------------
# Validation Functions
# --------------------------------------------

# Validate required files exist
validate_required_files() {
  local files=("$@")
  local missing_files=()

  for file in "${files[@]}"; do
    if [[ ! -f "${file}" ]]; then
      missing_files+=("${file}")
    fi
  done

  if [[ ${#missing_files[@]} -gt 0 ]]; then
    log_error "Required files not found:"
    for file in "${missing_files[@]}"; do
      log_error "  → ${file}"
    done
    return ${E_FILE_NOT_FOUND}
  fi

  return 0
}

# Validate required directories exist
validate_required_dirs() {
  local dirs=("$@")
  local missing_dirs=()

  for dir in "${dirs[@]}"; do
    if [[ ! -d "${dir}" ]]; then
      missing_dirs+=("${dir}")
    fi
  done

  if [[ ${#missing_dirs[@]} -gt 0 ]]; then
    log_error "Required directories not found:"
    for dir in "${missing_dirs[@]}"; do
      log_error "  → ${dir}"
    done
    return ${E_FILE_NOT_FOUND}
  fi

  return 0
}

# --------------------------------------------
# Safe Exit Functions
# --------------------------------------------

# Exit with success message
exit_success() {
  local message="${1:-Operation completed successfully}"
  log_success "${message}"
  cleanup
  exit ${E_SUCCESS}
}

# Exit with error message
exit_error() {
  local message="$1"
  local error_code="${2:-${E_GENERAL_ERROR}}"
  log_error "${message}"
  cleanup
  exit ${error_code}
}

# --------------------------------------------
# Error Context Management
# --------------------------------------------

# Set error context (useful for debugging)
set_error_context() {
  ERROR_CONTEXT="$1"
  log_debug "Error context set: ${ERROR_CONTEXT}"
}

# Get error context
get_error_context() {
  echo "${ERROR_CONTEXT:-No context}"
}

# --------------------------------------------
# Cleanup Function
# --------------------------------------------

# General cleanup function
cleanup() {
  local exit_code=$?

  if [[ ${exit_code} -eq ${E_SUCCESS} ]]; then
    log_debug "Cleanup: Successful exit"
  else
    log_debug "Cleanup: Error exit (code: ${exit_code})"
  fi

  # Remove lock file
  local lock_file="${AUTOMATION_LOCK_FILE:-}"
  if [[ -n "${lock_file}" && -f "${lock_file}" ]]; then
    rm -f "${lock_file}"
    log_debug "Removed lock file"
  fi

  # Close any open file descriptors
  # (Add specific cleanup as needed)

  return ${exit_code}
}

# --------------------------------------------
# Lock File Management
# --------------------------------------------

# Create lock file to prevent concurrent execution
acquire_lock() {
  local lock_file="${AUTOMATION_LOCK_FILE:-/tmp/ai-automation.lock}"
  local lock_timeout="${1:-3600}"  # Default 1 hour

  # Check if lock already exists
  if [[ -f "${lock_file}" ]]; then
    # Check if lock is stale (older than timeout)
    local lock_age
    lock_age=$(($(date +%s) - $(stat -c %Y "${lock_file}" 2>/dev/null || echo "0")))

    if [[ ${lock_age} -gt ${lock_timeout} ]]; then
      log_warning "Removing stale lock file (${lock_age}s old)"
      rm -f "${lock_file}"
    else
      log_error "Lock file exists: ${lock_file}"
      log_error "Another automation may be running"
      log_error "If this is an error, manually remove: rm ${lock_file}"
      return 1
    fi
  fi

  # Create lock file
  echo "PID: $$" > "${lock_file}"
  echo "Started: $(date '+%Y-%m-%d %H:%M:%S')" >> "${lock_file}"
  log_debug "Lock file created: ${lock_file}"

  # Set trap to remove lock on exit
  trap 'rm -f "${lock_file}"' EXIT

  return 0
}

# --------------------------------------------
# Fatal Error Handler
# --------------------------------------------

# Die with error (critical failure)
fatal() {
  local message="$1"
  local exit_code="${2:-${E_GENERAL_ERROR}}"

  log_critical "FATAL ERROR: ${message}"

  # Attempt cleanup even on fatal error
  cleanup_on_error

  exit ${exit_code}
}

# --------------------------------------------
# Assert Functions
# --------------------------------------------

# Assert condition is true
assert_true() {
  local condition="$1"
  local message="${2:-Assertion failed}"

  if [[ "${condition}" != "true" ]]; then
    fatal "${message}" ${E_GENERAL_ERROR}
  fi
}

# Assert command succeeds
assert_cmd() {
  local cmd="$1"
  local message="${2:-Command failed: ${cmd}}"

  if ! eval "${cmd}" >/dev/null 2>&1; then
    fatal "${message}" ${E_GENERAL_ERROR}
  fi
}

# Assert file exists
assert_file() {
  local file="$1"
  local message="${2:-File not found: ${file}}"

  if [[ ! -f "${file}" ]]; then
    fatal "${message}" ${E_FILE_NOT_FOUND}
  fi
}

# Assert variable is not empty
assert_not_empty() {
  local var_name="$1"
  local var_value="${!var_name}"
  local message="${2:-Variable ${var_name} is empty}"

  if [[ -z "${var_value}" ]]; then
    fatal "${message}" ${E_GENERAL_ERROR}
  fi
}

# --------------------------------------------
# Warning Handler
# --------------------------------------------

# Handle warnings as errors (optional)
warnings_as_errors() {
  local setting="${1:-true}"

  if [[ "${setting}" == "true" ]]; then
    set -W  # Treat warnings as errors
    log_debug "Warnings enabled as errors"
  else
    set +W
    log_debug "Warnings disabled as errors"
  fi
}

# --------------------------------------------
# Signal Handlers
# --------------------------------------------

# Handle interrupt signal (Ctrl+C)
handle_interrupt() {
  log_warning "Script interrupted by user"
  cleanup
  exit 130  # Standard exit code for SIGINT
}

# Handle termination signal
handle_terminate() {
  log_warning "Script received termination signal"
  cleanup
  exit 143  # Standard exit code for SIGTERM
}

# --------------------------------------------
# Initialization
# --------------------------------------------

# Set up signal handlers
trap handle_interrupt INT
trap handle_terminate TERM

# Log error handler library load
log_debug "Error handler library loaded successfully"

# ============================================
# END OF ERROR HANDLER LIBRARY
# ============================================
