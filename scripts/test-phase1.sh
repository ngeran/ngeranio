#!/bin/bash
# ============================================
# PHASE 1 TEST SCRIPT
# ============================================
# Comprehensive verification of Phase 1
# automation system components
# ============================================

# Don't exit on error - we want to run all tests
set +e

# Colors for output
readonly GREEN='\033[0;32m'
readonly RED='\033[0;31m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly CYAN='\033[0;36m'
readonly RESET='\033[0m'

# Test counters
TESTS_PASSED=0
TESTS_FAILED=0
TESTS_TOTAL=0

# --------------------------------------------
# Test Helper Functions
# --------------------------------------------

print_header() {
  echo -e "\n${CYAN}============================================${RESET}"
  echo -e "${CYAN}$1${RESET}"
  echo -e "${CYAN}============================================${RESET}\n"
}

print_test() {
  ((TESTS_TOTAL++))
  echo -e "${BLUE}[TEST ${TESTS_TOTAL}]${RESET} $1"
}

pass() {
  ((TESTS_PASSED++))
  echo -e "  ${GREEN}✓ PASS${RESET}: $1\n"
}

fail() {
  ((TESTS_FAILED++))
  echo -e "  ${RED}✗ FAIL${RESET}: $1\n"
}

warn() {
  echo -e "  ${YELLOW}⚠ WARNING${RESET}: $1\n"
}

# --------------------------------------------
# Test Suite 1: Directory Structure
# --------------------------------------------
test_directory_structure() {
  print_header "Test Suite 1: Directory Structure"

  print_test "Check if logs directory exists"
  if [[ -d "logs" ]]; then
    pass "logs directory exists"
  else
    fail "logs directory not found"
  fi

  print_test "Check if scripts/lib directory exists"
  if [[ -d "scripts/lib" ]]; then
    pass "scripts/lib directory exists"
  else
    fail "scripts/lib directory not found"
  fi

  print_test "Check if .env file exists"
  if [[ -f ".env" ]]; then
    pass ".env file exists"
  else
    fail ".env file not found"
  fi
}

# --------------------------------------------
# Test Suite 2: Library Loading
# --------------------------------------------
test_library_loading() {
  print_header "Test Suite 2: Library Loading"

  print_test "Load common.sh library"
  if source scripts/lib/common.sh 2>/dev/null; then
    pass "common.sh loaded successfully"
    echo "  PROJECT_ROOT: ${PROJECT_ROOT}"
    echo "  SCRIPT_DIR: ${SCRIPT_DIR}"
  else
    fail "Failed to load common.sh"
  fi

  print_test "Load logger.sh library"
  if source scripts/lib/logger.sh 2>/dev/null; then
    pass "logger.sh loaded successfully"
    echo "  LOG_DIR: ${LOG_DIR}"
    echo "  MAIN_LOG_FILE: ${MAIN_LOG_FILE}"
  else
    fail "Failed to load logger.sh"
  fi

  print_test "Load error-handler.sh library"
  if source scripts/lib/error-handler.sh 2>/dev/null; then
    pass "error-handler.sh loaded successfully"
    echo "  Error codes defined: E_SUCCESS=${E_SUCCESS}, E_GENERAL_ERROR=${E_GENERAL_ERROR}"
  else
    fail "Failed to load error-handler.sh"
  fi

  print_test "Load config.sh library"
  if source scripts/lib/config.sh 2>/dev/null; then
    pass "config.sh loaded successfully"
    echo "  CONFIG_LOADED: ${CONFIG_LOADED}"
    echo "  CONFIG_VALID: ${CONFIG_VALID}"
  else
    fail "Failed to load config.sh"
  fi

  print_test "Verify all libraries loaded in sequence"
  if [[ "${COMMON_LIB_LOADED:-}" == "true" ]] && \
     [[ "${LOGGER_LIB_LOADED:-}" == "true" ]] && \
     [[ "${ERROR_HANDLER_LIB_LOADED:-}" == "true" ]] && \
     [[ "${CONFIG_LIB_LOADED:-}" == "true" ]]; then
    pass "All libraries loaded successfully with guards in place"
  else
    fail "Library guards not properly set"
  fi
}

# --------------------------------------------
# Test Suite 3: Configuration System
# --------------------------------------------
test_configuration() {
  print_header "Test Suite 3: Configuration System"

  print_test "Load configuration from .env"
  if source scripts/lib/config.sh 2>/dev/null; then
    if [[ "${CONFIG_LOADED}" == "true" ]]; then
      pass "Configuration loaded successfully"

      # Display key configuration values
      echo "  Key Configuration Values:"
      echo "    SITE_URL: ${SITE_URL:-not set}"
      echo "    SITE_NAME: ${SITE_NAME:-not set}"
      echo "    HUGO_VERSION: ${HUGO_VERSION:-not set}"
      echo "    GIT_AUTHOR_NAME: ${GIT_AUTHOR_NAME:-not set}"
      echo "    GITHUB_REPO: ${GITHUB_REPO:-not set}"
      echo "    CONTENT_DIR: ${CONTENT_DIR:-not set}"
      echo "    MIN_WORD_COUNT: ${MIN_WORD_COUNT:-not set}"
    else
      fail "Configuration failed to load"
    fi
  else
    fail "Failed to source config.sh"
  fi

  print_test "Verify required configuration keys"
  local required_keys=("SITE_URL" "HUGO_VERSION" "GIT_AUTHOR_NAME" "GITHUB_REPO" "CONTENT_DIR")
  local missing_keys=()

  for key in "${required_keys[@]}"; do
    if [[ -z "${!key:-}" ]]; then
      missing_keys+=("${key}")
    fi
  done

  if [[ ${#missing_keys[@]} -eq 0 ]]; then
    pass "All required configuration keys are set"
  else
    fail "Missing required keys: ${missing_keys[*]}"
  fi

  print_test "Test get_config() function"
  local site_url
  site_url=$(get_config "SITE_URL")
  if [[ "${site_url}" == "https://ngeranio.com" ]]; then
    pass "get_config() works correctly"
    echo "    Retrieved: ${site_url}"
  else
    fail "get_config() returned unexpected value: ${site_url}"
  fi

  print_test "Test get_config() with default value"
  local test_value
  test_value=$(get_config "NONEXISTENT_KEY" "default_value")
  if [[ "${test_value}" == "default_value" ]]; then
    pass "get_config() default fallback works"
    echo "    Retrieved: ${test_value}"
  else
    fail "get_config() default fallback failed"
  fi

  print_test "Validate configuration"
  if [[ "${CONFIG_VALID}" == "true" ]]; then
    pass "Configuration validation passed"
  else
    fail "Configuration validation failed"
  fi
}

# --------------------------------------------
# Test Suite 4: Logging System
# --------------------------------------------
test_logging_system() {
  print_header "Test Suite 4: Logging System"

  print_test "Verify log files exist"
  local log_files=(
    "logs/automation.log"
    "logs/quality-gate.log"
    "logs/build.log"
    "logs/deployment.log"
    "logs/rollback.log"
  )

  local all_exist=true
  for log_file in "${log_files[@]}"; do
    if [[ ! -f "${log_file}" ]]; then
      all_exist=false
      break
    fi
  done

  if [[ "${all_exist}" == "true" ]]; then
    pass "All log files exist"
    echo "  Log files created:"
    printf "    - %s\n" "${log_files[@]}"
  else
    fail "Some log files are missing"
  fi

  print_test "Test logging functions"
  source scripts/lib/logger.sh 2>/dev/null

  # Write test log entries
  log_info "Test info message" 2>/dev/null
  log_debug "Test debug message" 2>/dev/null

  if grep -q "Test info message" logs/automation.log 2>/dev/null; then
    pass "Logging functions work correctly"
    echo "  Recent log entries:"
    tail -n 3 logs/automation.log | sed 's/^/    /'
  else
    fail "Log messages not found in file"
  fi

  print_test "Test component-specific logging"
  log_quality "INFO" "Test quality message" 2>/dev/null
  log_build "INFO" "Test build message" 2>/dev/null

  if grep -q "Test quality message" logs/quality-gate.log 2>/dev/null && \
     grep -q "Test build message" logs/build.log 2>/dev/null; then
    pass "Component-specific logging works"
  else
    fail "Component-specific logging failed"
  fi
}

# --------------------------------------------
# Test Suite 5: Error Handling
# --------------------------------------------
test_error_handling() {
  print_header "Test Suite 5: Error Handling"

  print_test "Test error codes are defined"
  if [[ -n "${E_SUCCESS:-}" ]] && \
     [[ -n "${E_GENERAL_ERROR:-}" ]] && \
     [[ -n "${E_INVALID_INPUT:-}" ]] && \
     [[ -n "${E_FILE_NOT_FOUND:-}" ]] && \
     [[ -n "${E_BUILD_FAILED:-}" ]] && \
     [[ -n "${E_GIT_ERROR:-}" ]] && \
     [[ -n "${E_DEPLOYMENT_FAILED:-}" ]]; then
    pass "All error codes defined"
    echo "  Defined error codes:"
    echo "    E_SUCCESS=${E_SUCCESS}"
    echo "    E_GENERAL_ERROR=${E_GENERAL_ERROR}"
    echo "    E_INVALID_INPUT=${E_INVALID_INPUT}"
    echo "    E_FILE_NOT_FOUND=${E_FILE_NOT_FOUND}"
    echo "    E_BUILD_FAILED=${E_BUILD_FAILED}"
    echo "    E_GIT_ERROR=${E_GIT_ERROR}"
    echo "    E_DEPLOYMENT_FAILED=${E_DEPLOYMENT_FAILED}"
  else
    fail "Some error codes are missing"
  fi

  print_test "Test validation functions"
  source scripts/lib/error-handler.sh 2>/dev/null

  # Test validate_required_files with existing file
  if validate_required_files ".env" "scripts/lib/common.sh" 2>/dev/null; then
    pass "validate_required_files() works correctly"
  else
    fail "validate_required_files() failed"
  fi

  # Test validate_required_files with non-existing file
  if ! validate_required_files "nonexistent.txt" 2>/dev/null; then
    pass "validate_required_files() correctly detects missing files"
  else
    fail "validate_required_files() should fail for missing files"
  fi

  print_test "Test string utilities"
  source scripts/lib/common.sh 2>/dev/null

  local test_slug
  test_slug=$(generate_slug "Test Title With Spaces")
  if [[ "${test_slug}" == "test-title-with-spaces" ]]; then
    pass "generate_slug() works correctly"
    echo "    Input: 'Test Title With Spaces'"
    echo "    Output: '${test_slug}'"
  else
    fail "generate_slug() returned unexpected result: ${test_slug}"
  fi
}

# --------------------------------------------
# Test Suite 6: System Dependencies
# --------------------------------------------
test_system_dependencies() {
  print_header "Test Suite 6: System Dependencies"

  print_test "Check if Hugo is installed"
  if command -v hugo &>/dev/null; then
    pass "Hugo is installed"
    local hugo_version
    hugo_version=$(hugo version 2>&1 | head -1)
    echo "    ${hugo_version}"
  else
    fail "Hugo is not installed"
  fi

  print_test "Check if Git is installed"
  if command -v git &>/dev/null; then
    pass "Git is installed"
    local git_version
    git_version=$(git --version)
    echo "    ${git_version}"
  else
    fail "Git is not installed"
  fi

  print_test "Check if GitHub CLI is installed"
  if command -v gh &>/dev/null; then
    pass "GitHub CLI is installed"
    local gh_version
    gh_version=$(gh --version 2>&1 | head -1)
    echo "    ${gh_version}"
  else
    warn "GitHub CLI is not installed (required for git automation)"
  fi

  print_test "Check if we're in a Git repository"
  if git rev-parse --git-dir &>/dev/null; then
    pass "Git repository detected"
    local current_branch
    current_branch=$(git branch --show-current)
    echo "    Current branch: ${current_branch}"
  else
    fail "Not in a Git repository"
  fi

  print_test "Check GitHub CLI authentication status"
  if command -v gh &>/dev/null; then
    if gh auth status &>/dev/null; then
      pass "GitHub CLI is authenticated"
    else
      warn "GitHub CLI is not authenticated (run 'gh auth login' when ready)"
    fi
  else
    warn "Cannot check GitHub CLI authentication (gh not installed)"
  fi
}

# --------------------------------------------
# Test Suite 7: Safety Features
# --------------------------------------------
test_safety_features() {
  print_header "Test Suite 7: Safety Features"

  print_test "Verify no automatic push is enabled"
  source scripts/lib/config.sh 2>/dev/null

  if [[ "${DEPLOY_AUTO_PUSH}" == "true" ]]; then
    warn "DEPLOY_AUTO_PUSH is enabled (commits will push automatically)"
  else
    pass "DEPLOY_AUTO_PUSH is disabled (safe mode)"
    echo "    You must manually approve pushes"
  fi

  print_test "Verify approval requirement setting"
  if [[ "${DEPLOY_REQUIRE_APPROVAL}" == "true" ]]; then
    pass "DEPLOY_REQUIRE_APPROVAL is enabled (extra safety)"
  else
    warn "DEPLOY_REQUIRE_APPROVAL is disabled"
  fi

  print_test "Verify backup setting"
  if [[ "${DEPLOY_CREATE_BACKUPS}" == "true" ]]; then
    pass "DEPLOY_CREATE_BACKUPS is enabled"
  else
    warn "DEPLOY_CREATE_BACKUPS is disabled"
  fi

  print_test "Verify rollback on failure setting"
  if [[ "${DEPLOY_ROLLBACK_ON_FAILURE}" == "true" ]]; then
    pass "DEPLOY_ROLLBACK_ON_FAILURE is enabled"
  else
    warn "DEPLOY_ROLLBACK_ON_FAILURE is disabled"
  fi

  print_test "Verify strict mode setting"
  if is_strict_mode 2>/dev/null; then
    pass "QUALITY_STRICT_MODE is enabled"
  else
    warn "QUALITY_STRICT_MODE is disabled"
  fi
}

# --------------------------------------------
# Main Test Execution
# --------------------------------------------
main() {
  print_header "PHASE 1 AUTOMATION SYSTEM TEST"
  echo -e "Testing all Phase 1 components and functionality\n"
  echo -e "Project Root: $(pwd)"
  echo -e "Test Started: $(date '+%Y-%m-%d %H:%M:%S')"

  # Change to project root
  cd "$(dirname "$0")/.." || exit 1

  # Run all test suites
  test_directory_structure
  test_library_loading
  test_configuration
  test_logging_system
  test_error_handling
  test_system_dependencies
  test_safety_features

  # ------------------------------------------
  # Test Summary
  # ------------------------------------------
  print_header "TEST SUMMARY"

  echo -e "Total Tests: ${TESTS_TOTAL}"
  echo -e "${GREEN}Passed: ${TESTS_PASSED}${RESET}"
  echo -e "${RED}Failed: ${TESTS_FAILED}${RESET}"

  local success_rate=0
  if [[ ${TESTS_TOTAL} -gt 0 ]]; then
    success_rate=$((TESTS_PASSED * 100 / TESTS_TOTAL))
  fi

  echo -e "\nSuccess Rate: ${success_rate}%"

  if [[ ${TESTS_FAILED} -eq 0 ]]; then
    echo -e "\n${GREEN}✓ All tests passed! Phase 1 is ready.${RESET}\n"
    exit 0
  else
    echo -e "\n${RED}✗ Some tests failed. Please review the output above.${RESET}\n"
    exit 1
  fi
}

# Run tests
main
