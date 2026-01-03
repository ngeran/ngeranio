#!/bin/bash
# ============================================
# AI CONTENT MANAGER - Content Management Script
# ============================================
# Creates, updates, and manages blog posts
# Integrates with quality gate for validation
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
VALID_CATEGORIES=("ospf" "bgp" "mpls" "junos")
CONTENT_TEMPLATE=$(get_config "CONTENT_TEMPLATE_PATH" ".ai-content-template.md")
AUTO_BACKUP=$(get_config "CONTENT_AUTO_BACKUP" "true")
BACKUP_DIR="${PROJECT_ROOT}/$(get_config "AUTOMATION_BACKUP_DIR" "/tmp/ai-automation-backups")"

# ============================================
# USAGE
# ============================================
usage() {
  cat << EOF
Usage: ${0##*/} <command> [options]

Commands:
  create <category> <title>    Create a new blog post
  update <file>               Update an existing post
  delete <file>               Delete a post (with confirmation)
  list [drafts|published]      List posts
  info <file>                 Show detailed post information
  validate <file>             Validate a post (uses quality-gate.sh)

Options:
  --no-backup                 Skip backup before update
  --force                     Force operation without confirmation
  --verbose                   Show detailed output

Examples:
  ${0##*/} create ospf "OSPF Virtual Links"
  ${0##*/} list drafts
  ${0##*/} update content/routing/ospf/virtual-links/index.md
  ${0##*/} info content/routing/bgp/bgp-attributes/index.md

EOF
  exit 0
}

# ============================================
# HELPER FUNCTIONS
# ============================================

# Validate category
validate_category() {
  local category="$1"

  for valid_cat in "${VALID_CATEGORIES[@]}"; do
    if [[ "$category" == "$valid_cat" ]]; then
      return 0
    fi
  done

  log_content "ERROR" "Invalid category: $category"
  log_content "ERROR" "Valid categories: ${VALID_CATEGORIES[*]}"
  return 1
}

# Generate slug from title
generate_slug() {
  local title="$1"
  echo "$title" | tr '[:upper:]' '[:lower:]' | sed 's/[^a-z0-9]/-/g' | sed 's/-\+/-/g' | sed 's/^-\|-$//g'
}

# Create backup
create_backup() {
  local file="$1"

  if [[ "$AUTO_BACKUP" != "true" ]]; then
    return 0
  fi

  local timestamp
  timestamp=$(date +%Y%m%d_%H%M%S)
  local backup_path="${BACKUP_DIR}/${timestamp}"

  mkdir -p "$backup_path"

  local post_dir
  post_dir=$(dirname "$file")

  cp -r "$post_dir" "$backup_path/"

  log_content "INFO" "Backup created: ${backup_path}/"
}

# ============================================
# CONTENT CREATION
# ============================================

create_post() {
  local category="$1"
  local title="$2"
  local force="${3:-false}"

  log_content "INFO" "Creating new post..."
  log_content "INFO" "Category: $category"
  log_content "INFO" "Title: $title"

  # Validate category
  if ! validate_category "$category"; then
    return 1
  fi

  # Generate slug
  local slug
  slug=$(generate_slug "$title")

  log_content "INFO" "Generated slug: $slug"

  # Create directory path
  local post_dir="${CONTENT_DIR}/${category}/${slug}"

  # Check if directory already exists
  if [[ -d "$post_dir" ]]; then
    if [[ "$force" != "true" ]]; then
      log_content "ERROR" "Post already exists: $post_dir"
      log_content "ERROR" "Use --force to overwrite"
      return 1
    else
      log_content "WARNING" "Overwriting existing post: $post_dir"
    fi
  fi

  # Create directory
  mkdir -p "$post_dir"

  # Check if template exists
  if [[ ! -f "$CONTENT_TEMPLATE" ]]; then
    log_content "WARNING" "Template not found: $CONTENT_TEMPLATE"
    log_content "INFO" "Creating basic post structure..."

    # Create basic frontmatter
    cat > "${post_dir}/index.md" << EOF
+++
title = '${title}'
date = $(date -Iseconds)
draft = true
tags = []
featured_image = 'featured.png'
summary = 'Brief description of the post'
+++

## Overview

[Brief introduction to the topic]

## Key Concepts

[Explain the main concepts]

## Configuration

[Configuration examples if applicable]

\`\`\`junos
# Configuration example
set protocols ospf area 0.0.0.0 interface all
\`\`\`

## Verification

[How to verify the configuration works]

## Summary

[Key takeaways]
EOF
  else
    # Copy template
    cp "$CONTENT_TEMPLATE" "${post_dir}/index.md"

    # Update title in frontmatter
    if [[ "$OSTYPE" == "darwin"* ]]; then
      sed -i '' "s|TITLE_PLACEHOLDER|${title}|g" "${post_dir}/index.md"
    else
      sed -i "s|TITLE_PLACEHOLDER|${title}|g" "${post_dir}/index.md"
    fi

    # Update date
    local current_date
    current_date=$(date -Iseconds)
    if [[ "$OSTYPE" == "darwin"* ]]; then
      sed -i '' "s|DATE_PLACEHOLDER|${current_date}|g" "${post_dir}/index.md"
    else
      sed -i "s|DATE_PLACEHOLDER|${current_date}|g" "${post_dir}/index.md"
    fi
  fi

  # Create placeholder featured image
  create_featured_image "$post_dir"

  log_content "SUCCESS" "✓ Post created: ${post_dir}/index.md"
  log_content "INFO" "Next steps:"
  log_content "INFO" "  1. Edit the post: ${post_dir}/index.md"
  log_content "INFO" "  2. Add content and images to: ${post_dir}/"
  log_content "INFO" "  3. Validate: ./scripts/quality-gate.sh validate ${post_dir}/index.md"
  log_content "INFO" "  4. Preview: ./scripts/preview.sh"
}

# Create featured image placeholder
create_featured_image() {
  local post_dir="$1"
  local featured_image="${post_dir}/featured.png"

  # Try ImageMagick first
  if command -v convert &>/dev/null; then
    local width
    width=$(get_config "IMAGE_DEFAULT_WIDTH" "1200")
    local height
    height=$(get_config "IMAGE_DEFAULT_HEIGHT" "630")
    local color
    color=$(get_config "IMAGE_PLACEHOLDER_COLOR" "#5e81ac")

    convert -size "${width}x${height}" "xc:${color}" \
      -gravity center \
      -pointsize 72 \
      -fill white \
      -annotate +0+0 "Featured Image" \
      "$featured_image" 2>/dev/null

    if [[ $? -eq 0 ]]; then
      log_content "INFO" "✓ Featured image created with ImageMagick"
      return 0
    fi
  fi

  # Fallback: create empty placeholder
  touch "$featured_image"
  log_content "INFO" "✓ Featured image placeholder created"
}

# ============================================
# CONTENT UPDATE
# ============================================

update_post() {
  local file="$1"
  local no_backup="${2:-false}"

  log_content "INFO" "Updating post: $file"

  # Check if file exists
  if [[ ! -f "$file" ]]; then
    log_content "ERROR" "File not found: $file"
    return 1
  fi

  # Create backup unless disabled
  if [[ "$no_backup" != "true" ]]; then
    create_backup "$file"
  fi

  # Open in editor
  local editor
  editor=$(get_config "CONTENT_EDITOR_CODE" "code")

  if command -v "$editor" &>/dev/null; then
    log_content "INFO" "Opening in $editor..."
    "$editor" "$file"
  else
    log_content "WARNING" "Editor '$editor' not found"
    log_content "INFO" "Please edit: $file"
  fi

  # Validate after edit
  local validate_on_create
  validate_on_create=$(get_config "DRAFT_VALIDATE_ON_CREATE" "true")

  if [[ "$validate_on_create" == "true" ]]; then
    log_content "INFO" "Validating updated post..."
    local quality_gate_script="${PROJECT_ROOT}/scripts/quality-gate.sh"
    bash "$quality_gate_script" validate "$file"
  fi

  log_content "SUCCESS" "✓ Post updated: $file"
}

# ============================================
# CONTENT DELETION
# ============================================

delete_post() {
  local file="$1"
  local force="${2:-false}"

  log_content "WARNING" "Deleting post: $file"

  # Check if file exists
  if [[ ! -f "$file" ]]; then
    log_content "ERROR" "File not found: $file"
    return 1
  fi

  # Get post directory
  local post_dir
  post_dir=$(dirname "$file")

  # Confirm deletion
  if [[ "$force" != "true" ]]; then
    echo -n "Are you sure you want to delete ${post_dir}? [y/N] "
    read -r response
    if [[ ! "$response" =~ ^[Yy]$ ]]; then
      log_content "INFO" "Deletion cancelled"
      return 0
    fi
  fi

  # Create backup before deletion
  create_backup "$file"

  # Delete directory
  rm -rf "$post_dir"

  log_content "SUCCESS" "✓ Post deleted: $post_dir"
}

# ============================================
# CONTENT LISTING
# ============================================

list_drafts() {
  log_content "INFO" "Draft posts:"
  echo ""

  local drafts
  drafts=$(find "${PROJECT_ROOT}/${CONTENT_DIR}" -name "index.md" -exec grep -l 'draft = true' {} \;)

  if [[ -z "$drafts" ]]; then
    log_content "INFO" "No draft posts found"
    return 0
  fi

  while IFS= read -r draft; do
    local title
    title=$(sed -n '/^+++/,/^+++/p' "$draft" | grep 'title' | sed "s/title = *//;s/'//g;s/ *$//")
    local category
    category=$(echo "$draft" | sed "s|${PROJECT_ROOT}/${CONTENT_DIR}/||" | cut -d'/' -f1)

    echo "  📝 ${title}"
    echo "     Category: ${category}"
    echo "     Path: ${draft}"
    echo ""
  done <<< "$drafts"
}

list_published() {
  log_content "INFO" "Published posts:"
  echo ""

  local published
  published=$(find "${PROJECT_ROOT}/${CONTENT_DIR}" -name "index.md" -exec grep -l 'draft = false' {} \;)

  if [[ -z "$published" ]]; then
    log_content "INFO" "No published posts found"
    return 0
  fi

  while IFS= read -r post; do
    local title
    title=$(sed -n '/^+++/,/^+++/p' "$post" | grep 'title' | sed "s/title = *//;s/'//g;s/ *$//")
    local category
    category=$(echo "$post" | sed "s|${PROJECT_ROOT}/${CONTENT_DIR}/||" | cut -d'/' -f1)
    local date
    date=$(sed -n '/^+++/,/^+++/p' "$post" | grep 'date' | sed 's/date = *//;s/"//g;s/ *$//;s/T.*//')

    echo "  ✅ ${title}"
    echo "     Category: ${category}"
    echo "     Published: ${date}"
    echo "     Path: ${post}"
    echo ""
  done <<< "$published"
}

# ============================================
# POST INFORMATION
# ============================================

show_post_info() {
  local file="$1"

  log_content "INFO" "Post Information:"
  echo ""

  # Check if file exists
  if [[ ! -f "$file" ]]; then
    log_content "ERROR" "File not found: $file"
    return 1
  fi

  # File stats
  local size
  size=$(wc -c < "$file" | tr -d ' ')
  local words
  words=$(wc -w < "$file" | tr -d ' ')
  local lines
  lines=$(wc -l < "$file" | tr -d ' ')

  echo "  📄 File: $file"
  echo "  📊 Size: ${size} bytes"
  echo "  📝 Words: $words"
  echo "  📃 Lines: $lines"
  echo ""

  # Frontmatter info
  echo "  📋 Frontmatter:"
  sed -n '/^+++/,/^+++/p' "$file" | sed '1d;$d' | while IFS= read -r line; do
    echo "     $line"
  done
  echo ""

  # Images in directory
  local post_dir
  post_dir=$(dirname "$file")
  local images
  images=$(find "$post_dir" -type f \( -name "*.png" -o -name "*.jpg" -o -name "*.jpeg" -o -name "*.gif" -o -name "*.svg" \) 2>/dev/null)

  if [[ -n "$images" ]]; then
    echo "  🖼️  Images:"
    while IFS= read -r img; do
      local img_name
      img_name=$(basename "$img")
      local img_size
      img_size=$(wc -c < "$img" | tr -d ' ')
      echo "     • ${img_name} (${img_size} bytes)"
    done <<< "$images"
    echo ""
  fi

  # Validation status
  echo "  ✅ Validation Status:"
  local quality_gate_script="${PROJECT_ROOT}/scripts/quality-gate.sh"
  bash "$quality_gate_script" validate "$file" 2>&1 | grep -E "(PASSED|FAILED|Errors|Warnings)" | sed 's/^/     /'
}

# ============================================
# COMMAND HANDLERS
# ============================================

cmd_create() {
  local category="$1"
  local title="$2"
  local force=false

  # Parse options
  while [[ $# -gt 0 ]]; do
    case "$1" in
      --force)
        force=true
        shift
        ;;
      *)
        shift
        ;;
    esac
  done

  if [[ -z "$category" ]] || [[ -z "$title" ]]; then
    log_content "ERROR" "Usage: ${0##*/} create <category> <title>"
    exit 1
  fi

  create_post "$category" "$title" "$force"
}

cmd_update() {
  local file="$1"
  local no_backup=false

  # Parse options
  while [[ $# -gt 0 ]]; do
    case "$1" in
      --no-backup)
        no_backup=true
        shift
        ;;
      *)
        shift
        ;;
    esac
  done

  if [[ -z "$file" ]]; then
    log_content "ERROR" "Usage: ${0##*/} update <file>"
    exit 1
  fi

  # Make path absolute if relative
  if [[ ! "$file" = /* ]]; then
    file="${PROJECT_ROOT}/${file}"
  fi

  update_post "$file" "$no_backup"
}

cmd_delete() {
  local file="$1"
  local force=false

  # Parse options
  while [[ $# -gt 0 ]]; do
    case "$1" in
      --force)
        force=true
        shift
        ;;
      *)
        shift
        ;;
    esac
  done

  if [[ -z "$file" ]]; then
    log_content "ERROR" "Usage: ${0##*/} delete <file>"
    exit 1
  fi

  # Make path absolute if relative
  if [[ ! "$file" = /* ]]; then
    file="${PROJECT_ROOT}/${file}"
  fi

  delete_post "$file" "$force"
}

cmd_list() {
  local filter="$1"

  case "$filter" in
    drafts)
      list_drafts
      ;;
    published)
      list_published
      ;;
    "")
      echo "Draft posts:"
      list_drafts
      echo ""
      echo "Published posts:"
      list_published
      ;;
    *)
      log_content "ERROR" "Invalid filter: $filter"
      log_content "ERROR" "Valid filters: drafts, published"
      exit 1
      ;;
  esac
}

cmd_info() {
  local file="$1"

  if [[ -z "$file" ]]; then
    log_content "ERROR" "Usage: ${0##*/} info <file>"
    exit 1
  fi

  # Make path absolute if relative
  if [[ ! "$file" = /* ]]; then
    file="${PROJECT_ROOT}/${file}"
  fi

  show_post_info "$file"
}

cmd_validate() {
  local file="$1"

  if [[ -z "$file" ]]; then
    log_content "ERROR" "Usage: ${0##*/} validate <file>"
    exit 1
  fi

  # Make path absolute if relative
  if [[ ! "$file" = /* ]]; then
    file="${PROJECT_ROOT}/${file}"
  fi

  # Call quality-gate.sh script with full path
  local quality_gate_script="${PROJECT_ROOT}/scripts/quality-gate.sh"
  bash "$quality_gate_script" validate "$file"
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
    create)
      cmd_create "$@"
      ;;
    update)
      cmd_update "$@"
      ;;
    delete)
      cmd_delete "$@"
      ;;
    list)
      cmd_list "$@"
      ;;
    info)
      cmd_info "$@"
      ;;
    validate)
      cmd_validate "$@"
      ;;
    -h|--help|help)
      usage
      ;;
    *)
      log_content "ERROR" "Unknown command: $command"
      echo ""
      usage
      ;;
  esac
}

# Run main
main "$@"
