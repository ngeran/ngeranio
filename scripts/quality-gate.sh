#!/bin/bash
# ============================================
# QUALITY GATE - Content Validation Script
# ============================================
# Validates blog posts before publishing
# Ensures content quality and completeness
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
# Get configuration values
STRICT_MODE=$(get_config "QUALITY_STRICT_MODE" "true")
MIN_WORD_COUNT=$(get_config "QUALITY_MIN_WORD_COUNT" "500")
REQUIRE_FEATURED_IMAGE=$(get_config "QUALITY_REQUIRE_FEATURED_IMAGE" "true")
VALIDATE_LINKS=$(get_config "CONTENT_VALIDATE_LINKS" "true")
VALIDATE_IMAGES=$(get_config "CONTENT_VALIDATE_IMAGES" "true")
REQUIRED_SECTIONS=($(get_config "QUALITY_REQUIRED_SECTIONS" "Overview Key Concepts Configuration Summary"))

# Validation counters
VALIDATION_ERRORS=0
VALIDATION_WARNINGS=0
VALIDATION_PASSED=0

# ============================================
# USAGE
# ============================================
usage() {
  cat << EOF
Usage: ${0##*/} <command> [options]

Commands:
  validate <file>          Validate a single post
  validate-drafts          Validate all draft posts
  validate-all             Validate all posts
  report <file>            Show detailed validation report
  check-word-count <file>  Check word count only

Options:
  --strict                 Enable strict mode (warnings treated as errors)
  --warn-only              Warning mode only (non-blocking)
  --verbose                Show detailed output
  --quiet                  Suppress non-error output

Examples:
  ${0##*/} validate content/routing/ospf/virtual-links/index.md
  ${0##*/} validate-drafts
  ${0##*/} report content/routing/bgp/bgp-attributes/index.md

EOF
  exit 0
}

# ============================================
# VALIDATION FUNCTIONS
# ============================================

# Validate frontmatter
validate_frontmatter() {
  local file="$1"
  local errors=0
  local warnings=0

  log_content "INFO" "Validating frontmatter..."

  # Extract frontmatter (between +++ markers)
  local frontmatter
  frontmatter=$(sed -n '/^+++/,/^+++/p' "$file" | sed '1d;$d')

  # Check if frontmatter exists
  if [[ -z "$frontmatter" ]]; then
    log_quality "ERROR" "No frontmatter found in $file"
    ((VALIDATION_ERRORS++))
    return 1
  fi

  # Check required fields
  local required_fields=("title" "date" "draft" "tags")
  for field in "${required_fields[@]}"; do
    if ! echo "$frontmatter" | grep -q "^${field}"; then
      log_quality "ERROR" "Missing required field: $field"
      ((errors++))
      ((VALIDATION_ERRORS++))
    fi
  done

  # Validate draft status
  local draft
  draft=$(echo "$frontmatter" | grep "^draft" | sed 's/draft *= *//;s/"//g;s/ *$//')
  if [[ "$draft" != "true" && "$draft" != "false" ]]; then
    log_quality "ERROR" "Invalid draft status: $draft (must be true or false)"
    ((errors++))
    ((VALIDATION_ERRORS++))
  fi

  # Validate date format
  local date
  date=$(echo "$frontmatter" | grep "^date" | sed 's/date *= *//;s/"//g')
  if [[ -n "$date" ]] && ! [[ "$date" =~ ^[0-9]{4}-[0-9]{2}-[0-9]{2}T ]]; then
    log_quality "ERROR" "Invalid date format: $date (expected ISO 8601)"
    ((errors++))
    ((VALIDATION_ERRORS++))
  fi

  # Check for recommended fields
  if ! echo "$frontmatter" | grep -q "^summary"; then
    log_quality "WARNING" "Missing recommended field: summary"
    ((warnings++))
    ((VALIDATION_WARNINGS++))
  fi

  if ! echo "$frontmatter" | grep -q "^featured_image"; then
    if [[ "$REQUIRE_FEATURED_IMAGE" == "true" ]]; then
      log_quality "ERROR" "Missing required field: featured_image"
      ((errors++))
      ((VALIDATION_ERRORS++))
    else
      log_quality "WARNING" "Missing recommended field: featured_image"
      ((warnings++))
      ((VALIDATION_WARNINGS++))
    fi
  fi

  # Validate tags array
  local tags
  tags=$(echo "$frontmatter" | grep -A 10 "^tags" | grep -E '^\s+"')
  if [[ -z "$tags" ]]; then
    log_quality "WARNING" "No tags defined"
    ((warnings++))
    ((VALIDATION_WARNINGS++))
  fi

  if [[ $errors -eq 0 ]]; then
    log_quality "INFO" "✓ Frontmatter validation passed"
    ((VALIDATION_PASSED++))
    return 0
  else
    return 1
  fi
}

# Validate content structure
validate_content() {
  local file="$1"
  local errors=0
  local warnings=0

  log_content "INFO" "Validating content structure..."

  # Extract content (after frontmatter)
  # Find the second +++ line and get everything after it
  local content
  content=$(awk 'BEGIN {found=0} /^+++$/ {found++; if (found==2) next} found==2 {print}' "$file")

  # Check if content exists
  if [[ -z "$content" ]]; then
    log_quality "ERROR" "No content found"
    ((errors++))
    ((VALIDATION_ERRORS++))
    return 1
  fi

  # Check for required sections
  for section in "${REQUIRED_SECTIONS[@]}"; do
    if ! echo "$content" | grep -qi "^##[[:space:]]*${section}"; then
      if [[ "$STRICT_MODE" == "true" ]]; then
        log_quality "ERROR" "Missing required section: $section"
        ((errors++))
        ((VALIDATION_ERRORS++))
      else
        log_quality "WARNING" "Missing recommended section: $section"
        ((warnings++))
        ((VALIDATION_WARNINGS++))
      fi
    fi
  done

  # Check heading levels
  local first_heading
  first_heading=$(echo "$content" | grep -m1 "^#" | sed 's/^#*//;s/^[[:space:]]*//;s/[[:space:]]*$//')
  if [[ "$first_heading" != "Overview" ]] && [[ "$first_heading" != "overview" ]]; then
    log_quality "WARNING" "First heading should be 'Overview', found: $first_heading"
    ((warnings++))
    ((VALIDATION_WARNINGS++))
  fi

  # Check code blocks
  local code_blocks
  code_blocks=$(grep -c '```' "$file" || true)
  if [[ $code_blocks -gt 0 ]] && [[ $((code_blocks % 2)) -ne 0 ]]; then
    log_quality "ERROR" "Unclosed code block detected"
    ((errors++))
    ((VALIDATION_ERRORS++))
  fi

  if [[ $errors -eq 0 ]]; then
    log_quality "INFO" "✓ Content structure validation passed"
    ((VALIDATION_PASSED++))
    return 0
  else
    return 1
  fi
}

# Validate word count
validate_word_count() {
  local file="$1"

  log_content "INFO" "Checking word count..."

  # Extract content (excluding frontmatter)
  local content
  content=$(awk 'BEGIN {found=0} /^+++$/ {found++; if (found==2) next} found==2 {print}' "$file")

  # Count words (exclude code blocks)
  local word_count
  word_count=$(echo "$content" | sed '/```/,/```/d' | wc -w | tr -d ' ')

  if [[ $word_count -lt $MIN_WORD_COUNT ]]; then
    log_quality "ERROR" "Word count ($word_count) below minimum ($MIN_WORD_COUNT)"
    ((VALIDATION_ERRORS++))
    return 1
  else
    log_quality "INFO" "✓ Word count: $word_count (minimum: $MIN_WORD_COUNT)"
    ((VALIDATION_PASSED++))
    return 0
  fi
}

# Validate images
validate_images() {
  local file="$1"
  local errors=0
  local warnings=0

  if [[ "$VALIDATE_IMAGES" != "true" ]]; then
    log_content "INFO" "Image validation disabled"
    return 0
  fi

  log_content "INFO" "Validating images..."

  # Get post directory
  local post_dir
  post_dir=$(dirname "$file")

  # Check featured_image
  local featured_image
  featured_image=$(sed -n '/^+++/,/^+++/p' "$file" | grep 'featured_image' | sed 's/.*= *//;s/"//g;s/ *$//')

  if [[ -n "$featured_image" ]]; then
    local image_path="${post_dir}/${featured_image}"
    if [[ ! -f "$image_path" ]]; then
      log_quality "ERROR" "Featured image not found: $image_path"
      ((errors++))
      ((VALIDATION_ERRORS++))
    else
      log_quality "INFO" "✓ Featured image exists: $featured_image"
    fi
  fi

  # Check for referenced images in content
  local content
  content=$(cat "$file")

  # Find all image references
  local images
  images=$(echo "$content" | grep -oE '!\[.*\]\([^)]+\)' | sed 's/.*](\(.*\))/\1/' || true)

  if [[ -n "$images" ]]; then
    while IFS= read -r image; do
      # Skip external images
      if [[ "$image" =~ ^https?:// ]]; then
        continue
      fi

      local image_path
      if [[ "$image" =~ ^/ ]]; then
        # Absolute path from site root
        image_path="${PROJECT_ROOT}/${image:1}"
      else
        # Relative path
        image_path="${post_dir}/${image}"
      fi

      if [[ ! -f "$image_path" ]]; then
        log_quality "ERROR" "Referenced image not found: $image"
        ((errors++))
        ((VALIDATION_ERRORS++))
      fi
    done <<< "$images"
  fi

  if [[ $errors -eq 0 ]]; then
    log_quality "INFO" "✓ Image validation passed"
    ((VALIDATION_PASSED++))
    return 0
  else
    return 1
  fi
}

# Validate links
validate_links() {
  local file="$1"
  local errors=0
  local warnings=0

  if [[ "$VALIDATE_LINKS" != "true" ]]; then
    log_content "INFO" "Link validation disabled"
    return 0
  fi

  log_content "INFO" "Validating links..."

  local content
  content=$(cat "$file")

  # Find all markdown links
  local links
  links=$(echo "$content" | grep -oE '\[.*\]\([^)]+\)' | sed 's/.*](\(.*\))/\1/' || true)

  if [[ -n "$links" ]]; then
    while IFS= read -r link; do
      # Skip external links
      if [[ "$link" =~ ^https?:// ]]; then
        continue
      fi

      # Check if relative link points to existing file
      if [[ "$link" =~ ^/ ]]; then
        local link_path="${PROJECT_ROOT}/content${link}"
        if [[ ! -f "$link_path" ]] && [[ ! -d "$link_path" ]]; then
          log_quality "WARNING" "Broken internal link: $link"
          ((warnings++))
          ((VALIDATION_WARNINGS++))
        fi
      fi
    done <<< "$links"
  fi

  if [[ $errors -eq 0 ]]; then
    log_quality "INFO" "✓ Link validation passed"
    ((VALIDATION_PASSED++))
    return 0
  else
    return 1
  fi
}

# Main validation orchestrator
validate_post() {
  local file="$1"

  # Reset counters
  VALIDATION_ERRORS=0
  VALIDATION_WARNINGS=0
  VALIDATION_PASSED=0

  log_content "INFO" "========================================="
  log_content "INFO" "Validating: $file"
  log_content "INFO" "========================================="

  # Check if file exists
  if [[ ! -f "$file" ]]; then
    log_quality "ERROR" "File not found: $file"
    return 1
  fi

  # Run all validations
  validate_frontmatter "$file"
  validate_content "$file"
  validate_word_count "$file"
  validate_images "$file"
  validate_links "$file"

  # Print summary
  echo ""
  log_quality "INFO" "========================================="
  log_quality "INFO" "VALIDATION SUMMARY"
  log_quality "INFO" "========================================="
  log_quality "INFO" "Passed:  $VALIDATION_PASSED"
  log_quality "WARNING" "Warnings: $VALIDATION_WARNINGS"
  log_quality "ERROR" "Errors:   $VALIDATION_ERRORS"

  # Determine exit code
  if [[ $VALIDATION_ERRORS -gt 0 ]]; then
    log_quality "ERROR" "Status: FAILED"
    return 1
  elif [[ $VALIDATION_WARNINGS -gt 0 && "$STRICT_MODE" == "true" ]]; then
    log_quality "WARNING" "Status: FAILED (strict mode - warnings treated as errors)"
    return 1
  else
    log_quality "INFO" "Status: PASSED"
    return 0
  fi
}

# Generate detailed report
generate_report() {
  local file="$1"

  log_content "INFO" "========================================="
  log_content "INFO" "DETAILED VALIDATION REPORT"
  log_content "INFO" "========================================="
  log_content "INFO" "File: $file"
  log_content "INFO" ""

  # File info
  log_content "INFO" "File Information:"
  log_content "INFO" "  Size: $(wc -c < "$file" | tr -d ' ') bytes"
  log_content "INFO" "  Words: $(wc -w < "$file" | tr -d ' ')"
  log_content "INFO" "  Lines: $(wc -l < "$file" | tr -d ' ')"
  log_content "INFO" ""

  # Frontmatter info
  log_content "INFO" "Frontmatter:"
  sed -n '/^+++/,/^+++/p' "$file" | sed '1d;$d' | while IFS= read -r line; do
    log_content "INFO" "  $line"
  done
  log_content "INFO" ""

  # Run validation
  validate_post "$file"
}

# ============================================
# COMMAND HANDLERS
# ============================================

cmd_validate() {
  local file="$1"

  if [[ -z "$file" ]]; then
    log_quality "ERROR" "Usage: ${0##*/} validate <file>"
    exit 1
  fi

  validate_post "$file"
}

cmd_validate_drafts() {
  local drafts
  drafts=$(find "${PROJECT_ROOT}/content" -name "index.md" -exec grep -l 'draft = true' {} \;)

  if [[ -z "$drafts" ]]; then
    log_quality "INFO" "No draft posts found"
    return 0
  fi

  local total=0
  local passed=0
  local failed=0

  while IFS= read -r draft; do
    ((total++))
    log_quality "INFO" "----------------------------------------"
    if validate_post "$draft"; then
      ((passed++))
    else
      ((failed++))
    fi
  done <<< "$drafts"

  echo ""
  log_quality "INFO" "========================================="
  log_quality "INFO" "DRAFTS VALIDATION SUMMARY"
  log_quality "INFO" "========================================="
  log_quality "INFO" "Total:   $total"
  log_quality "INFO" "Passed:  $passed"
  log_quality "ERROR" "Failed:  $failed"

  if [[ $failed -gt 0 ]]; then
    return 1
  fi
}

cmd_validate_all() {
  local posts
  posts=$(find "${PROJECT_ROOT}/content" -name "index.md")

  if [[ -z "$posts" ]]; then
    log_quality "INFO" "No posts found"
    return 0
  fi

  local total=0
  local passed=0
  local failed=0

  while IFS= read -r post; do
    ((total++))
    log_quality "INFO" "----------------------------------------"
    if validate_post "$post"; then
      ((passed++))
    else
      ((failed++))
    fi
  done <<< "$posts"

  echo ""
  log_quality "INFO" "========================================="
  log_quality "INFO" "ALL POSTS VALIDATION SUMMARY"
  log_quality "INFO" "========================================="
  log_quality "INFO" "Total:   $total"
  log_quality "INFO" "Passed:  $passed"
  log_quality "ERROR" "Failed:  $failed"

  if [[ $failed -gt 0 ]]; then
    return 1
  fi
}

cmd_report() {
  local file="$1"

  if [[ -z "$file" ]]; then
    log_quality "ERROR" "Usage: ${0##*/} report <file>"
    exit 1
  fi

  generate_report "$file"
}

cmd_check_word_count() {
  local file="$1"

  if [[ -z "$file" ]]; then
    log_quality "ERROR" "Usage: ${0##*/} check-word-count <file>"
    exit 1
  fi

  validate_word_count "$file"
}

# ============================================
# MAIN
# ============================================

main() {
  # Check if at least one argument provided
  if [[ $# -lt 1 ]]; then
    usage
  fi

  local command="$1"
  shift

  case "$command" in
    validate)
      cmd_validate "$@"
      ;;
    validate-drafts)
      cmd_validate_drafts
      ;;
    validate-all)
      cmd_validate_all
      ;;
    report)
      cmd_report "$@"
      ;;
    check-word-count)
      cmd_check_word_count "$@"
      ;;
    -h|--help|help)
      usage
      ;;
    *)
      log_quality "ERROR" "Unknown command: $command"
      echo ""
      usage
      ;;
  esac
}

# Run main
main "$@"
