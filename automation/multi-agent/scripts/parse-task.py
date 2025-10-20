#!/usr/bin/env python3
"""
Parse task details from EXECUTION_ROADMAP.md
"""

import re
import sys

def get_task_details(roadmap_path, task_id):
    """Extract task details from roadmap"""
    try:
        with open(roadmap_path, 'r') as f:
            content = f.read()
    except FileNotFoundError:
        print("TASK_NAME=Unknown Task")
        print("FILE_NAME=unknown")
        print("FIDELITY=false")
        return

    # Simple pattern - just get the file name
    pattern = f"Task {task_id}.*?File.*?([A-Za-z0-9_./-]+\\.swift)"
    match = re.search(pattern, content, re.IGNORECASE | re.DOTALL)
    
    if match:
        task_name = f"Task {task_id}"
        file_name = match.group(1).strip()
        
        # Extract legacy code references
        legacy_refs = re.findall(r'lines? (\d+)-(\d+)', content)
        
        # Extract fidelity reminders
        fidelity = "FIDELITY REMINDER" in content or "Maintain 100% functionality" in content
        
        print(f'TASK_NAME="{task_name}"')
        print(f'FILE_NAME="{file_name}"')
        if legacy_refs:
            print(f"LEGACY_START={legacy_refs[0][0]}")
            print(f"LEGACY_END={legacy_refs[0][1]}")
        print(f"FIDELITY={'true' if fidelity else 'false'}")
    else:
        print("TASK_NAME=Unknown Task")
        print("FILE_NAME=unknown")
        print("FIDELITY=false")

if __name__ == "__main__":
    if len(sys.argv) != 3:
        print("Usage: parse-task.py <roadmap_file> <task_id>")
        sys.exit(1)
    
    roadmap_path = sys.argv[1]
    task_id = sys.argv[2]
    get_task_details(roadmap_path, task_id)
