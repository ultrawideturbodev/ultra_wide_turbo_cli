#!/bin/bash

# Get script location and set up global paths
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(dirname "$SCRIPT_DIR")"
TARGET_DIR="$(dirname "$SCRIPT_DIR")"
WORKSPACES_DIR="$TARGET_DIR/workspaces"

# Function to convert title to kebab case
to_kebab_case() {
    echo "$1" | tr '[:upper:]' '[:lower:]' | sed -e 's/[^a-zA-Z0-9]/-/g' -e 's/--*/-/g' -e 's/^-//' -e 's/-$//'
}

# Function to get next available number for a base name
get_next_number() {
    local base_name="$1"
    local counter=1
    
    while [ -d "$WORKSPACES_DIR/$base_name-$(printf "%02d" $counter)" ]; do
        counter=$((counter + 1))
    done
    
    echo $(printf "%02d" $counter)
}

# Function to get default workspace name
get_default_name() {
    local base_name="$1"
    local month=$(date "+%m")
    local day=$(date "+%d")
    local weekday=$(date "+%a" | tr '[:upper:]' '[:lower:]')
    local date_suffix="${month}${day}-${weekday}"
    local number=$(get_next_number "$date_suffix")
    
    echo "$date_suffix-$number-$base_name"
}

# Show welcome message
echo "Welcome to Ultra Wide Turbo workspace creation!"
echo "----------------------------------------"

# Available components
components=(
    "Agent Work Documents"
    "Protocols"
    "Workflows"
    "Templates"
    "Wiki"
    "Prompts"
    "APIs"
    "Insights"
    "Scripts"
    "Feature Breakdowns"
    "Tutorials"
    "Case Studies"
)

# Show components and get selection
echo "Available components:"
for ((i=0; i<${#components[@]}; i++)); do
    echo "$((i+1)). ${components[$i]}"
done

echo -e "\nEnter numbers of components to include (space-separated) or press ENTER to include all:"
read -r include_nums

# Process selection
selected=()
if [ -z "$include_nums" ]; then
    selected=("${components[@]}")
    echo -e "\nIncluding all components:"
    for component in "${components[@]}"; do
        echo "✓ $component"
    done
else
    for i in {1..12}; do
        if [[ "$include_nums" == *"$i"* ]]; then
            selected+=("${components[$((i-1))]}")
            echo "✓ ${components[$((i-1))]}"
        fi
    done
    if [ ${#selected[@]} -eq 0 ]; then
        echo "No valid components selected, using all components:"
        selected=("${components[@]}")
        for component in "${components[@]}"; do
            echo "✓ $component"
        done
    else
        echo -e "\nSelected components:"
        for component in "${selected[@]}"; do
            echo "✓ $component"
        done
    fi
fi

# Get workspace base name
month=$(date "+%m")
day=$(date "+%d")
weekday=$(date "+%a" | tr '[:upper:]' '[:lower:]')
date_part="${month}${day}-${weekday}"
next_number=$(get_next_number "$date_part")
base_suggestion="${date_part}-${next_number}-turbo-workspace"
default_name="$base_suggestion"
echo -e "\nEnter workspace base name (press ENTER for: $default_name):"
read -r USER_INPUT

# Use default if no input
if [ -z "$USER_INPUT" ]; then
    BASE_NAME="turbo-workspace"
    FOLDER_PATH=""
    echo "Using default base name: $BASE_NAME"
else
    # Split input into folder path and base name if "/" is present
    if [[ "$USER_INPUT" == *"/"* ]]; then
        FOLDER_PATH="${USER_INPUT%/*}"
        BASE_NAME=$(to_kebab_case "${USER_INPUT##*/}")
        echo "Using folder path: $FOLDER_PATH"
        echo "Using kebab case name: $BASE_NAME"
    else
        FOLDER_PATH=""
        BASE_NAME=$(to_kebab_case "$USER_INPUT")
        echo "Using kebab case name: $BASE_NAME"
    fi
fi

# Generate workspace name
WORKSPACE_NAME=$(get_default_name "$BASE_NAME")
echo "Using workspace name: $WORKSPACE_NAME"

# Ensure workspaces directory exists
mkdir -p "$WORKSPACES_DIR"

# Create main workspace directory with folder path if specified
if [ -n "$FOLDER_PATH" ]; then
    WORKSPACE_DIR="$WORKSPACES_DIR/$FOLDER_PATH/$WORKSPACE_NAME"
else
    WORKSPACE_DIR="$WORKSPACES_DIR/$WORKSPACE_NAME"
fi
mkdir -p "$WORKSPACE_DIR"
echo -e "\nCreated workspace directory: $WORKSPACE_DIR"

# Create selected components
echo -e "\nCreating workspace with selected components..."
for component in "${selected[@]}"; do
    case "$component" in
        "Agent Work Documents")
            cp "$REPO_ROOT"/your-*.md "$WORKSPACE_DIR/" 2>/dev/null || echo "⚠️  No agent work documents found to copy"
            ;;
        "Protocols")
            cp -r "$REPO_ROOT/protocols" "$WORKSPACE_DIR/" 2>/dev/null || echo "⚠️  No protocols found to copy"
            ;;
        "Workflows")
            cp -r "$REPO_ROOT/workflows" "$WORKSPACE_DIR/" 2>/dev/null || echo "⚠️  No workflows found to copy"
            ;;
        "Templates")
            cp -r "$REPO_ROOT/templates" "$WORKSPACE_DIR/" 2>/dev/null || echo "⚠️  No templates found to copy"
            ;;
        "Wiki")
            cp -r "$REPO_ROOT/wiki" "$WORKSPACE_DIR/" 2>/dev/null || echo "⚠️  No knowledge found to copy"
            ;;
        "Prompts")
            cp -r "$REPO_ROOT/prompts" "$WORKSPACE_DIR/" 2>/dev/null || echo "⚠️  No prompts found to copy"
            ;;
        "APIs")
            cp -r "$REPO_ROOT/apis" "$WORKSPACE_DIR/" 2>/dev/null || echo "⚠️  No APIs found to copy"
            ;;
        "Insights")
            cp -r "$REPO_ROOT/insights" "$WORKSPACE_DIR/" 2>/dev/null || echo "⚠️  No insights found to copy"
            ;;
        "Scripts")
            cp -r "$REPO_ROOT/scripts" "$WORKSPACE_DIR/" 2>/dev/null || echo "⚠️  No scripts found to copy"
            ;;
        "Feature Breakdowns")
            cp -r "$REPO_ROOT/feature-breakdowns" "$WORKSPACE_DIR/" 2>/dev/null || echo "⚠️  No feature breakdowns found to copy"
            ;;
        "Tutorials")
            cp -r "$REPO_ROOT/tutorials" "$WORKSPACE_DIR/" 2>/dev/null || echo "⚠️  No tutorials found to copy"
            ;;
        "Case Studies")
            cp -r "$REPO_ROOT/case-studies" "$WORKSPACE_DIR/" 2>/dev/null || echo "⚠️  No case studies found to copy"
            ;;
    esac
done

echo -e "\nFiles in new workspace:"
ls -la "$WORKSPACE_DIR"
echo -e "\n🎉 Ultra Wide Turbo workspace '$WORKSPACE_NAME' created successfully!"
echo "Location: $WORKSPACE_DIR"
