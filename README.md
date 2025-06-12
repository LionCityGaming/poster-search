# Poster Image Search Script

A bash script for efficiently searching poster image files with user-based prioritization and flexible filtering options. This script is designed to work in conjunction with [DAPS (Drazzilb's Arr PMM Scripts)](https://github.com/Drazzilb08/daps) and [DAPS-UI](https://github.com/zarskie/daps-ui/wiki).

## Overview

This script enhances the poster browsing capabilities for DAPS users by providing:
- Quick searching through user-synchronized poster directories
- Priority-based sorting of trusted users' contributions
- Format-specific filtering
- Collection overview with file count per user
- Adaptive color-coded output with terminal compatibility
- Automatic terminal capability detection

For information about setting up DAPS and DAPS-UI, please refer to:
- [DAPS Documentation](https://github.com/Drazzilb08/daps)
- [DAPS-UI Wiki](https://github.com/zarskie/daps-ui/wiki)

## Features

- Search for images by filename across multiple user directories
- **View file count statistics per user with collection overview**
- Filter results by file format (JPG, JPEG, PNG)
- Sort results by various criteria including custom priority order
- Smart color-coded output with terminal compatibility detection
- Advanced and basic color support with automatic fallback
- User-specific filtering
- Support for JPG, JPEG, and PNG files
- Multiple search paths support
- Enhanced search performance
- **Total collection statistics with format-specific breakdowns**

## Version History

**Current Version:** 0.3.0

Changes in 0.3.0:
- **Added file count function (-c flag) to display collection statistics**
- **Shows number of files per user directory with total count**
- **Format-specific counting (works with -f flag for targeted statistics)**
- **Color-coded user display matching search results**
- **Priority-ordered statistics display**

Changes in 0.2.1:
- Updated color scheme for better terminal compatibility
- Added advanced and basic color support with fallbacks
- Automatic terminal capability detection
- Smart color mode selection based on terminal support
- Enhanced search term highlighting for supported terminals

Changes in 0.2.0:
- Complete rebuild with simplified codebase
- Multiple search paths support
- Optimized search performance
- Simplified user configuration
- Same feature set with more maintainable code
- Improved error handling
- Better handling of non-existent paths

Previous Changes (0.1.1):
- Added priority-based sorting (now default)
- Added PNG file support to search results
- Added file format filter option (-f)
- Made search term optional when using format filter
- Reformatted user list for better readability
- Changed default sort from year-desc to priority order
- Modified -l list to show users in priority order (previously alphabetical)

## Prerequisites

- A working [DAPS](https://github.com/Drazzilb08/daps) installation
- Access to the DAPS posters directory
- Bash shell (version 4.0 or higher)
- Terminal with basic color support (enhanced features available for terminals with advanced color support)

## Installation

1. Clone this repository:
```bash
git clone https://github.com/LionCityGaming/poster-search.git
cd poster-search
```

2. Make the script executable:
```bash
chmod +x poster-search.sh
```

## Configuration

The script now uses an enhanced configuration system with support for both advanced and basic terminal colors:
```bash
# Search paths - Add or modify paths as needed
declare -a SEARCH_PATHS=(
    "/volume2/docker/dockge/stacks/daps/posters"    # Main DAPS posters directory
    # Add additional paths here
)

# User priority and color mapping with fallback support
declare -a USERS=(
    "LionCityGaming:1;31"         # Light Red
    "IamSpartacus:1;32"           # Light Green
    # Format: "username:color_code"
)
```

The color system automatically detects your terminal's capabilities and provides:
- Advanced colors for modern terminals
- Basic colors for standard terminals
- Fallback to no colors for limited terminals

## Usage

### Basic Search
```bash
./poster-search.sh [search_term]
```

### Collection Statistics
```bash
# Show file count for all users
./poster-search.sh -c

# Show file count for specific format
./poster-search.sh -c -f jpg
./poster-search.sh -c -f png
```

Example output:
```
File count per user:
====================
LionCityGaming     1,234 files
IamSpartacus         892 files
Drazzilb             567 files
BZ                   445 files
...
====================
Total files: 8,456
```

### List All Users
```bash
./poster-search.sh -l
```

### Filter by Format
```bash
# Show all PNG files
./poster-search.sh -f png

# Show all JPG files
./poster-search.sh -f jpg

# Search PNGs with term
./poster-search.sh -f png searchterm
```

![WindowsTerminal_4cqr5BcaD2](https://github.com/user-attachments/assets/2303017a-bc4a-4db1-b274-319711e9f182)

### Filter by Username
```bash
./poster-search.sh -u username searchterm
```

### Sort Options
```bash
./poster-search.sh -s priority searchterm    # Sort by predefined priority (default)
./poster-search.sh -s username searchterm    # Sort alphabetically by username
./poster-search.sh -s filename searchterm    # Sort alphabetically by filename
./poster-search.sh -s year-asc searchterm   # Sort by year, oldest first
./poster-search.sh -s year-desc searchterm  # Sort by year, newest first
```

### Combining Options
```bash
./poster-search.sh -u username -f png -s priority searchterm
```

### Debug and Verbose Output
```bash
# Run with verbose output
./poster-search.sh -v searchterm

# Run with debug output
./poster-search.sh -d searchterm

# Can be combined with other options
./poster-search.sh -v -u username -f png searchterm
./poster-search.sh -d -u username -f png searchterm
```

## Command Line Options

| Option | Description |
|--------|-------------|
| -h | Show help text |
| -l | List all synced drives |
| **-c** | **Show file count per user (collection statistics)** |
| -u username | Filter results by username (case insensitive, partial match) |
| -f format | Filter by file format (jpg, jpeg, png, or all) |
| -s sort_option | Sort results (priority, username, filename, year-asc, year-desc) |
| -v | Enable verbose output (shows additional processing information) |
| -d | Enable debug mode (shows additional debugging information) |

## Terminal Compatibility

The script now includes smart terminal detection and will automatically:
1. Use advanced colors (including light/dark variations) on fully-capable terminals
2. Fall back to basic ANSI colors on terminals with standard color support
3. Disable colors completely on terminals without color support

This ensures optimal visibility and compatibility across different terminal emulators and SSH sessions.

## Collection Management

The new file count feature provides valuable insights for collection management:

- **Quick overview**: See which users contribute the most content
- **Format analysis**: Identify format distribution across your collection
- **Storage planning**: Understand collection size for backup and storage decisions
- **User activity**: Monitor active contributors to your poster collection

Use cases:
- `./poster-search.sh -c` - Get overall collection statistics
- `./poster-search.sh -c -f jpg` - See JPG distribution across users
- `./poster-search.sh -c -f png` - Analyze PNG collection by user

## Directory Structure

The script is designed to work with DAPS directory structure and expects images to be organized in the following way:
```
/volume2/docker/dockge/stacks/daps/posters/  # Default DAPS posters directory
├── user1/                                   # DAPS sync username
│   ├── image1.jpg
│   └── image2.png
├── user2/
│   ├── image3.jpg
│   └── image4.png
└── user3/
    └── image5.jpg
```

The default search path is set to the standard DAPS posters directory but can be modified in the script configuration.

## Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Related Links

- [DAPS](https://github.com/Drazzilb08/daps) - Docker Automated Plex Synchronization
- [DAPS-UI](https://github.com/zarskie/daps-ui) - Web interface for DAPS
- [DAPS-UI Wiki](https://github.com/zarskie/daps-ui/wiki) - Documentation for DAPS-UI
- [DAPS Install Guide](https://github.com/Drazzilb08/daps/blob/main/docs/install.md) - Official DAPS installation guide
- [DAPS Discord](https://discord.gg/FT6wcxqyZ5) - Official DAPS Discord community

## Acknowledgments

- Users who contributed to feature requests and testing
- Inspiration from similar image organization tools
- DAPS community for feedback and testing
