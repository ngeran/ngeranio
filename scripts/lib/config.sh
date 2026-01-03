#!/bin/bash
# ============================================
# CONFIG LIBRARY - Configuration Management
# ============================================
# Handles loading, validation, and access to
# configuration values from .env file
#
# Usage: source "${SCRIPT_DIR}/lib/config.sh"
# ============================================

# Prevent multiple inclusion
[[ -n "${CONFIG_LIB_LOADED:-}" ]] && return 0
CONFIG_LIB_LOADED=true

# Source common library
source "$(dirname "${BASH_SOURCE[0]}")/common.sh"

# --------------------------------------------
# Configuration State
# --------------------------------------------
CONFIG_LOADED=false
CONFIG_VALID=false

# --------------------------------------------
# Required Configuration Keys
# --------------------------------------------
REQUIRED_CONFIG_KEYS=(
  "SITE_URL"
  "HUGO_VERSION"
  "GIT_AUTHOR_NAME"
  "GITHUB_REPO"
  "CONTENT_DIR"
)

# --------------------------------------------
# Load Configuration
# --------------------------------------------

# Load configuration from .env file
load_config() {
  local env_file="${PROJECT_ROOT}/.env"

  if [[ ! -f "${env_file}" ]]; then
    log_error "Configuration file not found: ${env_file}"
    return 1
  fi

  log_debug "Loading configuration from ${env_file}"

  # Load .env file (use set -a to export all variables)
  set -a
  source "${env_file}"
  set +a

  CONFIG_LOADED=true
  log_debug "Configuration loaded successfully"

  # Validate configuration
  validate_config

  return 0
}

# --------------------------------------------
# Validate Configuration
# --------------------------------------------

# Validate all required configuration
validate_config() {
  local errors=0

  log_debug "Validating configuration..."

  # Check required keys
  for key in "${REQUIRED_CONFIG_KEYS[@]}"; do
    if [[ -z "${!key:-}" ]]; then
      log_error "Required configuration key missing: ${key}"
      ((errors++))
    fi
  done

  # Validate specific values
  if [[ ${errors} -eq 0 ]]; then
    # Validate HUGO_VERSION format
    if [[ ! "${HUGO_VERSION}" =~ ^[0-9]+\.[0-9]+\.[0-9]+ ]]; then
      log_error "Invalid HUGO_VERSION format: ${HUGO_VERSION}"
      ((errors++))
    fi

    # Validate SITE_URL format
    if [[ ! "${SITE_URL}" =~ ^https?:// ]]; then
      log_error "Invalid SITE_URL format: ${SITE_URL}"
      ((errors++))
    fi

    # Validate directories exist or can be created
    if [[ ! -d "${PROJECT_ROOT}/${CONTENT_DIR}" ]]; then
      log_warning "Content directory does not exist: ${CONTENT_DIR}"
      log_warning "It will be created when needed"
    fi
  fi

  if [[ ${errors} -eq 0 ]]; then
    CONFIG_VALID=true
    log_debug "Configuration validated successfully"
    return 0
  else
    log_error "Configuration validation failed with ${errors} errors"
    CONFIG_VALID=false
    return 1
  fi
}

# --------------------------------------------
# Get Configuration Value
# --------------------------------------------

# Get config value with default fallback
get_config() {
  local key="$1"
  local default_value="${2:-}"

  # Ensure config is loaded
  if [[ "${CONFIG_LOADED}" != "true" ]]; then
    log_warning "Configuration not loaded, loading now..."
    load_config
  fi

  # Get variable value
  local value="${!key:-}"

  # Return value or default
  if [[ -n "${value}" ]]; then
    echo "${value}"
  else
    echo "${default_value}"
  fi
}

# Get required config value (exit if missing)
get_config_required() {
  local key="$1"
  local error_msg="${2:-Required configuration missing: ${key}}"

  local value
  value="$(get_config "${key}")"

  if [[ -z "${value}" ]]; then
    log_error "${error_msg}"
    return 1
  fi

  echo "${value}"
  return 0
}

# --------------------------------------------
# Configuration Display
# --------------------------------------------

# Show all configuration values
show_config() {
  local prefix="${1:-}"

  echo "=========================================="
  echo "Configuration"
  echo "=========================================="

  # Site Configuration
  echo ""
  echo "Site Configuration:"
  echo "  SITE_URL: ${SITE_URL:-not set}"
  echo "  SITE_NAME: ${SITE_NAME:-not set}"
  echo "  HUGO_VERSION: ${HUGO_VERSION:-not set}"
  echo "  HUGO_EXTENDED: ${HUGO_EXTENDED:-not set}"

  # Git Configuration
  echo ""
  echo "Git Configuration:"
  echo "  GIT_AUTHOR_NAME: ${GIT_AUTHOR_NAME:-not set}"
  echo "  GIT_AUTHOR_EMAIL: ${GIT_AUTHOR_EMAIL:-not set}"
  echo "  GITHUB_REPO: ${GITHUB_REPO:-not set}"
  echo "  GITHUB_DEFAULT_BRANCH: ${GITHUB_DEFAULT_BRANCH:-not set}"

  # Content Configuration
  echo ""
  echo "Content Configuration:"
  echo "  CONTENT_DIR: ${CONTENT_DIR:-not set}"
  echo "  MIN_WORD_COUNT: ${MIN_WORD_COUNT:-not set}"
  echo "  VALID_CATEGORIES: ${VALID_CATEGORIES[@]:-not set}"

  # Quality Gate Configuration
  echo ""
  echo "Quality Gate Configuration:"
  echo "  QUALITY_STRICT_MODE: ${QUALITY_STRICT_MODE:-not set}"
  echo "  QUALITY_MIN_WORD_COUNT: ${QUALITY_MIN_WORD_COUNT:-not set}"

  # Build Configuration
  echo ""
  echo "Build Configuration:"
  echo "  BUILD_OUTPUT_DIR: ${BUILD_OUTPUT_DIR:-not set}"
  echo "  BUILD_PREVIEW_PORT: ${BUILD_PREVIEW_PORT:-not set}"
  echo "  BUILD_MINIFY: ${BUILD_MINIFY:-not set}"

  # Deployment Configuration
  echo ""
  echo "Deployment Configuration:"
  echo "  DEPLOY_AUTO_PUSH: ${DEPLOY_AUTO_PUSH:-not set}"
  echo "  DEPLOY_REQUIRE_APPROVAL: ${DEPLOY_REQUIRE_APPROVAL:-not set}"
  echo "  DEPLOY_CREATE_BACKUPS: ${DEPLOY_CREATE_BACKUPS:-not set}"

  # Automation Configuration
  echo ""
  echo "Automation Configuration:"
  echo "  AUTOMATION_LOG_FILE: ${AUTOMATION_LOG_FILE:-not set}"
  echo "  AUTOMATION_LOG_LEVEL: ${AUTOMATION_LOG_LEVEL:-not set}"
  echo "  AUTOMATION_MAX_RETRIES: ${AUTOMATION_MAX_RETRIES:-not set}"

  echo ""
  echo "=========================================="
  echo "Configuration Status:"
  echo "  Loaded: ${CONFIG_LOADED}"
  echo "  Valid: ${CONFIG_VALID}"
  echo "=========================================="
}

# --------------------------------------------
# Configuration Validation Helpers
# --------------------------------------------

# Check if strict mode is enabled
is_strict_mode() {
  local strict_mode
  strict_mode="$(get_config "QUALITY_STRICT_MODE" "false")"

  [[ "${strict_mode}" == "true" ]]
}

# Check if auto push is enabled
is_auto_push_enabled() {
  local auto_push
  auto_push="$(get_config "DEPLOY_AUTO_PUSH" "false")"

  [[ "${auto_push}" == "true" ]]
}

# Check if approval is required
is_approval_required() {
  local require_approval
  require_approval="$(get_config "DEPLOY_REQUIRE_APPROVAL" "false")"

  [[ "${require_approval}" == "true" ]]
}

# Check if backups should be created
should_create_backups() {
  local create_backups
  create_backups="$(get_config "DEPLOY_CREATE_BACKUPS" "true")"

  [[ "${create_backups}" == "true" ]]
}

# --------------------------------------------
# Path Helpers
# --------------------------------------------

# Get absolute path from project root
get_project_path() {
  local relative_path="$1"
  echo "${PROJECT_ROOT}/${relative_path}"
}

# Get content directory path
get_content_dir() {
  get_project_path "$(get_config "CONTENT_DIR")"
}

# Get scripts directory path
get_scripts_dir() {
  echo "${SCRIPT_DIR}"
}

# Get logs directory path
get_logs_dir() {
  echo "${LOG_DIR}"
}

# --------------------------------------------
# Hugo Configuration
# --------------------------------------------

# Get Hugo executable command
get_hugo_cmd() {
  echo "hugo"
}

# Check if Hugo extended version
is_hugo_extended() {
  local extended
  extended="$(get_config "HUGO_EXTENDED" "false")"
  [[ "${extended}" == "true" ]]
}

# --------------------------------------------
# Git Configuration Helpers
# --------------------------------------------

# Get git author name
get_git_author_name() {
  get_config "GIT_AUTHOR_NAME"
}

# Get git author email
get_git_author_email() {
  get_config "GIT_AUTHOR_EMAIL"
}

# Get GitHub repository
get_github_repo() {
  get_config "GITHUB_REPO"
}

# Get main branch name
get_main_branch() {
  get_config "GITHUB_DEFAULT_BRANCH"
}

# --------------------------------------------
# Quality Gate Configuration
# --------------------------------------------

# Get minimum word count
get_min_word_count() {
  get_config "QUALITY_MIN_WORD_COUNT" "500"
}

# Check if link checking is enabled
is_link_check_enabled() {
  local check_links
  check_links="$(get_config "QUALITY_CHECK_EXTERNAL_LINKS" "true")"
  [[ "${check_links}" == "true" ]]
}

# --------------------------------------------
# Deployment Configuration
# --------------------------------------------

# Get Cloudflare account ID
get_cloudflare_account_id() {
  get_config "CLOUDFLARE_ACCOUNT_ID"
}

# Get Cloudflare project name
get_cloudflare_project_name() {
  get_config "CLOUDFLARE_PROJECT_NAME"
}

# Get Cloudflare API token
get_cloudflare_api_token() {
  get_config "CLOUDFLARE_API_TOKEN"
}

# Check if Cloudflare is configured
is_cloudflare_configured() {
  local account_id
  local api_token

  account_id="$(get_cloudflare_account_id)"
  api_token="$(get_cloudflare_api_token)"

  [[ -n "${account_id}" && -n "${api_token}" ]]
}

# --------------------------------------------
# Feature Flags
# --------------------------------------------

# Check if feature is enabled
is_feature_enabled() {
  local feature="$1"
  local feature_var="ENABLE_${feature}"
  local feature_value="${!feature_var:-false}"

  [[ "${feature_value}" == "true" ]]
}

# --------------------------------------------
# Configuration Export
# --------------------------------------------

# Export configuration as environment variables
export_config() {
  # Load config if not already loaded
  if [[ "${CONFIG_LOADED}" != "true" ]]; then
    load_config
  fi

  # Export key configuration values
  export SITE_URL
  export SITE_NAME
  export HUGO_VERSION
  export CONTENT_DIR
  export MIN_WORD_COUNT
  export DEPLOY_AUTO_PUSH
  export AUTOMATION_LOG_FILE
  export AUTOMATION_LOG_LEVEL

  log_debug "Configuration exported to environment"
}

# --------------------------------------------
# Configuration Reset
# --------------------------------------------

# Reset configuration (unload)
reset_config() {
  CONFIG_LOADED=false
  CONFIG_VALID=false

  # Unset variables
  unset SITE_URL SITE_NAME HUGO_VERSION HUGO_EXTENDED
  unset GIT_AUTHOR_NAME GIT_AUTHOR_EMAIL GITHUB_REPO
  unset CONTENT_DIR MIN_WORD_COUNT DRAFT_MODE
  unset QUALITY_STRICT_MODE QUALITY_MIN_WORD_COUNT
  unset BUILD_OUTPUT_DIR BUILD_PREVIEW_PORT
  unset DEPLOY_AUTO_PUSH DEPLOY_REQUIRE_APPROVAL

  log_debug "Configuration reset"
}

# --------------------------------------------
# Initialization
# --------------------------------------------

# Auto-load configuration
if [[ -f "${PROJECT_ROOT}/.env" ]]; then
  load_config
else
  log_warning "No .env file found, using defaults"
fi

# Log config library load
log_debug "Config library loaded successfully"

# ============================================
# END OF CONFIG LIBRARY
# ============================================
