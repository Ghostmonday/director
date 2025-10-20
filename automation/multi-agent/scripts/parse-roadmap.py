#!/usr/bin/env python3
"""
Parse EXECUTION_ROADMAP.md and generate task queue
"""

import re
import json
import sys

def get_dependencies(task_id):
    """Calculate task dependencies based on task ID"""
    # Tasks must complete in order within stages
    stage = int(task_id.split('.')[0])
    task_num = float(task_id.split('.')[1].rstrip('abc'))
    
    # First task in stage only depends on previous stage
    if task_num == 1:
        if stage > 1:
            return [f"{stage-1}.9"]  # Depends on previous stage completion
        return []
    
    # Other tasks depend on previous task in same stage
    prev_task = task_num - 1
    if prev_task == int(prev_task):
        prev_task = int(prev_task)
    return [f"{stage}.{prev_task}"]

def parse_roadmap(roadmap_path):
    """Parse the roadmap file and extract tasks"""
    with open(roadmap_path, 'r') as f:
        content = f.read()

    # Regex to extract tasks - simplified pattern
    task_pattern = r'### Task (\d+\.\d+[a-z]?): (.+?)\n\*\*File:\*\* `?([^`\n]+)`?\n\*\*Priority:\*\* (🔴|🟡|🟢)'
    
    tasks = []
    for match in re.finditer(task_pattern, content):
        task_id = match.group(1)
        task_name = match.group(2)
        file = match.group(3)
        priority = match.group(4)
        
        # Map priority emoji to level
        priority_map = {'🔴': 'CRITICAL', '🟡': 'HIGH', '🟢': 'MEDIUM'}
        
        tasks.append({
            'id': task_id,
            'name': task_name,
            'file': file,
            'priority': priority_map.get(priority, 'MEDIUM'),
            'status': 'pending',
            'dependencies': get_dependencies(task_id),
            'assigned_to': None,
            'attempts': 0
        })
    
    return {'tasks': tasks}

if __name__ == "__main__":
    if len(sys.argv) != 2:
        print("Usage: parse-roadmap.py <roadmap_file>")
        sys.exit(1)
    
    roadmap_path = sys.argv[1]
    result = parse_roadmap(roadmap_path)
    print(json.dumps(result, indent=2))
