# Getting Started with DirectorStudio

This guide will help you get started with DirectorStudio, from installation to your first video generation.

## Prerequisites

- macOS 12.0 or later
- Swift 5.9 or later
- Xcode 14.0 or later (optional, for development)

## Installation

### Clone the Repository

```bash
git clone https://github.com/yourusername/director-studio.git
cd director-studio
```

### Build the Project

```bash
# Option 1: Using Swift directly
swift build

# Option 2: Using the build script
./scripts/build/build.sh
```

## Using the CLI

DirectorStudio provides a command-line interface for processing stories and generating videos.

### Basic Usage

```bash
# Option 1: Using Swift directly
swift run DirectorStudioCLI --input "Your story text here"

# Option 2: Using the CLI runner script
./scripts/utils/run-cli.sh --input "Your story text here"
```

### CLI Options

- `--input <text>`: Input text to process
- `--input-file <path>`: Input file path
- `--output <path>`: Output file path
- `--verbose`: Enable verbose output
- `--test`: Run tests
- `--health`: Show health status

### Example: Generate a Video

```bash
swift run DirectorStudioCLI --input "A brave knight embarks on a quest to save the kingdom from a fearsome dragon." --output video.mp4
```

## Core Modules

DirectorStudio processes your story through several modules:

1. **Story Analysis**: Analyzes your story to extract characters, locations, and themes
2. **Story Segmentation**: Breaks down your story into filmable segments
3. **Taxonomy Enrichment**: Adds cinematic metadata to segments
4. **Video Generation**: Creates video clips for each segment
5. **Video Assembly**: Combines clips with transitions
6. **Video Effects**: Applies post-processing effects

## Project Structure

- **Sources/DirectorStudio**: Core library
  - **Core**: Core protocols and interfaces
  - **Modules**: Individual processing modules
- **Sources/DirectorStudioCLI**: Command-line interface
- **Tests**: Test suite
- **docs**: Documentation
- **scripts**: Utility scripts

## Development

### Running Tests

```bash
# Option 1: Using Swift directly
swift test

# Option 2: Using the build script
./scripts/build/build.sh test
```

### Clean Build

```bash
# Option 1: Using Swift directly
swift package clean

# Option 2: Using the build script
./scripts/build/build.sh clean
```

## Troubleshooting

### Common Issues

1. **Build Errors**: Make sure you have the latest version of Swift installed.
2. **Runtime Errors**: Check the logs in the `logs` directory for detailed error messages.
3. **Video Generation Issues**: Ensure you have sufficient credits for video generation.

### Getting Help

If you encounter any issues, please:

1. Check the documentation in the `docs` directory
2. Look for error messages in the logs
3. File an issue on the GitHub repository
