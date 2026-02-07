#!/usr/bin/env bash
#
# Remove repositories from Terraform management
#
# This script removes repositories from Terraform state without destroying them
# on GitHub. Use this for archived repos or repos you no longer want to manage.
#
# Usage:
#   ./scripts/offboard-repos.sh [OPTIONS] [REPO_NAMES...]
#
# Options:
#   -d, --dry-run         Show what would be done without making changes
#   -c, --remove-config   Also remove from config/repository/*.yml files
#   -l, --list            List all repositories currently in Terraform state
#   -h, --help            Show this help message
#
# Examples:
#   # List repos in Terraform state
#   ./scripts/offboard-repos.sh --list
#
#   # Remove specific repos from state (dry-run)
#   ./scripts/offboard-repos.sh --dry-run repo1 repo2
#
#   # Remove repos from state and config files
#   ./scripts/offboard-repos.sh --remove-config repo1 repo2
#
# Requirements:
#   - terraform initialized in terraform/ directory
#
# Notes:
#   - This does NOT delete repositories from GitHub
#   - This removes them from Terraform management only
#   - Archived repos should be removed to avoid Terraform errors
#

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
TF_DIR="$PROJECT_ROOT/terraform"
REPOSITORY_CONFIG_PATH="$PROJECT_ROOT/config/repository"

# Default values
DRY_RUN=false
REMOVE_CONFIG=false
LIST=false
REPOS=()

# Helper functions
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[OK]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1" >&2
}

show_help() {
    head -35 "$0" | tail -32 | sed 's/^#//' | sed 's/^ //'
    exit 0
}

# Check required tools
check_requirements() {
    if ! command -v terraform &> /dev/null; then
        log_error "terraform not found"
        exit 1
    fi

    if [[ ! -d "$TF_DIR" ]]; then
        log_error "Terraform directory not found: $TF_DIR"
        exit 1
    fi
}

# List repositories in Terraform state
list_repos_in_state() {
    log_info "Repositories in Terraform state:"
    echo ""

    cd "$TF_DIR"
    local repos
    repos=$(terraform state list 2>/dev/null | grep 'module.repositories\[.*\]\.github_repository\.this$' | sed 's/.*\["\([^"]*\)"\].*/\1/' | sort -u)

    if [[ -z "$repos" ]]; then
        log_warn "No repositories found in Terraform state"
        return
    fi

    echo "$repos" | while read -r repo; do
        # Check if repo exists in config
        if grep -rq "^$repo:" "$REPOSITORY_CONFIG_PATH"/*.yml 2>/dev/null; then
            echo "  $repo"
        else
            echo "  $repo (not in config)"
        fi
    done

    echo ""
    echo "$repos" | wc -l | xargs echo "Total:"
}

# Remove repository from Terraform state
remove_from_state() {
    local repo="$1"
    local dry_run="$2"

    cd "$TF_DIR"

    # Find all state entries for this repo
    local entries
    entries=$(terraform state list 2>/dev/null | grep "module.repositories\[\"$repo\"\]" || true)

    if [[ -z "$entries" ]]; then
        log_warn "$repo not found in Terraform state"
        return 0
    fi

    local count
    count=$(echo "$entries" | wc -l)

    if [[ "$dry_run" == true ]]; then
        log_info "[DRY-RUN] Would remove $count state entries for $repo:"
        echo "$entries" | sed 's/^/    /'
        return 0
    fi

    log_info "Removing $count state entries for $repo..."

    echo "$entries" | while read -r entry; do
        if terraform state rm "$entry" 2>&1; then
            log_success "Removed: $entry"
        else
            log_error "Failed to remove: $entry"
        fi
    done
}

# Remove repository from config files
remove_from_config() {
    local repo="$1"
    local dry_run="$2"

    # Find which file contains the repo
    local config_file
    config_file=$(grep -rl "^$repo:" "$REPOSITORY_CONFIG_PATH"/*.yml 2>/dev/null | head -1 || true)

    if [[ -z "$config_file" ]]; then
        log_warn "$repo not found in any config file"
        return 0
    fi

    if [[ "$dry_run" == true ]]; then
        log_info "[DRY-RUN] Would remove $repo from $config_file"
        return 0
    fi

    log_info "Removing $repo from $config_file..."

    # Use sed to remove the repo block (from repo: to next repo: or end of file)
    # This is a simple approach - for complex YAML, manual editing may be needed
    local temp_file
    temp_file=$(mktemp)

    # Use awk to remove the repo block
    awk -v repo="$repo:" '
        BEGIN { skip = 0 }
        /^[a-zA-Z0-9_-]+:/ {
            if ($0 == repo) {
                skip = 1
                next
            } else {
                skip = 0
            }
        }
        !skip { print }
    ' "$config_file" > "$temp_file"

    mv "$temp_file" "$config_file"
    log_success "Removed $repo from $config_file"
}

# Parse command line arguments
parse_args() {
    while [[ $# -gt 0 ]]; do
        case "$1" in
            -d|--dry-run)
                DRY_RUN=true
                shift
                ;;
            -c|--remove-config)
                REMOVE_CONFIG=true
                shift
                ;;
            -l|--list)
                LIST=true
                shift
                ;;
            -h|--help)
                show_help
                ;;
            -*)
                log_error "Unknown option: $1"
                exit 1
                ;;
            *)
                REPOS+=("$1")
                shift
                ;;
        esac
    done
}

# Main function
main() {
    parse_args "$@"
    check_requirements

    # List mode
    if [[ "$LIST" == true ]]; then
        list_repos_in_state
        exit 0
    fi

    # Require repos
    if [[ ${#REPOS[@]} -eq 0 ]]; then
        log_error "No repositories specified. Use --list to see repos in state."
        echo "Usage: $0 [OPTIONS] repo1 repo2 ..."
        exit 1
    fi

    log_info "Offboarding ${#REPOS[@]} repositories..."
    if [[ "$DRY_RUN" == true ]]; then
        log_warn "DRY-RUN mode - no changes will be made"
    fi
    echo ""

    local failed=0
    for repo in "${REPOS[@]}"; do
        log_info "Processing $repo..."

        # Remove from Terraform state
        if ! remove_from_state "$repo" "$DRY_RUN"; then
            ((failed++))
            continue
        fi

        # Remove from config if requested
        if [[ "$REMOVE_CONFIG" == true ]]; then
            remove_from_config "$repo" "$DRY_RUN"
        fi

        echo ""
    done

    if [[ $failed -gt 0 ]]; then
        log_warn "$failed repositories failed to offboard"
        exit 1
    else
        log_success "All repositories offboarded successfully"
        if [[ "$REMOVE_CONFIG" == false ]]; then
            log_info "Note: Config files were not modified. Use --remove-config to also remove from YAML."
        fi
    fi
}

main "$@"
