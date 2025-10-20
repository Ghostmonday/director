#!/usr/bin/env python3
"""
Extract requirements from EXECUTION_ROADMAP.md for a specific task
"""

import re
import sys

def extract_requirements(roadmap_path, task_id):
    """Extract requirements for a specific task"""
    with open(roadmap_path, 'r') as f:
        content = f.read()
    
    task_section = re.search(f"### Task {re.escape(task_id)}:(.+?)(?=###|---|\Z)", content, re.DOTALL)

    if task_section:
        text = task_section.group(1)
        
        # Look for requirement indicators
        requirements = []
        
        # From "Implementation:" section
        impl_match = re.search(r'\*\*Implementation:\*\*(.+?)(?=\*\*|$)', text, re.DOTALL)
        if impl_match:
            impl_text = impl_match.group(1)
            # Extract bullet points
            requirements.extend(re.findall(r'[•-] (.+)', impl_text))
        
        # From code comments
        code_match = re.search(r'```swift(.+?)```', text, re.DOTALL)
        if code_match:
            code = code_match.group(1)
            requirements.extend(re.findall(r'// (.+)', code))
        
        for req in requirements:
            print(req.strip())

if __name__ == "__main__":
    if len(sys.argv) != 3:
        print("Usage: extract-requirements.py <roadmap_file> <task_id>")
        sys.exit(1)
    
    roadmap_path = sys.argv[1]
    task_id = sys.argv[2]
    extract_requirements(roadmap_path, task_id)
