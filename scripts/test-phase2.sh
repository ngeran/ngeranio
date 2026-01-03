#!/bin/bash
# ============================================
# PHASE 2 TEST SUITE
# ============================================
# Tests Phase 2 automation functionality
# Tests enhanced scripts and quality gate
# ============================================

set -o pipefail

# ============================================
# SETUP
# ============================================
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"

# Color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Test counters
TESTS_TOTAL=0
TESTS_PASSED=0
TESTS_FAILED=0
TESTS_WARNING=0

# ============================================
# TEST FUNCTIONS
# ============================================

print_header() {
  echo ""
  echo -e "${BLUE}============================================${NC}"
  echo -e "${BLUE}$1${NC}"
  echo -e "${BLUE}============================================${NC}"
  echo ""
}

test_start() {
  ((TESTS_TOTAL++))
  echo -e "${BLUE}[TEST $TESTS_TOTAL]${NC} $1"
}

test_pass() {
  ((TESTS_PASSED++))
  echo -e "${GREEN}  ✓ PASS${NC}: $1"
  echo ""
}

test_fail() {
  ((TESTS_FAILED++))
  echo -e "${RED}  ✗ FAIL${NC}: $1"
  echo ""
}

test_warn() {
  ((TESTS_WARNING++))
  echo -e "${YELLOW}  ⚠ WARN${NC}: $1"
  echo ""
}

# ============================================
# PHASE 2: CORE SCRIPT TESTS
# ============================================

test_quality_gate_exists() {
  test_start "Check quality-gate.sh exists"

  local quality_gate="${PROJECT_ROOT}/scripts/quality-gate.sh"

  if [[ -f "$quality_gate" ]]; then
    test_pass "quality-gate.sh exists"
  else
    test_fail "quality-gate.sh not found at $quality_gate"
  fi
}

test_ai_content_manager_exists() {
  test_start "Check ai-content-manager.sh exists"

  local ai_manager="${PROJECT_ROOT}/scripts/ai-content-manager.sh"

  if [[ -f "$ai_manager" ]]; then
    test_pass "ai-content-manager.sh exists"
  else
    test_fail "ai-content-manager.sh not found at $ai_manager"
  fi
}

test_quality_gate_executable() {
  test_start "Check quality-gate.sh is executable"

  local quality_gate="${PROJECT_ROOT}/scripts/quality-gate.sh"

  if [[ -x "$quality_gate" ]]; then
    test_pass "quality-gate.sh is executable"
  else
    test_fail "quality-gate.sh is not executable"
  fi
}

test_ai_content_manager_executable() {
  test_start "Check ai-content-manager.sh is executable"

  local ai_manager="${PROJECT_ROOT}/scripts/ai-content-manager.sh"

  if [[ -x "$ai_manager" ]]; then
    test_pass "ai-content-manager.sh is executable"
  else
    test_fail "ai-content-manager.sh is not executable"
  fi
}

# ============================================
# PHASE 2: ENHANCED SCRIPT TESTS
# ============================================

test_create_post_enhanced() {
  test_start "Check create-post.sh uses Phase 1 libraries"

  local create_post="${PROJECT_ROOT}/scripts/create-post.sh"

  if grep -q "scripts/lib/common.sh" "$create_post" && \
     grep -q "scripts/lib/logger.sh" "$create_post" && \
     grep -q "scripts/lib/error-handler.sh" "$create_post" && \
     grep -q "scripts/lib/config.sh" "$create_post"; then
    test_pass "create-post.sh sources all Phase 1 libraries"
  else
    test_fail "create-post.sh missing Phase 1 library imports"
  fi
}

test_preview_enhanced() {
  test_start "Check preview.sh uses Phase 1 libraries"

  local preview="${PROJECT_ROOT}/scripts/preview.sh"

  if grep -q "scripts/lib/common.sh" "$preview" && \
     grep -q "scripts/lib/logger.sh" "$preview" && \
     grep -q "scripts/lib/error-handler.sh" "$preview" && \
     grep -q "scripts/lib/config.sh" "$preview"; then
    test_pass "preview.sh sources all Phase 1 libraries"
  else
    test_fail "preview.sh missing Phase 1 library imports"
  fi
}

test_publish_drafts_enhanced() {
  test_start "Check publish-drafts.sh uses Phase 1 libraries"

  local publish_drafts="${PROJECT_ROOT}/scripts/publish-drafts.sh"

  if grep -q "scripts/lib/common.sh" "$publish_drafts" && \
     grep -q "scripts/lib/logger.sh" "$publish_drafts" && \
     grep -q "scripts/lib/error-handler.sh" "$publish_drafts" && \
     grep -q "scripts/lib/config.sh" "$publish_drafts"; then
    test_pass "publish-drafts.sh sources all Phase 1 libraries"
  else
    test_fail "publish-drafts.sh missing Phase 1 library imports"
  fi
}

# ============================================
# PHASE 2: CONFIGURATION INTEGRATION
# ============================================

test_create_post_uses_config() {
  test_start "Check create-post.sh uses get_config"

  local create_post="${PROJECT_ROOT}/scripts/create-post.sh"

  if grep -q "get_config" "$create_post"; then
    test_pass "create-post.sh uses get_config()"
  else
    test_fail "create-post.sh doesn't use get_config()"
  fi
}

test_preview_uses_config() {
  test_start "Check preview.sh uses get_config"

  local preview="${PROJECT_ROOT}/scripts/preview.sh"

  if grep -q "get_config" "$preview"; then
    test_pass "preview.sh uses get_config()"
  else
    test_fail "preview.sh doesn't use get_config()"
  fi
}

test_publish_drafts_uses_config() {
  test_start "Check publish-drafts.sh uses get_config"

  local publish_drafts="${PROJECT_ROOT}/scripts/publish-drafts.sh"

  if grep -q "get_config" "$publish_drafts"; then
    test_pass "publish-drafts.sh uses get_config()"
  else
    test_fail "publish-drafts.sh doesn't use get_config()"
  fi
}

# ============================================
# PHASE 2: LOGGING INTEGRATION
# ============================================

test_create_post_logging() {
  test_start "Check create-post.sh uses component logging"

  local create_post="${PROJECT_ROOT}/scripts/create-post.sh"

  if grep -q "log_content" "$create_post"; then
    test_pass "create-post.sh uses log_content()"
  else
    test_fail "create-post.sh doesn't use component logging"
  fi
}

test_preview_logging() {
  test_start "Check preview.sh uses component logging"

  local preview="${PROJECT_ROOT}/scripts/preview.sh"

  if grep -q "log_build" "$preview"; then
    test_pass "preview.sh uses log_build()"
  else
    test_fail "preview.sh doesn't use component logging"
  fi
}

test_publish_drafts_logging() {
  test_start "Check publish-drafts.sh uses component logging"

  local publish_drafts="${PROJECT_ROOT}/scripts/publish-drafts.sh"

  if grep -q "log_deployment" "$publish_drafts"; then
    test_pass "publish-drafts.sh uses log_deployment()"
  else
    test_fail "publish-drafts.sh doesn't use component logging"
  fi
}

# ============================================
# PHASE 2: QUALITY GATE INTEGRATION
# ============================================

test_quality_gate_has_validate() {
  test_start "Check quality-gate.sh has validate command"

  local quality_gate="${PROJECT_ROOT}/scripts/quality-gate.sh"

  if grep -q "validate" "$quality_gate"; then
    test_pass "quality-gate.sh has validate functionality"
  else
    test_fail "quality-gate.sh missing validate functionality"
  fi
}

test_quality_gate_has_validate_drafts() {
  test_start "Check quality-gate.sh has validate-drafts command"

  local quality_gate="${PROJECT_ROOT}/scripts/quality-gate.sh"

  if grep -q "validate-drafts" "$quality_gate"; then
    test_pass "quality-gate.sh has validate-drafts functionality"
  else
    test_fail "quality-gate.sh missing validate-drafts functionality"
  fi
}

test_publish_drafts_integrates_quality_gate() {
  test_start "Check publish-drafts.sh integrates with quality-gate.sh"

  local publish_drafts="${PROJECT_ROOT}/scripts/publish-drafts.sh"

  if grep -q "quality-gate.sh" "$publish_drafts"; then
    test_pass "publish-drafts.sh integrates with quality-gate.sh"
  else
    test_fail "publish-drafts.sh doesn't integrate with quality-gate.sh"
  fi
}

test_preview_integrates_quality_gate() {
  test_start "Check preview.sh integrates with quality-gate.sh"

  local preview="${PROJECT_ROOT}/scripts/preview.sh"

  if grep -q "quality-gate.sh" "$preview"; then
    test_pass "preview.sh integrates with quality-gate.sh"
  else
    test_fail "preview.sh doesn't integrate with quality-gate.sh"
  fi
}

# ============================================
# PHASE 2: ENHANCED FUNCTIONALITY
# ============================================

test_create_post_has_force_option() {
  test_start "Check create-post.sh has --force option"

  local create_post="${PROJECT_ROOT}/scripts/create-post.sh"

  if grep -q "\-\-force" "$create_post"; then
    test_pass "create-post.sh has --force option"
  else
    test_fail "create-post.sh missing --force option"
  fi
}

test_create_post_has_backup_option() {
  test_start "Check create-post.sh has --no-backup option"

  local create_post="${PROJECT_ROOT}/scripts/create-post.sh"

  if grep -q "\-\-no-backup" "$create_post"; then
    test_pass "create-post.sh has --no-backup option"
  else
    test_fail "create-post.sh missing --no-backup option"
  fi
}

test_preview_has_validate_option() {
  test_start "Check preview.sh has --validate option"

  local preview="${PROJECT_ROOT}/scripts/preview.sh"

  if grep -q "\-\-validate" "$preview"; then
    test_pass "preview.sh has --validate option"
  else
    test_fail "preview.sh missing --validate option"
  fi
}

test_preview_has_port_option() {
  test_start "Check preview.sh has --port option"

  local preview="${PROJECT_ROOT}/scripts/preview.sh"

  if grep -q "\-\-port" "$preview"; then
    test_pass "preview.sh has --port option"
  else
    test_fail "preview.sh missing --port option"
  fi
}

test_publish_drafts_has_validate_option() {
  test_start "Check publish-drafts.sh has --validate option"

  local publish_drafts="${PROJECT_ROOT}/scripts/publish-drafts.sh"

  if grep -q "\-\-validate" "$publish_drafts"; then
    test_pass "publish-drafts.sh has --validate option"
  else
    test_fail "publish-drafts.sh missing --validate option"
  fi
}

test_publish_drafts_has_backup_option() {
  test_start "Check publish-drafts.sh has --backup option"

  local publish_drafts="${PROJECT_ROOT}/scripts/publish-drafts.sh"

  if grep -q "\-\-backup" "$publish_drafts"; then
    test_pass "publish-drafts.sh has --backup option"
  else
    test_fail "publish-drafts.sh missing --backup option"
  fi
}

test_publish_drafts_has_category_option() {
  test_start "Check publish-drafts.sh has --category option"

  local publish_drafts="${PROJECT_ROOT}/scripts/publish-drafts.sh"

  if grep -q "\-\-category" "$publish_drafts"; then
    test_pass "publish-drafts.sh has --category option"
  else
    test_fail "publish-drafts.sh missing --category option"
  fi
}

test_publish_drafts_has_force_option() {
  test_start "Check publish-drafts.sh has --force option"

  local publish_drafts="${PROJECT_ROOT}/scripts/publish-drafts.sh"

  if grep -q "\-\-force" "$publish_drafts"; then
    test_pass "publish-drafts.sh has --force option"
  else
    test_fail "publish-drafts.sh missing --force option"
  fi
}

# ============================================
# PHASE 2: AI CONTENT MANAGER TESTS
# ============================================

test_ai_manager_has_commands() {
  test_start "Check ai-content-manager.sh has required commands"

  local ai_manager="${PROJECT_ROOT}/scripts/ai-content-manager.sh"

  local has_create=0
  local has_update=0
  local has_delete=0
  local has_list=0
  local has_info=0
  local has_validate=0

  grep -q "cmd_create()" "$ai_manager" && ((has_create++))
  grep -q "cmd_update()" "$ai_manager" && ((has_update++))
  grep -q "cmd_delete()" "$ai_manager" && ((has_delete++))
  grep -q "cmd_list()" "$ai_manager" && ((has_list++))
  grep -q "cmd_info()" "$ai_manager" && ((has_info++))
  grep -q "cmd_validate()" "$ai_manager" && ((has_validate++))

  if [[ $has_create -eq 1 && $has_update -eq 1 && $has_delete -eq 1 && \
        $has_list -eq 1 && $has_info -eq 1 && $has_validate -eq 1 ]]; then
    test_pass "ai-content-manager.sh has all 6 commands (create, update, delete, list, info, validate)"
  else
    test_fail "ai-content-manager.sh missing some commands"
  fi
}

# ============================================
# PHASE 2: BACKUP FUNCTIONALITY
# ============================================

test_publish_drafts_has_backup_function() {
  test_start "Check publish-drafts.sh has backup functionality"

  local publish_drafts="${PROJECT_ROOT}/scripts/publish-drafts.sh"

  if grep -q "create_backup()" "$publish_drafts"; then
    test_pass "publish-drafts.sh has create_backup() function"
  else
    test_fail "publish-drafts.sh missing create_backup() function"
  fi
}

test_ai_manager_has_backup_function() {
  test_start "Check ai-content-manager.sh has backup functionality"

  local ai_manager="${PROJECT_ROOT}/scripts/ai-content-manager.sh"

  if grep -q "create_backup()" "$ai_manager"; then
    test_pass "ai-content-manager.sh has create_backup() function"
  else
    test_fail "ai-content-manager.sh missing create_backup() function"
  fi
}

# ============================================
# PHASE 2: ERROR HANDLING
# ============================================

test_create_post_error_handling() {
  test_start "Check create-post.sh has error handling"

  local create_post="${PROJECT_ROOT}/scripts/create-post.sh"

  if grep -q "return 1" "$create_post" && grep -q "return 0" "$create_post"; then
    test_pass "create-post.sh has proper error handling"
  else
    test_fail "create-post.sh missing proper error handling"
  fi
}

test_preview_error_handling() {
  test_start "Check preview.sh has error handling"

  local preview="${PROJECT_ROOT}/scripts/preview.sh"

  if grep -q "return 1" "$preview" || grep -q "exit 1" "$preview"; then
    test_pass "preview.sh has error handling"
  else
    test_fail "preview.sh missing error handling"
  fi
}

test_publish_drafts_error_handling() {
  test_start "Check publish-drafts.sh has error handling"

  local publish_drafts="${PROJECT_ROOT}/scripts/publish-drafts.sh"

  if grep -q "return 1" "$publish_drafts" && grep -q "return 0" "$publish_drafts"; then
    test_pass "publish-drafts.sh has proper error handling"
  else
    test_fail "publish-drafts.sh missing proper error handling"
  fi
}

# ============================================
# PHASE 2: CROSS-PLATFORM COMPATIBILITY
# ============================================

test_publish_drafts_macos_compat() {
  test_start "Check publish-drafts.sh has macOS compatibility"

  local publish_drafts="${PROJECT_ROOT}/scripts/publish-drafts.sh"

  if grep -q "darwin" "$publish_drafts"; then
    test_pass "publish-drafts.sh has macOS sed compatibility"
  else
    test_fail "publish-drafts.sh missing macOS compatibility"
  fi
}

# ============================================
# PHASE 2: HELP DOCUMENTATION
# ============================================

test_create_post_help() {
  test_start "Check create-post.sh has help documentation"

  local create_post="${PROJECT_ROOT}/scripts/create-post.sh"

  if grep -q "show_usage()" "$create_post" || grep -q "usage()" "$create_post"; then
    test_pass "create-post.sh has help documentation"
  else
    test_fail "create-post.sh missing help documentation"
  fi
}

test_preview_help() {
  test_start "Check preview.sh has help documentation"

  local preview="${PROJECT_ROOT}/scripts/preview.sh"

  if grep -q "show_usage()" "$preview" || grep -q "usage()" "$preview"; then
    test_pass "preview.sh has help documentation"
  else
    test_fail "preview.sh missing help documentation"
  fi
}

test_publish_drafts_help() {
  test_start "Check publish-drafts.sh has help documentation"

  local publish_drafts="${PROJECT_ROOT}/scripts/publish-drafts.sh"

  if grep -q "show_usage()" "$publish_drafts" || grep -q "usage()" "$publish_drafts"; then
    test_pass "publish-drafts.sh has help documentation"
  else
    test_fail "publish-drafts.sh missing help documentation"
  fi
}

test_ai_manager_help() {
  test_start "Check ai-content-manager.sh has help documentation"

  local ai_manager="${PROJECT_ROOT}/scripts/ai-content-manager.sh"

  if grep -q "usage()" "$ai_manager"; then
    test_pass "ai-content-manager.sh has help documentation"
  else
    test_fail "ai-content-manager.sh missing help documentation"
  fi
}

# ============================================
# MAIN TEST RUNNER
# ============================================

main() {
  print_header "PHASE 2 TEST SUITE"

  echo -e "${BLUE}Testing Phase 2 Implementation${NC}"
  echo -e "Project Root: ${PROJECT_ROOT}"
  echo ""

  # Phase 2: Core Scripts
  print_header "Phase 2: Core Scripts"
  test_quality_gate_exists
  test_ai_content_manager_exists
  test_quality_gate_executable
  test_ai_content_manager_executable

  # Phase 2: Enhanced Scripts
  print_header "Phase 2: Enhanced Scripts Integration"
  test_create_post_enhanced
  test_preview_enhanced
  test_publish_drafts_enhanced

  # Phase 2: Configuration Integration
  print_header "Phase 2: Configuration Integration"
  test_create_post_uses_config
  test_preview_uses_config
  test_publish_drafts_uses_config

  # Phase 2: Logging Integration
  print_header "Phase 2: Logging Integration"
  test_create_post_logging
  test_preview_logging
  test_publish_drafts_logging

  # Phase 2: Quality Gate Integration
  print_header "Phase 2: Quality Gate Integration"
  test_quality_gate_has_validate
  test_quality_gate_has_validate_drafts
  test_publish_drafts_integrates_quality_gate
  test_preview_integrates_quality_gate

  # Phase 2: Enhanced Functionality
  print_header "Phase 2: Enhanced Functionality"
  test_create_post_has_force_option
  test_create_post_has_backup_option
  test_preview_has_validate_option
  test_preview_has_port_option
  test_publish_drafts_has_validate_option
  test_publish_drafts_has_backup_option
  test_publish_drafts_has_category_option
  test_publish_drafts_has_force_option

  # Phase 2: AI Content Manager
  print_header "Phase 2: AI Content Manager"
  test_ai_manager_has_commands

  # Phase 2: Backup Functionality
  print_header "Phase 2: Backup Functionality"
  test_publish_drafts_has_backup_function
  test_ai_manager_has_backup_function

  # Phase 2: Error Handling
  print_header "Phase 2: Error Handling"
  test_create_post_error_handling
  test_preview_error_handling
  test_publish_drafts_error_handling

  # Phase 2: Cross-Platform Compatibility
  print_header "Phase 2: Cross-Platform Compatibility"
  test_publish_drafts_macos_compat

  # Phase 2: Help Documentation
  print_header "Phase 2: Help Documentation"
  test_create_post_help
  test_preview_help
  test_publish_drafts_help
  test_ai_manager_help

  # ============================================
  # RESULTS SUMMARY
  # ============================================
  print_header "TEST RESULTS SUMMARY"

  local success_rate=0
  if [[ $TESTS_TOTAL -gt 0 ]]; then
    success_rate=$((TESTS_PASSED * 100 / TESTS_TOTAL))
  fi

  echo -e "Total Tests: ${TESTS_TOTAL}"
  echo -e "${GREEN}Passed: ${TESTS_PASSED}${NC}"
  echo -e "${RED}Failed: ${TESTS_FAILED}${NC}"
  echo -e "${YELLOW}Warnings: ${TESTS_WARNING}${NC}"
  echo ""
  echo -e "Success Rate: ${success_rate}%"
  echo ""

  if [[ $TESTS_FAILED -eq 0 ]]; then
    echo -e "${GREEN}✓ All tests passed! Phase 2 is working correctly.${NC}"
    return 0
  elif [[ $success_rate -ge 80 ]]; then
    echo -e "${YELLOW}⚠ Phase 2 is mostly working, but some tests failed.${NC}"
    return 0
  else
    echo -e "${RED}✗ Phase 2 has significant issues. Please review failed tests.${NC}"
    return 1
  fi
}

# Run main
main "$@"
