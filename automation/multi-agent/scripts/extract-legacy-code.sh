#!/bin/bash
# 📚 LEGACY CODE EXTRACTOR
# Extracts specific line ranges from LEGACY_CODEBASE_REFERENCE.txt

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../../.." && pwd)"
LEGACY_CODE="$REPO_ROOT/LEGACY_CODEBASE_REFERENCE.txt"

# ============================================================================
# USAGE
# ============================================================================

usage() {
    cat << EOF
Usage: $0 [OPTIONS]

Extract code from LEGACY_CODEBASE_REFERENCE.txt

OPTIONS:
    --lines START END       Extract lines START to END
    --task TASK_ID          Extract lines for specific task (reads from roadmap)
    --output FILE           Write to FILE instead of stdout
    --preview               Show first 20 lines only
    -h, --help              Show this help message

EXAMPLES:
    # Extract lines 1924-1979
    $0 --lines 1924 1979

    # Extract lines for Task 1.1
    $0 --task 1.1

    # Extract and save to file
    $0 --lines 1924 1979 --output PromptSegment.swift

    # Preview extraction
    $0 --task 1.1 --preview
EOF
    exit 1
}

# ============================================================================
# LINE EXTRACTION
# ============================================================================

extract_lines() {
    local start="$1"
    local end="$2"
    local output="${3:-}"
    
    if [[ ! -f "$LEGACY_CODE" ]]; then
        echo "ERROR: LEGACY_CODEBASE_REFERENCE.txt not found" >&2
        exit 1
    fi
    
    echo "Extracting lines $start-$end from legacy code..." >&2
    
    local content=$(sed -n "${start},${end}p" "$LEGACY_CODE")
    
    if [[ -n "$output" ]]; then
        echo "$content" > "$output"
        echo "✅ Extracted to: $output" >&2
    else
        echo "$content"
    fi
}

# ============================================================================
# TASK-BASED EXTRACTION
# ============================================================================

get_task_line_refs() {
    local task_id="$1"
    local roadmap="$REPO_ROOT/EXECUTION_ROADMAP.md"
    
    if [[ ! -f "$roadmap" ]]; then
        echo "ERROR: EXECUTION_ROADMAP.md not found" >&2
        exit 1
    fi
    
    # Extract line references from roadmap
    python3 "$(dirname "$0")/extract-line-refs.py" "$roadmap" "$task_id"
}

extract_for_task() {
    local task_id="$1"
    local output="${2:-}"
    
    echo "Finding line references for task $task_id..." >&2
    
    # Get line references
    local lines
    lines=$(get_task_line_refs "$task_id")
    
    if [[ $? -ne 0 ]]; then
        exit 1
    fi
    
    # Extract the lines
    extract_lines $lines "$output"
}

# ============================================================================
# PREVIEW
# ============================================================================

preview_extraction() {
    local start="$1"
    local end="$2"
    
    local total_lines=$((end - start + 1))
    
    echo "==================================================" >&2
    echo "Preview: Lines $start-$end ($total_lines lines)" >&2
    echo "==================================================" >&2
    
    sed -n "${start},${end}p" "$LEGACY_CODE" | head -n 20
    
    if [[ $total_lines -gt 20 ]]; then
        echo "..." >&2
        echo "($((total_lines - 20)) more lines)" >&2
    fi
    
    echo "==================================================" >&2
}

# ============================================================================
# MAIN
# ============================================================================

main() {
    local mode=""
    local start=""
    local end=""
    local task_id=""
    local output=""
    local preview=false
    
    while [[ $# -gt 0 ]]; do
        case "$1" in
            --lines)
                mode="lines"
                start="$2"
                end="$3"
                shift 3
                ;;
            --task)
                mode="task"
                task_id="$2"
                shift 2
                ;;
            --output)
                output="$2"
                shift 2
                ;;
            --preview)
                preview=true
                shift
                ;;
            -h|--help)
                usage
                ;;
            *)
                echo "ERROR: Unknown option: $1" >&2
                usage
                ;;
        esac
    done
    
    if [[ -z "$mode" ]]; then
        usage
    fi
    
    case "$mode" in
        lines)
            if [[ "$preview" == "true" ]]; then
                preview_extraction "$start" "$end"
            else
                extract_lines "$start" "$end" "$output"
            fi
            ;;
        task)
            if [[ "$preview" == "true" ]]; then
                # Get lines for task, then preview
                lines=$(get_task_line_refs "$task_id")
                if [[ $? -ne 0 ]] || [[ -z "$lines" ]]; then
                    echo "ERROR: Could not extract line references for task $task_id" >&2
                    exit 1
                fi
                preview_extraction $lines
            else
                extract_for_task "$task_id" "$output"
            fi
            ;;
    esac
}

main "$@"
