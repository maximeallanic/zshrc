#!/bin/bash

# =============================================================================
# NIVUUS SHELL - GITHUB RELEASE MANAGER
# =============================================================================

set -euo pipefail

# Colors and formatting
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[0;33m'
readonly BLUE='\033[0;34m'
readonly PURPLE='\033[0;35m'
readonly CYAN='\033[0;36m'
readonly WHITE='\033[0;37m'
readonly BOLD='\033[1m'
readonly NC='\033[0m' # No Color

# Configuration
readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
readonly VERSION_FILE="$PROJECT_ROOT/VERSION"
readonly CHANGELOG_FILE="$PROJECT_ROOT/CHANGELOG.md"
readonly INSTALL_SCRIPT="$PROJECT_ROOT/install.sh"

# Functions
print_header() {
    echo -e "${BLUE}${BOLD}================================${NC}"
    echo -e "${BLUE}${BOLD}  Nivuus Shell Release Manager${NC}"
    echo -e "${BLUE}${BOLD}================================${NC}"
    echo
}

print_step() {
    echo -e "${CYAN}➤ $1${NC}"
}

print_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_error() {
    echo -e "${RED}❌ $1${NC}"
    exit 1
}

print_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

print_info() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

show_usage() {
    echo -e "${WHITE}${BOLD}Usage:${NC}"
    echo -e "  $0 <major|minor|patch> [--dry-run] [--no-push] [--auto-changelog]"
    echo
    echo -e "${WHITE}${BOLD}Arguments:${NC}"
    echo -e "  major     Increment major version (1.0.0 -> 2.0.0)"
    echo -e "  minor     Increment minor version (1.0.0 -> 1.1.0)"
    echo -e "  patch     Increment patch version (1.0.0 -> 1.0.1)"
    echo
    echo -e "${WHITE}${BOLD}Options:${NC}"
    echo -e "  --dry-run         Show what would be done without making changes"
    echo -e "  --no-push         Don't push changes to remote repository"
    echo -e "  --auto-changelog  Use automatic changelog entries (no prompts)"
    echo
    echo -e "${WHITE}${BOLD}Examples:${NC}"
    echo -e "  $0 patch"
    echo -e "  $0 minor --dry-run"
    echo -e "  $0 major --no-push"
    echo -e "  $0 patch --auto-changelog"
}

check_dependencies() {
    local deps=("git" "gh" "sed" "date")
    for dep in "${deps[@]}"; do
        if ! command -v "$dep" &> /dev/null; then
            print_error "Required dependency '$dep' not found. Please install it first."
        fi
    done
}

check_git_status() {
    if ! git diff-index --quiet HEAD --; then
        print_error "Working directory is not clean. Please commit or stash changes first."
    fi
    
    if [[ "$(git rev-parse --abbrev-ref HEAD)" != "master" ]] && [[ "$(git rev-parse --abbrev-ref HEAD)" != "main" ]]; then
        print_warning "Not on main/master branch. Current branch: $(git rev-parse --abbrev-ref HEAD)"
        read -p "Continue anyway? (y/N): " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            exit 1
        fi
    fi
}

get_current_version() {
    if [[ ! -f "$VERSION_FILE" ]]; then
        print_error "VERSION file not found at $VERSION_FILE"
    fi
    cat "$VERSION_FILE" | tr -d '\n'
}

increment_version() {
    local current_version="$1"
    local increment_type="$2"
    
    local major minor patch
    IFS='.' read -r major minor patch <<< "$current_version"
    
    case "$increment_type" in
        "major")
            ((major++))
            minor=0
            patch=0
            ;;
        "minor")
            ((minor++))
            patch=0
            ;;
        "patch")
            ((patch++))
            ;;
        *)
            print_error "Invalid increment type: $increment_type"
            ;;
    esac
    
    echo "$major.$minor.$patch"
}

update_version_file() {
    local new_version="$1"
    local dry_run="$2"
    
    if [[ "$dry_run" == "true" ]]; then
        print_info "Would update VERSION file to: $new_version"
        return
    fi
    
    echo "$new_version" > "$VERSION_FILE"
    print_success "Updated VERSION file to $new_version"
}

update_install_script() {
    local new_version="$1"
    local dry_run="$2"
    
    if [[ "$dry_run" == "true" ]]; then
        print_info "Would update version in install.sh to: $new_version"
        return
    fi
    
    sed -i "s/^VERSION=.*/VERSION=\"$new_version\"/" "$INSTALL_SCRIPT"
    print_success "Updated install.sh version to $new_version"
}

generate_auto_changelog() {
    local current_version="$1"
    
    # Get the latest tag (previous version)
    local previous_tag
    previous_tag=$(git describe --tags --abbrev=0 2>/dev/null || echo "")
    
    local commit_range
    if [[ -n "$previous_tag" ]]; then
        commit_range="${previous_tag}..HEAD"
        # Don't use print_info here to avoid ANSI codes in output
    else
        # If no previous tag, get all commits
        commit_range="HEAD"
    fi
    
    # Get commits with format: type(scope): message
    local commits
    commits=$(git log "$commit_range" --pretty=format:"%s" --reverse 2>/dev/null || echo "")
    
    if [[ -z "$commits" ]]; then
        echo "- Bug fixes and improvements"
        return
    fi
    
    local changes=()
    
    # Process each commit message
    while IFS= read -r commit_msg; do
        [[ -z "$commit_msg" ]] && continue
        
        # Clean up commit message and categorize
        if [[ "$commit_msg" =~ ^(feat|feature)(\(.+\))?:\ (.+) ]]; then
            changes+=("- ✨ ${BASH_REMATCH[3]}")
        elif [[ "$commit_msg" =~ ^(fix|bugfix)(\(.+\))?:\ (.+) ]]; then
            changes+=("- 🐛 ${BASH_REMATCH[3]}")
        elif [[ "$commit_msg" =~ ^(docs|doc)(\(.+\))?:\ (.+) ]]; then
            changes+=("- 📚 ${BASH_REMATCH[3]}")
        elif [[ "$commit_msg" =~ ^(perf|performance)(\(.+\))?:\ (.+) ]]; then
            changes+=("- ⚡ ${BASH_REMATCH[3]}")
        elif [[ "$commit_msg" =~ ^(refactor)(\(.+\))?:\ (.+) ]]; then
            changes+=("- ♻️ ${BASH_REMATCH[3]}")
        elif [[ "$commit_msg" =~ ^(test)(\(.+\))?:\ (.+) ]]; then
            changes+=("- 🧪 ${BASH_REMATCH[3]}")
        elif [[ "$commit_msg" =~ ^(chore)(\(.+\))?:\ (.+) ]]; then
            changes+=("- 🔧 ${BASH_REMATCH[3]}")
        elif [[ "$commit_msg" =~ ^(style)(\(.+\))?:\ (.+) ]]; then
            changes+=("- 💄 ${BASH_REMATCH[3]}")
        elif [[ "$commit_msg" =~ ^(ci)(\(.+\))?:\ (.+) ]]; then
            changes+=("- 👷 ${BASH_REMATCH[3]}")
        elif [[ "$commit_msg" =~ ^(build)(\(.+\))?:\ (.+) ]]; then
            changes+=("- 📦 ${BASH_REMATCH[3]}")
        else
            # Generic commit message - clean it up
            local clean_msg="$commit_msg"
            # Remove any leading/trailing whitespace and special characters
            clean_msg=$(echo "$clean_msg" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')
            changes+=("- $clean_msg")
        fi
    done <<< "$commits"
    
    # If no changes found, use default
    if [[ ${#changes[@]} -eq 0 ]]; then
        changes+=("- Bug fixes and improvements")
    fi
    
    printf '%s\n' "${changes[@]}"
}

prompt_changelog_entry() {
    local version="$1"
    
    echo -e "${YELLOW}${BOLD}Please provide changelog entry for version $version:${NC}"
    echo -e "${YELLOW}Enter your changes (one per line, empty line to finish):${NC}"
    echo -e "${YELLOW}You have 30 seconds to enter changes, or use --auto-changelog flag${NC}"
    echo
    
    local changes=()
    local timeout_duration=30
    
    # Read with timeout
    while true; do
        if read -t "$timeout_duration" -r line; then
            [[ -z "$line" ]] && break
            changes+=("- $line")
            timeout_duration=10  # Shorter timeout for subsequent lines
        else
            print_warning "Timeout reached. Using default changelog entry."
            break
        fi
    done
    
    # If no entries provided, use default
    if [[ ${#changes[@]} -eq 0 ]]; then
        changes+=("- Bug fixes and improvements")
    fi
    
    printf '%s\n' "${changes[@]}"
}

update_changelog() {
    local new_version="$1"
    local dry_run="$2"
    local auto_changelog="$3"
    
    local date_str
    date_str=$(date +%Y-%m-%d)
    
    if [[ "$dry_run" == "true" ]]; then
        print_info "Would add changelog entry for version $new_version"
        return
    fi
    
    # Verify CHANGELOG.md exists and is readable
    if [[ ! -f "$CHANGELOG_FILE" ]] || [[ ! -r "$CHANGELOG_FILE" ]]; then
        print_error "CHANGELOG.md not found or not readable at $CHANGELOG_FILE"
    fi
    
    # Get changelog entries from user or auto-generate
    local changelog_entries
    if [[ "$auto_changelog" == "true" ]]; then
        print_info "Generating automatic changelog from git commits..."
        
        # Get the latest tag for info display
        local previous_tag
        previous_tag=$(git describe --tags --abbrev=0 2>/dev/null || echo "")
        if [[ -n "$previous_tag" ]]; then
            print_info "Collecting commits from ${previous_tag} to HEAD"
        else
            print_info "Collecting commits from initial commit to HEAD"
        fi
        
        changelog_entries=$(generate_auto_changelog "$new_version")
        print_info "Generated changelog entries based on git commits"
    else
        print_info "Collecting changelog entries..."
        changelog_entries=$(prompt_changelog_entry "$new_version")
    fi
    
    if [[ -z "$changelog_entries" ]]; then
        print_warning "No changelog entries provided. Using default entry."
        changelog_entries="- Bug fixes and improvements"
    fi
    
    # Create temporary file with new entry
    local temp_file
    temp_file=$(mktemp)
    
    # Safely handle CHANGELOG.md structure
    if ! head -n 8 "$CHANGELOG_FILE" > "$temp_file" 2>/dev/null; then
        print_error "Failed to read CHANGELOG.md header"
    fi
    
    # Add new version entry
    {
        echo
        echo "## [$new_version] - $date_str"
        echo
        echo "### Added"
        echo
        echo "$changelog_entries"
        echo
    } >> "$temp_file"
    
    # Add rest of file (skip first 8 lines)
    if ! tail -n +9 "$CHANGELOG_FILE" >> "$temp_file" 2>/dev/null; then
        print_warning "Could not append existing changelog entries"
    fi
    
    # Atomically replace the file
    if mv "$temp_file" "$CHANGELOG_FILE"; then
        print_success "Updated CHANGELOG.md with version $new_version"
    else
        print_error "Failed to update CHANGELOG.md"
    fi
}

commit_changes() {
    local new_version="$1"
    local dry_run="$2"
    
    if [[ "$dry_run" == "true" ]]; then
        print_info "Would commit changes with message: 'Release v$new_version'"
        return
    fi
    
    git add "$VERSION_FILE" "$CHANGELOG_FILE" "$INSTALL_SCRIPT"
    git commit -m "Release v$new_version"
    git tag -a "v$new_version" -m "Release v$new_version"
    
    print_success "Created commit and tag for v$new_version"
}

push_changes() {
    local dry_run="$1"
    local no_push="$2"
    
    if [[ "$dry_run" == "true" ]]; then
        print_info "Would push changes and tags to remote repository"
        return
    fi
    
    if [[ "$no_push" == "true" ]]; then
        print_warning "Skipping push (--no-push flag specified)"
        return
    fi
    
    git push origin HEAD
    git push origin --tags
    
    print_success "Pushed changes and tags to remote repository"
}

create_github_release() {
    local new_version="$1"
    local dry_run="$2"
    
    if [[ "$dry_run" == "true" ]]; then
        print_info "Would create GitHub release for v$new_version"
        return
    fi
    
    # Extract changelog for this version
    local release_notes
    release_notes=$(sed -n "/## \[$new_version\]/,/## \[/p" "$CHANGELOG_FILE" | sed '$d' | tail -n +3)
    
    gh release create "v$new_version" \
        --title "Release v$new_version" \
        --notes "$release_notes" \
        --latest
    
    print_success "Created GitHub release for v$new_version"
}

main() {
    local increment_type=""
    local dry_run="false"
    local no_push="false"
    local auto_changelog="false"
    
    # Parse arguments
    while [[ $# -gt 0 ]]; do
        case $1 in
            major|minor|patch)
                if [[ -n "$increment_type" ]]; then
                    print_error "Multiple increment types specified"
                fi
                increment_type="$1"
                shift
                ;;
            --dry-run)
                dry_run="true"
                shift
                ;;
            --no-push)
                no_push="true"
                shift
                ;;
            --auto-changelog)
                auto_changelog="true"
                shift
                ;;
            -h|--help)
                show_usage
                exit 0
                ;;
            *)
                print_error "Unknown argument: $1"
                ;;
        esac
    done
    
    if [[ -z "$increment_type" ]]; then
        print_error "No increment type specified"
        show_usage
        exit 1
    fi
    
    print_header
    
    if [[ "$dry_run" == "true" ]]; then
        print_warning "DRY RUN MODE - No changes will be made"
        echo
    fi
    
    print_step "Checking dependencies..."
    check_dependencies
    
    print_step "Checking git status..."
    check_git_status
    
    print_step "Getting current version..."
    local current_version
    current_version=$(get_current_version)
    print_info "Current version: $current_version"
    
    print_step "Calculating new version..."
    local new_version
    new_version=$(increment_version "$current_version" "$increment_type")
    print_info "New version: $new_version"
    
    print_step "Updating VERSION file..."
    update_version_file "$new_version" "$dry_run"
    
    print_step "Updating install.sh..."
    update_install_script "$new_version" "$dry_run"
    
    print_step "Updating documentation..."
    if [[ "$dry_run" == "false" ]] && [[ -x "$SCRIPT_DIR/update-docs.sh" ]]; then
        "$SCRIPT_DIR/update-docs.sh"
    fi
    
    print_step "Updating CHANGELOG.md..."
    update_changelog "$new_version" "$dry_run" "$auto_changelog"
    
    print_step "Committing changes..."
    commit_changes "$new_version" "$dry_run"
    
    print_step "Pushing to remote..."
    push_changes "$dry_run" "$no_push"
    
    print_step "Creating GitHub release..."
    create_github_release "$new_version" "$dry_run"
    
    echo
    print_success "Release v$new_version completed successfully!"
    
    if [[ "$dry_run" == "false" ]]; then
        echo
        print_info "Install command:"
        echo -e "${WHITE}curl -fsSL https://github.com/maximeallanic/nivuus-shell/releases/latest/download/install.sh | bash${NC}"
    fi
}

# Change to project root
cd "$PROJECT_ROOT"

# Run main function
main "$@"
