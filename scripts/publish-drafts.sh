#!/bin/bash
# ============================================
# PUBLISH DRAFTS - Enhanced with Phase 1 Libraries
# ============================================
# Convert draft posts to published
# Usage: ./scripts/publish-drafts.sh [post-path] [options]
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
CONTENT_DIR=$(get_config "CONTENT_DIR" "content/routing")
CREATE_BACKUPS=$(get_config "DEPLOY_CREATE_BACKUPS" "true")
BACKUP_DIR="${PROJECT_ROOT}/$(get_config "AUTOMATION_BACKUP_DIR" "/tmp/ai-automation-backups")"

# ============================================
# FUNCTIONS
# ============================================

show_usage() {
  cat << EOF
Usage: ${0##*/} [post-path] [options]

Arguments:
  post-path    Path to post index.md file (optional)
                If not provided, lists all drafts for selection

Options:
  --validate      Validate post before publishing
  --backup        Create backup before publishing
  --category CAT  Publish all drafts in category
  --force         Skip confirmation prompts
  --help          Show this help message

Examples:
  ${0##*/}
  ${0##*/} content/routing/ospf/virtual-links/index.md
  ${0##*/} content/routing/ospf/virtual-links/index.md --validate
  ${0##*/} --category ospf --validate

EOF
  exit 0
}

create_backup() {
  local file="$1"

  if [[ "$CREATE_BACKUPS" != "true" ]]; then
    return 0
  fi

  local timestamp
  timestamp=$(date +%Y%m%d_%H%M%S)
  local backup_path="${BACKUP_DIR}/${timestamp}"

  mkdir -p "$backup_path"

  local post_dir
  post_dir=$(dirname "$file")

  cp -r "$post_dir" "$backup_path/"

  log_deployment "INFO" "Backup created: ${backup_path}/"
}

publish_post() {
  local file="$1"
  local validate="$2"
  local backup="$3"

  log_deployment "INFO" "Publishing: $file"

  # Check if file exists
  if [[ ! -f "$file" ]]; then
    log_deployment "ERROR" "File not found: $file"
    return 1
  fi

  # Validate if requested
  if [[ "$validate" == "true" ]]; then
    log_deployment "INFO" "Validating post before publishing..."

    local quality_gate_script="${PROJECT_ROOT}/scripts/quality-gate.sh"

    if ! bash "$quality_gate_script" validate "$file"; then
      log_deployment "ERROR" "Validation failed. Post not published."
      log_deployment "ERROR" "Fix validation errors before publishing."
      return 1
    fi

    log_deployment "SUCCESS" "✓ Validation passed"
  fi

  # Create backup
  if [[ "$backup" == "true" ]]; then
    create_backup "$file"
  fi

  # Check current draft status
  local current_status
  current_status=$(sed -n '/^+++/,/^+++/p' "$file" | grep 'draft' | sed 's/draft *= *//;s/"//g;s/ *$//')

  if [[ "$current_status" == "false" ]]; then
    log_deployment "WARNING" "Post is already published (draft = false)"
    return 0
  fi

  # Publish the post
  if [[ "$OSTYPE" == "darwin"* ]]; then
    sed -i '' 's/draft = true/draft = false/' "$file"
  else
    sed -i 's/draft = true/draft = false/' "$file"
  fi

  log_deployment "SUCCESS" "✓ Post published successfully"

  # Show post info
  local title
  title=$(sed -n '/^+++/,/^+++/p' "$file" | grep 'title' | sed "s/title = *//;s/'//g;s/ *$//")

  log_deployment "INFO" "Title: $title"
  log_deployment "INFO" "File: $file"
  log_deployment "INFOe "Remember to commit and push when ready"
}

list_drafts() {
  log_deployment "INFO" "Finding draft posts..."
  echo ""

  local drafts
  drafts=$(find "${PROJECT_ROOT}/${CONTENT_DIR}" -name "index.md" -exec grep -l 'draft = true' {} \;)

  if [[ -z "$drafts" ]]; then
    log_deployment "INFO" "No draft posts found"
    return 0
  fi

  local index=1
  while IFS= read -r draft; do
    local title
    title=$(sed -n '/^+++/,/^+++/p' "$draft" | grep 'title' | sed "s/title = *//;s/'//g;s/ *$//")
    local category
    category=$(echo "$draft" | sed "s|${PROJECT_ROOT}/${CONTENT_DIR}/||" | cut -d'/' -f1)

    echo "  [$index] ${title}"
    echo "      Category: ${category}"
    echo "      Path: ${draft}"
    echo ""
    ((index++))
  done <<< "$drafts"
}

publish_category() {
  local category="$1"
  local validate="$2"
  local backup="$3"
  local force="$4"

  log_deployment "INFO" "Publishing all drafts in category: $category"

  local drafts
  drafts=$(find "${PROJECT_ROOT}/${CONTENT_DIR}/${category}" -name "index.md" -exec grep -l 'draft = true' {} \;)

  if [[ -z "$drafts" ]]; then
    log_deployment "INFO" "No draft posts found in category: $category"
    return 0
  fi

  if [[ "$force" != "true" ]]; then
    echo -n "Publish $(echo "$drafts" | wc -l) draft(s) in ${category}? [y/N] "
    read -r response
    if [[ ! "$response" =~ ^[Yy]$ ]]; then
      log_deployment "INFO" "Cancelled"
      return 0
    fi
  fi

  local published=0
  local failed=0

  while IFS= read -r draft; do
    if publish_post "$draft" "$validate" "$backup"; then
      ((published++))
    else
      ((failed++))
    fi
  done <<< "$drafts"

  log_deployment "INFO" "Published: $published, Failed: $failed"

  if [[ $failed -gt 0 ]]; then
    return 1
  fi
}

publish_all_drafts() {
  local validate="$1"
  local backup="$2"
  local force="$3"

  log_deployment "INFO" "Publishing ALL draft posts"

  local drafts
  drafts=$(find "${PROJECT_ROOT}/${CONTENT_DIR}" -name "index.md" -exec grep -l 'draft = true' {} \;)

  if [[ -z "$drafts" ]]; then
    log_deployment "INFO" "No draft posts found"
    return 0
  fi

  if [[ "$force" != "true" ]]; then
    echo -n "Publish $(echo "$drafts" | wc -l) draft(s)? [y/N] "
    read -r response
    if [[ ! "$response" =~ ^[Yy]$ ]]; then
      log_deployment "INFO" "Cancelled"
      return 0
    fi
  fi

  local published=0
  local failed=0

  while IFS= read -r draft; do
    if publish_post "$draft" "$validate" "$backup"; then
      ((published++))
    else
      ((failed++))
    fi
  done <<< "$drafts"

  log_deployment "INFO" "Published: $published, Failed: $failed"

  if [[ $failed -gt 0 ]]; then
    return 1
  fi
}

# ============================================
# MAIN
# ============================================

main() {
  local post_file=""
  local validate="false"
  local backup="false"
  local category=""
  local force="false"

  # Parse arguments
  while [[ $# -gt 0 ]]; do
    case "$1" in
      --validate)
        validate="true"
        shift
        ;;
      --backup)
        backup="true"
        shift
        ;;
      --category)
        category="$2"
        shift 2
        ;;
      --force)
        force="true"
        shift
        ;;
      --help|-h)
        show_usage
        ;;
      -*)
        log_deployment "ERROR" "Unknown option: $1"
        echo ""
        show_usage
        ;;
      *)
        post_file="$1"
        shift
        ;;
    esac
  done

  # Make path absolute if relative
  if [[ -n "$post_file" ]] && [[ ! "$post_file" = /* ]]; then
    post_file="${PROJECT_ROOT}/${post_file}"
  fi

  # Execute based on arguments
  if [[ -n "$category" ]]; then
    publish_category "$category" "$validate" "$backup" "$force"
  elif [[ -n "$post_file" ]]; then
    publish_post "$post_file" "$validate" "$backup"
  elif [[ -z "$post_file" ]]; then
    # List drafts and ask for confirmation
    list_drafts
    echo ""
    publish_all_drafts "$validate" "$backup" "$force"
  fi
}

# Run main
main "$@"

