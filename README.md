# DirectorStudio

A powerful AI-powered video generation and story processing platform.

## Overview

DirectorStudio is a Swift-based application that transforms text stories into cinematic videos. It provides a comprehensive pipeline for story analysis, segmentation, video generation, and post-processing.

## Features

- **Story Analysis**: Deep analysis of text to extract characters, locations, and themes
- **Story Segmentation**: Breaking down stories into filmable segments
- **Cinematic Taxonomy**: Enriching segments with cinematic metadata
- **Video Generation**: AI-powered video creation from story segments
- **Video Assembly**: Combining video clips with transitions and effects
- **Video Effects**: Post-processing and visual enhancements

## Getting Started

### Prerequisites

- Swift 5.9 or later
- macOS 12.0 or later

### Installation

Clone the repository and build the project:

```bash
git clone https://github.com/yourusername/director-studio.git
cd director-studio
swift build
```

### Running the CLI

```bash
swift run DirectorStudioCLI --input "Your story text here"
```

## Project Structure

- **Sources/DirectorStudio**: Core library
  - **Core**: Core protocols and interfaces
  - **Modules**: Individual processing modules
- **Sources/DirectorStudioCLI**: Command-line interface
- **Tests**: Test suite
- **docs**: Documentation
- **scripts**: Utility scripts

## Documentation

For more detailed documentation, see the `docs` directory:

- [Restoration Complete](docs/RESTORATION_COMPLETE.md): Final restoration report
- [Execution Roadmap](docs/EXECUTION_ROADMAP.md): Detailed task breakdown
- [Progress Update](docs/PROGRESS_UPDATE.md): Latest progress status

## License

This project is licensed under the MIT License - see the LICENSE file for details.
