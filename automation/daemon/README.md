# 🤖 Stage Validation Daemon

## Overview
Automated daemon that monitors PR validation status and generates stage completion markers when all tasks in a stage are completed.

## Files
- `stage-validation-daemon.sh` - Main daemon script
- `com.ghostmonday.director.stage-daemon.plist` - Launchd configuration
- `install-daemon.sh` - Installation script

## Features
- ✅ **Hourly Monitoring**: Runs every hour to check stage progress
- ✅ **PR Tracker Integration**: Reads `automation/logs/pr-tracker.md` for validation status
- ✅ **Stage Completion Detection**: Identifies when all modules in a stage are validated
- ✅ **Auto-Generation**: Creates `STAGE_<n>_COMPLETE.md` files automatically
- ✅ **Progress Tracking**: Logs stage status to `automation/logs/stage-progress.md`
- ✅ **Safe Integration**: Works with existing `create-module-pr.sh` automation
- ✅ **Manual Edit Protection**: Never overwrites existing completion files
- ✅ **Concise Logging**: Clean console output (e.g., "Stage 1 → COMPLETE")

## Stage Definitions
Each stage requires validation of these modules:

### Stage 1: Foundation
- `PromptSegment`, `PipelineContext`, `MockAIService`, `RewordingModule`, `RewordingUI`

### Stage 2: Pipeline  
- `PipelineOrchestrator`, `PipelineConfig`, `PipelineManager`, `PipelineProgressView`

### Stage 3: AI Service
- `SecretsConfiguration`, `AIService`, `ImageGenerationService`, `AIServiceSettingsView`

### Stage 4: Persistence
- `ProjectStore`, `ProjectManager`, `ProjectListView`, `ProjectDetailView`

### Stage 5: Credits
- `CreditsService`, `StoreKitService`, `CreditsStoreView`, `PurchaseFlowView`

## Usage

### Manual Testing
```bash
./automation/daemon/stage-validation-daemon.sh --test
```

### Single Run
```bash
./automation/daemon/stage-validation-daemon.sh --once
```

### Continuous Mode (Manual)
```bash
./automation/daemon/stage-validation-daemon.sh --continuous
```

### Installation & Auto-Start
```bash
./automation/daemon/install-daemon.sh
```

## Integration
- **Input**: Reads from `automation/logs/pr-tracker.md` (GitHub Actions updates)
- **Output**: Generates `STAGE_<n>_COMPLETE.md` and updates `automation/logs/stage-progress.md`
- **Compatibility**: Designed to work with existing PR automation

## Logs
- `automation/logs/daemon.log` - Standard output
- `automation/logs/daemon-error.log` - Error output
- `automation/logs/stage-progress.md` - Stage completion status

## Safety Features
- ✅ Never overwrites manual edits to completion files
- ✅ Gracefully handles unfinished stages
- ✅ Safe file operations with error handling
- ✅ Clean process management via launchd

## Requirements
- macOS with launchd
- Git repository with PR automation
- Existing `create-module-pr.sh` workflow
