#!/usr/bin/env python3
"""
Extract line references from EXECUTION_ROADMAP.md for a specific task
"""

import re
import sys

def extract_line_refs(roadmap_path, task_id):
    """Extract line references for a specific task"""
    with open(roadmap_path, 'r') as f:
        content = f.read()

    # Find task section
    task_pattern = rf"### Task {re.escape(task_id)}:(.+?)(?=###|---|\Z)"
    match = re.search(task_pattern, content, re.DOTALL)

    if not match:
        print("ERROR: Task {} not found in roadmap".format(task_id), file=sys.stderr)
        sys.exit(1)

    task_section = match.group(1)

    # Find line references
    line_refs = re.findall(r'lines? (\d+)-(\d+)', task_section)

    if not line_refs:
        print("ERROR: No line references found for task {}".format(task_id), file=sys.stderr)
        sys.exit(1)

    # Print first reference (usually the most important)
    print("{} {}".format(line_refs[0][0], line_refs[0][1]))

    # Print all references to stderr for info
    if len(line_refs) > 1:
        print("Note: Found {} line references. Extracting first.".format(len(line_refs)), file=sys.stderr)
        for i, (start, end) in enumerate(line_refs, 1):
            print("  {}. Lines {}-{}".format(i, start, end), file=sys.stderr)

if __name__ == "__main__":
    if len(sys.argv) != 3:
        print("Usage: extract-line-refs.py <roadmap_file> <task_id>")
        sys.exit(1)
    
    roadmap_path = sys.argv[1]
    task_id = sys.argv[2]
    extract_line_refs(roadmap_path, task_id)
