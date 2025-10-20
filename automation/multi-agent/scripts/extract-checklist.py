#!/usr/bin/env python3
"""
Extract validation checklist from EXECUTION_ROADMAP.md for a specific task
"""

import re
import sys

def extract_checklist(roadmap_path, task_id):
    """Extract validation checklist for a specific task"""
    with open(roadmap_path, 'r') as f:
        content = f.read()
    
    task_pattern = f"### Task {re.escape(task_id)}:.*?\\*\\*Validation:\\*\\*(.+?)\\n\\n"
    match = re.search(task_pattern, content, re.DOTALL)

    if match:
        validation_section = match.group(1)
        checklist_items = re.findall(r'- \[ \] (.+)', validation_section)
        for item in checklist_items:
            print(item)

if __name__ == "__main__":
    if len(sys.argv) != 3:
        print("Usage: extract-checklist.py <roadmap_file> <task_id>")
        sys.exit(1)
    
    roadmap_path = sys.argv[1]
    task_id = sys.argv[2]
    extract_checklist(roadmap_path, task_id)
