#!/usr/bin/env bash
#
# Migrate Terraform state from direct layout to module-wrapped layout.
#
# When adopting the published module, an existing fork's state paths change:
#
#   BEFORE (direct root):   module.repositories["repo-name"].github_repository.this
#   AFTER (wrapped module): module.github_org.module.repositories["repo-name"].github_repository.this
#
# This script lists current state paths matching the direct layout and generates
# the terraform state mv commands required to migrate them.
#
# Usage:
#   ./scripts/migrate-state.sh [OPTIONS]
#
# Options:
#   -s, --source-prefix PREFIX  Current state path prefix (default: "")
#                               Set this if repos are already under a module.
#   -t, --target-prefix PREFIX  Target state path prefix
#                               (default: "module.github_org.")
#   -d, --dry-run               Print commands without executing them (default)
#   -x, --execute               Execute the terraform state mv commands
#   -h, --help                  Show this help message
#
# Examples:
#   # Preview migration commands (safe - no changes)
#   ./scripts/migrate-state.sh
#
#   # Preview with custom target module name
#   ./scripts/migrate-state.sh --target-prefix "module.my_org."
#
#   # Execute the migration
#   ./scripts/migrate-state.sh --execute
#
# Requirements:
#   - terraform initialized in the project root directory
#

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
TF_DIR="$PROJECT_ROOT"

# Defaults
SOURCE_PREFIX=""
TARGET_PREFIX="module.github_org."
EXECUTE=false

log_info()    { echo -e "${BLUE}[INFO]${NC} $1"; }
log_success() { echo -e "${GREEN}[OK]${NC} $1"; }
log_warn()    { echo -e "${YELLOW}[WARN]${NC} $1"; }
log_error()   { echo -e "${RED}[ERROR]${NC} $1" >&2; }

show_help() {
    head -50 "$0" | tail -47 | sed 's/^#//' | sed 's/^ //'
    exit 0
}

check_requirements() {
    if ! command -v terraform &>/dev/null; then
        log_error "terraform not found in PATH"
        exit 1
    fi

    if [[ ! -d "$TF_DIR" ]]; then
        log_error "Terraform directory not found: $TF_DIR"
        exit 1
    fi
}

parse_args() {
    while [[ $# -gt 0 ]]; do
        case "$1" in
            -s|--source-prefix)
                SOURCE_PREFIX="$2"
                shift 2
                ;;
            -t|--target-prefix)
                TARGET_PREFIX="$2"
                shift 2
                ;;
            -d|--dry-run)
                EXECUTE=false
                shift
                ;;
            -x|--execute)
                EXECUTE=true
                shift
                ;;
            -h|--help)
                show_help
                ;;
            *)
                log_error "Unknown option: $1"
                exit 1
                ;;
        esac
    done
}

main() {
    parse_args "$@"
    check_requirements

    log_info "Scanning Terraform state for repository resources..."
    log_info "  Source prefix : '${SOURCE_PREFIX}' (current paths)"
    log_info "  Target prefix : '${TARGET_PREFIX}' (new paths)"
    echo ""

    cd "$TF_DIR"

    # Find all entries under module.repositories[*] (with optional source prefix)
    local grep_pattern="${SOURCE_PREFIX}module\.repositories\[\"[^\"]*\"\]"
    local entries
    entries=$(terraform state list 2>/dev/null | grep -E "$grep_pattern" || true)

    if [[ -z "$entries" ]]; then
        log_warn "No state entries found matching pattern: ${SOURCE_PREFIX}module.repositories[*]"
        log_warn "Nothing to migrate."
        exit 0
    fi

    local count
    count=$(echo "$entries" | wc -l | tr -d ' ')
    log_info "Found $count state entries to migrate:"
    echo ""

    local cmds=()
    while IFS= read -r entry; do
        # Replace the source prefix with the target prefix
        local new_entry="${TARGET_PREFIX}${entry#${SOURCE_PREFIX}}"
        local cmd="terraform state mv '${entry}' '${new_entry}'"
        cmds+=("$cmd")
        echo "  $cmd"
    done <<< "$entries"

    echo ""

    if [[ "$EXECUTE" == false ]]; then
        log_warn "DRY-RUN: no changes made. Pass --execute to apply the above commands."
        echo ""
        echo "To run the migration:"
        echo "  $0 --execute"
    else
        log_info "Executing $count terraform state mv commands..."
        echo ""
        local failed=0
        for cmd in "${cmds[@]}"; do
            if eval "$cmd"; then
                log_success "Moved: $cmd"
            else
                log_error "Failed: $cmd"
                ((failed++))
            fi
        done

        echo ""
        if [[ $failed -gt 0 ]]; then
            log_warn "$failed moves failed — check state manually."
            exit 1
        else
            log_success "Migration complete. $count resources moved."
            log_info "Next: update your Terraform root to use the module source and run terraform plan."
        fi
    fi
}

main "$@"
