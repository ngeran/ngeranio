#!/bin/bash
# ============================================
# LOGGER LIBRARY - Advanced Logging System
# ============================================
# Provides advanced logging capabilities with
# multiple log levels, log rotation, and structured output
#
# Usage: source "${SCRIPT_DIR}/lib/logger.sh"
# ============================================

# Prevent multiple inclusion
[[ -n "${LOGGER_LIB_LOADED:-}" ]] && return 0
LOGGER_LIB_LOADED=true

# Source common library for base functions
source "$(dirname "${BASH_SOURCE[0]}")/common.sh"

# --------------------------------------------
# Log Levels
# --------------------------------------------
readonly LOG_LEVEL_DEBUG=0
readonly LOG_LEVEL_INFO=1
readonly LOG_LEVEL_WARNING=2
readonly LOG_LEVEL_ERROR=3
readonly LOG_LEVEL_CRITICAL=4

# Current log level (default: INFO)
CURRENT_LOG_LEVEL="${LOG_LEVEL_INFO}"

# --------------------------------------------
# Log File Configuration
# --------------------------------------------
LOG_DIR="${PROJECT_ROOT}/logs"
MAIN_LOG_FILE="${LOG_DIR}/automation.log"
QUALITY_LOG_FILE="${LOG_DIR}/quality-gate.log"
BUILD_LOG_FILE="${LOG_DIR}/build.log"
DEPLOYMENT_LOG_FILE="${LOG_DIR}/deployment.log"
ROLLBACK_LOG_FILE="${LOG_DIR}/rollback.log"

# --------------------------------------------
# Initialize Logging System
# --------------------------------------------

init_logging() {
  # Ensure log directory exists
  ensure_dir "${LOG_DIR}"

  # Create log files if they don't exist
  touch "${MAIN_LOG_FILE}"
  touch "${QUALITY_LOG_FILE}"
  touch "${BUILD_LOG_FILE}"
  touch "${DEPLOYMENT_LOG_FILE}"
  touch "${ROLLBACK_LOG_FILE}"

  # Set permissions
  chmod 644 "${LOG_DIR}"/*.log 2>/dev/null || true

  log_debug "Logging system initialized"
}

# --------------------------------------------
# Structured Logging Functions
# --------------------------------------------

# Core logging function
_log() {
  local level="$1"
  local level_num="$2"
  local component="$3"
  local message="$4"
  local log_file="${5:-${MAIN_LOG_FILE}}"

  # Check if we should log this level
  if [[ ${level_num} -lt ${CURRENT_LOG_LEVEL} ]]; then
    return 0
  fi

  local timestamp
  timestamp="$(date '+%Y-%m-%d %H:%M:%S')"

  # Format: YYYY-MM-DD HH:MM:SS [LEVEL] [COMPONENT] Message
  local log_entry="[${timestamp}] [${level}] [${component}] ${message}"

  # Write to log file
  echo "${log_entry}" >> "${log_file}"

  # Also write to stderr for visibility
  echo -e "${log_entry}" >&2
}

# Debug level logging
log_debug() {
  _log "DEBUG" ${LOG_LEVEL_DEBUG} "GLOBAL" "$1"
}

# Info level logging (to specific log file)
log_info_to() {
  local component="$1"
  local message="$2"
  local log_file="${3:-${MAIN_LOG_FILE}}"

  _log "INFO" ${LOG_LEVEL_INFO} "${component}" "${message}" "${log_file}"
}

# Warning level logging
log_warn_to() {
  local component="$1"
  local message="$2"
  local log_file="${3:-${MAIN_LOG_FILE}}"

  _log "WARNING" ${LOG_LEVEL_WARNING} "${component}" "${message}" "${log_file}"
}

# Error level logging
log_error_to() {
  local component="$1"
  local message="$2"
  local log_file="${3:-${MAIN_LOG_FILE}}"

  _log "ERROR" ${LOG_LEVEL_ERROR} "${component}" "${message}" "${log_file}"
}

# Critical level logging
log_critical() {
  local component="$1"
  local message="$2"
  local log_file="${3:-${MAIN_LOG_FILE}}"

  _log "CRITICAL" ${LOG_LEVEL_CRITICAL} "${component}" "${message}" "${log_file}"
}

# --------------------------------------------
# Component-Specific Logging
# --------------------------------------------

# Content Manager logging
log_content() {
  local level="$1"
  local message="$2"
  log_info_to "ContentManager" "[${level}] ${message}"
}

# Quality Gate logging
log_quality() {
  local level="$1"
  local message="$2"
  log_info_to "QualityGate" "[${level}] ${message}" "${QUALITY_LOG_FILE}"
}

# Build logging
log_build() {
  local level="$1"
  local message="$2"
  log_info_to "Build" "[${level}] ${message}" "${BUILD_LOG_FILE}"
}

# Git automation logging
log_git() {
  local level="$1"
  local message="$2"
  log_info_to "GitAutomation" "[${level}] ${message}"
}

# Deployment logging
log_deployment() {
  local level="$1"
  local message="$2"
  log_info_to "Deployment" "[${level}] ${message}" "${DEPLOYMENT_LOG_FILE}"
}

# Rollback logging
log_rollback() {
  local level="$1"
  local message="$2"
  log_info_to "Rollback" "[${level}] ${message}" "${ROLLBACK_LOG_FILE}"
}

# Orchestrator logging
log_orchestrator() {
  local level="$1"
  local message="$2"
  log_info_to "Orchestrator" "[${level}] ${message}"
}

# --------------------------------------------
# Set Log Level
# --------------------------------------------

set_log_level() {
  local level="$1"
  local level_upper
  level_upper="$(to_upper "${level}")"

  case "${level_upper}" in
    DEBUG)
      CURRENT_LOG_LEVEL=${LOG_LEVEL_DEBUG}
      ;;
    INFO)
      CURRENT_LOG_LEVEL=${LOG_LEVEL_INFO}
      ;;
    WARNING|WARN)
      CURRENT_LOG_LEVEL=${LOG_LEVEL_WARNING}
      ;;
    ERROR)
      CURRENT_LOG_LEVEL=${LOG_LEVEL_ERROR}
      ;;
    CRITICAL)
      CURRENT_LOG_LEVEL=${LOG_LEVEL_CRITICAL}
      ;;
    *)
      log_warning "Invalid log level: ${level}. Using INFO."
      CURRENT_LOG_LEVEL=${LOG_LEVEL_INFO}
      ;;
  esac

  log_debug "Log level set to: ${level_upper}"
}

# --------------------------------------------
# Log Rotation
# --------------------------------------------

rotate_logs() {
  local retention_days="${1:-30}"

  log_info "Rotating logs (retention: ${retention_days} days)..."

  # Compress logs older than 1 day
  find "${LOG_DIR}" -name "*.log" -mtime +1 -not -name "*.gz" -exec gzip -q {} \; 2>/dev/null || true

  # Remove compressed logs older than retention days
  find "${LOG_DIR}" -name "*.gz" -mtime +${retention_days} -delete 2>/dev/null || true

  log_success "Log rotation complete"
}

# --------------------------------------------
# Log Retrieval
# --------------------------------------------

# Get recent log entries
get_logs() {
  local log_file="${1:-${MAIN_LOG_FILE}}"
  local lines="${2:-50}"

  if [[ ! -f "${log_file}" ]]; then
    log_error "Log file not found: ${log_file}"
    return 1
  fi

  tail -n "${lines}" "${log_file}"
}

# Get logs since specific time
get_logs_since() {
  local since="$1"
  local log_file="${2:-${MAIN_LOG_FILE}}"

  if [[ ! -f "${log_file}" ]]; then
    log_error "Log file not found: ${log_file}"
    return 1
  fi

  # Use journalctl syntax for time
  journalctl --since "${since}" -f "${log_file}" 2>/dev/null || \
    grep "$(date -d "${since}" '+%Y-%m-%d')" "${log_file}" || \
    tail -n 100 "${log_file}"
}

# Search logs for pattern
search_logs() {
  local pattern="$1"
  local log_file="${2:-${MAIN_LOG_FILE}}"

  if [[ ! -f "${log_file}" ]]; then
    log_error "Log file not found: ${log_file}"
    return 1
  fi

  grep -i "${pattern}" "${log_file}" || log_warning "No matches found for: ${pattern}"
}

# --------------------------------------------
# Log Analysis
# --------------------------------------------

# Count log entries by level
count_log_levels() {
  local log_file="${1:-${MAIN_LOG_FILE}}"

  if [[ ! -f "${log_file}" ]]; then
    log_error "Log file not found: ${log_file}"
    return 1
  fi

  echo "Log Level Summary for: ${log_file}"
  echo "================================"

  for level in CRITICAL ERROR WARNING INFO DEBUG; do
    local count
    count=$(grep -c "\[${level}\]" "${log_file}" 2>/dev/null || echo "0")
    echo "  ${level}: ${count}"
  done
}

# Show recent errors
show_recent_errors() {
  local log_file="${1:-${MAIN_LOG_FILE}}"
  local count="${2:-10}"

  log_info "Recent ${count} errors from ${log_file}:"
  grep "\[ERROR\]" "${log_file}" | tail -n "${count}"
}

# --------------------------------------------
# Log Statistics
# --------------------------------------------

# Get log file size
get_log_size() {
  local log_file="${1:-${MAIN_LOG_FILE}}"

  if [[ ! -f "${log_file}" ]]; then
    echo "0"
    return 1
  fi

  du -h "${log_file}" | cut -f1
}

# Get total logs size
get_total_logs_size() {
  du -sh "${LOG_DIR}" 2>/dev/null | cut -f1 || echo "0"
}

# --------------------------------------------
# Log Cleanup
# --------------------------------------------

# Clear all logs
clear_logs() {
  local confirm="${1:-false}"

  if [[ "${confirm}" != "true" ]]; then
    if ! confirm "This will delete all log files. Continue?"; then
      log_info "Log cleanup cancelled"
      return 0
    fi
  fi

  log_info "Clearing all logs..."
  rm -rf "${LOG_DIR}"/*.log
  init_logging
  log_success "All logs cleared"
}

# Archive old logs
archive_logs() {
  local archive_dir="${LOG_DIR}/archive"
  local archive_date
  archive_date="$(date '+%Y%m%d')"

  ensure_dir "${archive_dir}"

  local archive_file="${archive_dir}/logs-${archive_date}.tar.gz"

  log_info "Archiving logs to: ${archive_file}"
  tar -czf "${archive_file}" -C "${LOG_DIR}" ./*.log 2>/dev/null || true

  # Clear original logs
  rm -f "${LOG_DIR}"/*.log
  init_logging

  log_success "Logs archived successfully"
}

# --------------------------------------------
# Initialization
# --------------------------------------------

# Initialize logging system
init_logging

# Log logger library load
log_debug "Logger library loaded successfully"

# ============================================
# END OF LOGGER LIBRARY
# ============================================
