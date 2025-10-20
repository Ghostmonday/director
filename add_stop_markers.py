#!/usr/bin/env python3
import re

# Read the file
with open('CHEETAH_EXECUTION_CHECKLIST.md', 'r') as f:
    content = f.read()

# Define stop marker template
stop_marker = """
**🛑 STOP FOR USER TESTING:**
Once this task is complete, STOP development and notify user to:
- [ ] Build project in Xcode
- [ ] Run all compilation checks
- [ ] Test functionality programmatically
- [ ] Verify feature works as specified
**⏸️ WAIT for user approval before proceeding to next task**
"""

# Tasks that should have stop markers (after functional completion)
stop_after_tasks = [
    "Task 1.1",  # PromptSegment
    "Task 1.2",  # PipelineContext
    "Task 1.3",  # MockAIService
    "Task 1.4",  # Update rewording.swift
    "Task 1.5",  # Update segmentation.swift
    "Task 1.6",  # Update storyanalysis.swift
    "Task 1.7",  # Update taxonomy.swift
    "Task 1.8",  # Update continuity.swift
    "Task 1.9",  # Validation Test
    "Task 2.1",  # PipelineConfiguration
    "Task 2.2",  # PipelineOrchestrator
    "Task 2.7",  # Integration Test
    "Task 3.1",  # Secrets Configuration
    "Task 3.2",  # AIService
    "Task 3.2a", # ImageGenerationService
    "Task 3.3",  # Rate Limiting
    "Task 4.1",  # CoreData Model
    "Task 4.2",  # PersistenceController
    "Task 5.1",  # CreditsService
    "Task 5.2",  # StoreKitService
    "Task 6.1",  # Update Segmentation
    "Task 6.2",  # VideoGenerationModule
    "Task 6.3",  # VideoAssemblyModule
    "Task 6.4",  # Update ContinuityModule
]

# Find validation sections and add stop markers
lines = content.split('\n')
new_lines = []
i = 0

while i < len(lines):
    new_lines.append(lines[i])
    
    # Check if this is a validation section
    if lines[i].startswith('**Validation:**'):
        # Look ahead to find the end of validation checklist
        j = i + 1
        while j < len(lines) and (lines[j].startswith('- [ ]') or lines[j].strip() == ''):
            new_lines.append(lines[j])
            j += 1
        
        # Check if next line is a separator or new task
        if j < len(lines) and (lines[j].strip() == '---' or lines[j].startswith('###')):
            # Check if we're in a task that needs a stop marker
            # Look backwards to find the task number
            for k in range(i, max(0, i-50), -1):
                if lines[k].startswith('### Task'):
                    task_id = lines[k].split(':')[0].replace('### ', '').strip()
                    # Remove any emoji or extra text
                    task_id = re.sub(r'[⚠️🔴🟡🟢].*', '', task_id).strip()
                    
                    if any(task_id.startswith(t) for t in stop_after_tasks):
                        # Add stop marker
                        new_lines.append('')
                        for marker_line in stop_marker.strip().split('\n'):
                            new_lines.append(marker_line)
                    break
        
        i = j - 1
    
    i += 1

# Write back
with open('CHEETAH_EXECUTION_CHECKLIST.md', 'w') as f:
    f.write('\n'.join(new_lines))

print("✅ Added STOP markers after functional completions")

