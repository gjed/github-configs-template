#!/usr/bin/env bash
#
# Onboard existing GitHub repositories into Terraform management
#
# This script helps import existing repositories into Terraform state and
# optionally generates YAML configuration entries for them.
#
# Usage:
#   ./scripts/onboard-repos.sh [OPTIONS] [REPO_NAMES...]
#
# Options:
#   -o, --org ORG             GitHub organization (default: from config/config.yml)
#   -g, --groups GROUPS       Comma-separated list of groups (default: base)
#   -y, --generate-yaml       Generate YAML entries for repositories.yml
#   -i, --import              Import repositories into Terraform state
#   -l, --list                List all repositories in the organization
#   -f, --filter PATTERN      Filter repositories by name pattern (with --list)
#   -m, --module-path PREFIX  Terraform module path prefix to prepend to resource
#                             addresses (e.g. "module.github_org." for wrapped
#                             consumers). Default: "" (direct layout).
#   -d, --dry-run             Show what would be done without making changes
#   -h, --help                Show this help message
#
# Examples:
#   # List all repos in the organization
#   ./scripts/onboard-repos.sh --list
#
#   # Generate YAML for specific repos
#   ./scripts/onboard-repos.sh --generate-yaml repo1 repo2 repo3
#
#   # Import specific repos into Terraform (direct layout - this repo as root)
#   ./scripts/onboard-repos.sh --import repo1 repo2
#
#   # Import repos when using the module from a consumer root
#   ./scripts/onboard-repos.sh --module-path "module.github_org." --import repo1 repo2
#
#   # Full onboarding: generate YAML and import
#   ./scripts/onboard-repos.sh --generate-yaml --import repo1 repo2
#
#   # List and filter repos
#   ./scripts/onboard-repos.sh --list --filter "api-"
#
# Requirements:
#   - gh CLI (GitHub CLI) installed and authenticated
#   - yq (YAML processor) for reading config - falls back to Python if not available
#   - terraform initialized in terraform/ directory (for --import)
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

# Default values
ORG=""
GROUPS="base"
GENERATE_YAML=false
IMPORT=false
LIST=false
FILTER=""
MODULE_PATH=""
DRY_RUN=false
REPOS=()

# Configuration paths (matching Terraform's yaml-config.tf)
REPOSITORY_CONFIG_PATH="$PROJECT_ROOT/config/repository"

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
    head -40 "$0" | tail -37 | sed 's/^#//' | sed 's/^ //'
    exit 0
}

# Read organization from config.yml
get_org_from_config() {
    local config_file="$PROJECT_ROOT/config/config.yml"
    if [[ ! -f "$config_file" ]]; then
        log_error "Config file not found: $config_file"
        exit 1
    fi

    # Try yq first, fall back to Python
    if command -v yq &> /dev/null; then
        yq -r '.organization' "$config_file"
    else
        python3 -c "import yaml; print(yaml.safe_load(open('$config_file'))['organization'])"
    fi
}

# Check required tools
check_requirements() {
    local missing=()

    if ! command -v gh &> /dev/null; then
        missing+=("gh (GitHub CLI)")
    fi

    if ! command -v yq &> /dev/null && ! command -v python3 &> /dev/null; then
        missing+=("yq or python3 (for YAML parsing)")
    fi

    if [[ "$IMPORT" == true ]] && ! command -v terraform &> /dev/null; then
        missing+=("terraform")
    fi

    if [[ ${#missing[@]} -gt 0 ]]; then
        log_error "Missing required tools:"
        for tool in "${missing[@]}"; do
            echo "  - $tool"
        done
        exit 1
    fi

    # Check gh authentication
    if ! gh auth status &> /dev/null; then
        log_error "GitHub CLI not authenticated. Run: gh auth login"
        exit 1
    fi
}

# List repositories in the organization
list_repos() {
    local org="$1"
    local filter="${2:-}"

    log_info "Listing repositories in $org..."

    local repos
    repos=$(gh repo list "$org" --limit 1000 --json name,description,visibility,isArchived \
        --jq '.[] | select(.isArchived == false) | "\(.name)\t\(.visibility)\t\(.description // "")"')

    if [[ -n "$filter" ]]; then
        repos=$(echo "$repos" | grep -i "$filter" || true)
    fi

    if [[ -z "$repos" ]]; then
        log_warn "No repositories found"
        return
    fi

    echo ""
    printf "%-40s %-10s %s\n" "REPOSITORY" "VISIBILITY" "DESCRIPTION"
    printf "%-40s %-10s %s\n" "----------" "----------" "-----------"
    echo "$repos" | while IFS=$'\t' read -r name visibility desc; do
        printf "%-40s %-10s %s\n" "$name" "$visibility" "${desc:0:50}"
    done
    echo ""
    echo "$repos" | wc -l | xargs echo "Total:"
}

# Get repository info from GitHub
get_repo_info() {
    local org="$1"
    local repo="$2"

    gh repo view "$org/$repo" --json name,description,visibility,hasWikiEnabled,hasIssuesEnabled,hasProjectsEnabled,hasDiscussionsEnabled \
        --jq '{name, description, visibility, has_wiki: .hasWikiEnabled, has_issues: .hasIssuesEnabled, has_projects: .hasProjectsEnabled, has_discussions: .hasDiscussionsEnabled}'
}

# Generate YAML entry for a repository
generate_yaml_entry() {
    local org="$1"
    local repo="$2"
    local groups="$3"

    local info
    info=$(get_repo_info "$org" "$repo")

    local description visibility
    description=$(echo "$info" | python3 -c "import sys,json; print(json.load(sys.stdin).get('description') or '')")
    visibility=$(echo "$info" | python3 -c "import sys,json; print(json.load(sys.stdin).get('visibility', 'PRIVATE').lower())")

    # Convert groups string to YAML array
    local groups_yaml
    groups_yaml=$(echo "$groups" | tr ',' '\n' | sed 's/^/    - /' | sed 's/^ *//')

    cat <<EOF

$repo:
  description: "$description"
  groups:
$(echo "$groups" | tr ',' '\n' | sed 's/^/    - /')
  # Visibility: $visibility (verify groups match)
EOF
}

# Import repository into Terraform state
import_repo() {
    local org="$1"
    local repo="$2"
    local dry_run="$3"

    local tf_dir="$PROJECT_ROOT/terraform"

    if [[ ! -d "$tf_dir" ]]; then
        log_error "Terraform directory not found: $tf_dir"
        return 1
    fi

    local import_addr="${MODULE_PATH}module.repositories[\"$repo\"].github_repository.this"
    # GitHub provider expects just the repo name when owner is configured in provider
    local import_id="$repo"

    if [[ "$dry_run" == true ]]; then
        log_info "[DRY-RUN] Would import: $import_addr <- $import_id"
        return 0
    fi

    log_info "Importing $repo..."

    if (cd "$tf_dir" && terraform import "$import_addr" "$import_id" 2>&1); then
        log_success "Imported $repo"
    else
        log_error "Failed to import $repo"
        return 1
    fi
}

# Parse command line arguments
parse_args() {
    while [[ $# -gt 0 ]]; do
        case "$1" in
            -o|--org)
                ORG="$2"
                shift 2
                ;;
            -g|--groups)
                GROUPS="$2"
                shift 2
                ;;
            -y|--generate-yaml)
                GENERATE_YAML=true
                shift
                ;;
            -i|--import)
                IMPORT=true
                shift
                ;;
            -l|--list)
                LIST=true
                shift
                ;;
            -f|--filter)
                FILTER="$2"
                shift 2
                ;;
            -m|--module-path)
                MODULE_PATH="$2"
                shift 2
                ;;
            -d|--dry-run)
                DRY_RUN=true
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

    # Get organization
    if [[ -z "$ORG" ]]; then
        ORG=$(get_org_from_config)
        if [[ "$ORG" == "your-org-name" ]]; then
            log_error "Please configure your organization in config/config.yml or use --org"
            exit 1
        fi
    fi

    log_info "Organization: $ORG"

    # List mode
    if [[ "$LIST" == true ]]; then
        list_repos "$ORG" "$FILTER"
        exit 0
    fi

    # Require repos for other operations
    if [[ ${#REPOS[@]} -eq 0 ]]; then
        log_error "No repositories specified. Use --list to see available repos or provide repo names."
        echo "Usage: $0 [OPTIONS] repo1 repo2 ..."
        exit 1
    fi

    # Generate YAML
    if [[ "$GENERATE_YAML" == true ]]; then
        log_info "Generating YAML entries for ${#REPOS[@]} repositories..."
        echo ""
        echo "# Add the following to config/repository/*.yml:"
        echo "# ================================================"

        for repo in "${REPOS[@]}"; do
            if $DRY_RUN; then
                log_info "[DRY-RUN] Would generate YAML for: $repo"
            else
                generate_yaml_entry "$ORG" "$repo" "$GROUPS"
            fi
        done

        echo ""
        echo "# ================================================"
    fi

    # Import to Terraform
    if [[ "$IMPORT" == true ]]; then
        log_info "Importing ${#REPOS[@]} repositories into Terraform state..."

        # Check if repos are in config (search all YAML files in config/repository/)
        for repo in "${REPOS[@]}"; do
            if ! grep -rq "^$repo:" "$REPOSITORY_CONFIG_PATH"/*.yml 2>/dev/null; then
                log_warn "$repo not found in config/repository/*.yml - add it first or import will fail"
            fi
        done

        echo ""

        local failed=0
        for repo in "${REPOS[@]}"; do
            if ! import_repo "$ORG" "$repo" "$DRY_RUN"; then
                ((failed++))
            fi
        done

        echo ""
        if [[ $failed -gt 0 ]]; then
            log_warn "$failed imports failed"
            exit 1
        else
            log_success "All imports completed"
        fi
    fi

    # If neither action specified, show help
    if [[ "$GENERATE_YAML" == false && "$IMPORT" == false ]]; then
        log_error "No action specified. Use --generate-yaml and/or --import"
        echo "Run '$0 --help' for usage information."
        exit 1
    fi
}

main "$@"
