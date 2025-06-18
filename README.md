# Poster Image Search Script

A bash script for efficiently searching poster image files with user-based prioritization and flexible filtering options. This script is designed to work in conjunction with [DAPS (Drazzilb's Arr PMM Scripts)](https://github.com/Drazzilb08/daps) and [DAPS-UI](https://github.com/zarskie/daps-ui/wiki).

## Overview

This script enhances the poster browsing capabilities for DAPS users by providing:
- Quick searching through user-synchronized poster directories
- Priority-based sorting of trusted users' contributions
- Format-specific filtering
- **Collection overview with file count and disk usage per user**
- **Advanced sorting options for collection statistics including disk usage**
- **Interactive menu-driven interface for easy navigation**
- **External configuration file support for portability**
- Adaptive color-coded output with terminal compatibility
- Automatic terminal capability detection

For information about setting up DAPS and DAPS-UI, please refer to:
- [DAPS Documentation](https://github.com/Drazzilb08/daps)
- [DAPS-UI Wiki](https://github.com/zarskie/daps-ui/wiki)

## Features

- Search for images by filename across multiple user directories
- **View file count and disk usage statistics per user with flexible sorting options**
- Filter results by file format (JPG, JPEG, PNG)
- Sort results by various criteria including custom priority order
- **Sort collection statistics by file count, disk usage, username, or priority**
- **Human-readable size formatting (B, KB, MB, GB, TB)**
- **Interactive mode with menu-driven interface for enhanced user experience**
- **External configuration support via poster-search.env file**
- **Configuration persistence across script updates**
- Smart color-coded output with terminal compatibility detection
- Advanced and basic color support with automatic fallback
- User-specific filtering
- Support for JPG, JPEG, and PNG files
- Multiple search paths support
- Enhanced search performance
- **Total collection statistics with format-specific breakdowns and total disk usage**

## Version History

**Current Version:** 0.6.0

Changes in 0.6.0:
- **Added external poster-search.env configuration file support**
- **Automatic poster-search.env.example file creation for easy setup**
- **Configuration persistence across script updates**
- **User-defined poster paths and user configurations**
- **Safe configuration parsing with fallback to built-in defaults**
- **Enhanced portability and maintainability**

Changes in 0.5.0:
- **Added interactive mode (-i flag) with menu-driven interface**
- **Main menu with search, statistics, user listing, and advanced options**
- **Advanced options submenu for configuring filters and settings**
- **Collection statistics submenu with format and sorting options**
- **Persistent settings within interactive session**
- **Clear screen management and user-friendly navigation**
- **Enhanced user experience with guided interface**

Changes in 0.4.0:
- **Added disk usage information to file count display (-c flag)**
- **New sort options: size-asc, size-desc for sorting by disk usage**
- **Enhanced display format to show both file count and space used**
- **Added human-readable size formatting (B, KB, MB, GB, TB)**
- **Optimized file size calculation using find -printf for dramatically improved performance**
- **Fixed scientific notation handling for very large collections**
- **Enhanced total statistics display with both file count and disk usage**

Changes in 0.3.1:
- **Fixed total file count calculation** (was showing 0 due to subshell variable scoping issue)
- **Added sorting options for file count display (-c flag)**
- **New sort options: count-asc, count-desc for sorting by file count**
- **Enhanced -s argument to work intelligently with both search and count modes**
- Improved collection analysis capabilities with flexible sorting

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

3. Set up configuration (optional but recommended):
```bash
# First run creates the example configuration
./poster-search.sh -h

# Copy and customize the configuration
cp poster-search.env.example poster-search.env
nano poster-search.env  # Edit paths and users as needed
```

## Configuration

The script supports both internal configuration and external configuration files for enhanced portability:

### External Configuration (Recommended)
Create a `poster-search.env` file in the same directory as the script:

```bash
# Poster directory paths (comma-separated)
POSTER_PATHS="/etc/komodo/stacks/daps-ui/daps-ui/posters,/path/to/additional/posters"

# User configuration (comma-separated user:color pairs)
USERS_CONFIG="LionCityGaming:1;31,IamSpartacus:1;32,Drazzilb:1;34"
```

### Setup Instructions:
1. **First run**: The script automatically creates `poster-search.env.example` 
2. **Copy and customize**: `cp poster-search.env.example poster-search.env`
3. **Modify paths**: Update `POSTER_PATHS` with your poster directories
4. **Customize users**: Update `USERS_CONFIG` with your users and preferred colors
5. **Update-safe**: Your configuration persists across script updates

### Internal Configuration (Fallback)
If no `poster-search.env` file exists, the script uses built-in defaults:

```bash
# Search paths - Add or modify paths as needed
declare -a SEARCH_PATHS=(
    "/etc/komodo/stacks/daps-ui/daps-ui/posters"    # Main DAPS posters directory
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

### Interactive Mode
```bash
# Start interactive mode with menu-driven interface
./poster-search.sh -i
```

Interactive mode features:
- **Main Menu**: Search, statistics, user listing, advanced options, and exit
- **Collection Statistics Menu**: View file counts and disk usage with format and sorting options
- **Advanced Options Menu**: Configure search filters, sorting, and display settings
- **Persistent Settings**: All configured options remain active within the session
- **User-Friendly Navigation**: Clear prompts and menu-driven interface

### Basic Search
```bash
./poster-search.sh [search_term]
```

### Collection Statistics with Disk Usage
```bash
# Show file count and disk usage for all users (sorted by priority - default)
./poster-search.sh -c

# Show file count and disk usage sorted by highest count first
./poster-search.sh -c -s count-desc

# Show file count and disk usage sorted by largest disk usage first
./poster-search.sh -c -s size-desc

# Show file count and disk usage sorted by smallest disk usage first
./poster-search.sh -c -s size-asc

# Show file count and disk usage sorted by lowest count first
./poster-search.sh -c -s count-asc

# Show file count and disk usage sorted alphabetically by username
./poster-search.sh -c -s username

# Show file count and disk usage for specific format with sorting
./poster-search.sh -c -f jpg -s size-desc
./poster-search.sh -c -f png -s count-desc
```

Example output:
```
File count and disk usage per user:
===================================
LionCityGaming     1234 files   [1.2 GB]
IamSpartacus        892 files   [856.3 MB]
Drazzilb            567 files   [445.7 MB]
BZ                  445 files   [298.1 MB]
...
===================================
Total Count: 8456 files [3.2 GB]
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

#### For Search Results:
```bash
./poster-search.sh -s priority searchterm    # Sort by predefined priority (default)
./poster-search.sh -s username searchterm    # Sort alphabetically by username
./poster-search.sh -s filename searchterm    # Sort alphabetically by filename
./poster-search.sh -s year-asc searchterm   # Sort by year, oldest first
./poster-search.sh -s year-desc searchterm  # Sort by year, newest first
```

#### For Collection Statistics (-c flag):
```bash
./poster-search.sh -c -s priority      # Sort by user priority (default)
./poster-search.sh -c -s username      # Sort alphabetically by username
./poster-search.sh -c -s count-asc     # Sort by file count, lowest first
./poster-search.sh -c -s count-desc    # Sort by file count, highest first
./poster-search.sh -c -s size-asc      # Sort by disk usage, smallest first
./poster-search.sh -c -s size-desc     # Sort by disk usage, largest first
```

### Combining Options
```bash
./poster-search.sh -u username -f png -s priority searchterm
./poster-search.sh -c -f jpg -s size-desc  # Show JPG counts and disk usage, largest first
./poster-search.sh -i                      # Start interactive mode for guided interface
```

### Debug and Verbose Output
```bash
# Run with verbose output
./poster-search.sh -v searchterm

# Run with debug output
./poster-search.sh -d searchterm

# Can be combined with other options
./poster-search.sh -v -u username -f png searchterm
./poster-search.sh -d -c -s size-desc
```

## Command Line Options

| Option | Description |
|--------|-------------|
| -h | Show help text |
| -l | List all synced drives |
| **-c** | **Show file count and disk usage per user (collection statistics)** |
| **-i** | **Interactive mode with menu-driven interface** |
| -u username | Filter results by username (case insensitive, partial match) |
| -f format | Filter by file format (jpg, jpeg, png, or all) |
| **-s sort_option** | **Sort results - Search: (priority, username, filename, year-asc, year-desc) / Count: (priority, username, count-asc, count-desc, size-asc, size-desc)** |
| -v | Enable verbose output (shows additional processing information) |
| -d | Enable debug mode (shows additional debugging information) |

## Terminal Compatibility

The script now includes smart terminal detection and will automatically:
1. Use advanced colors (including light/dark variations) on fully-capable terminals
2. Fall back to basic ANSI colors on terminals with standard color support
3. Disable colors completely on terminals without color support

This ensures optimal visibility and compatibility across different terminal emulators and SSH sessions.

## Collection Management

The enhanced file count and disk usage feature provides valuable insights for collection management:

- **Quick overview**: See which users contribute the most content and use the most disk space
- **Format analysis**: Identify format distribution and storage usage across your collection
- **Storage planning**: Understand collection size for backup and storage decisions with precise disk usage information
- **User activity**: Monitor active contributors to your poster collection and their storage impact
- **Performance analysis**: Identify users with the largest collections for optimization
- **Storage optimization**: Find users with high file counts but low disk usage (smaller files) or vice versa

### Advanced Collection Analysis Examples:
```bash
# Find users with the most content
./poster-search.sh -c -s count-desc

# Find users using the most disk space
./poster-search.sh -c -s size-desc

# Analyze PNG distribution and disk usage
./poster-search.sh -c -f png -s size-desc

# Get alphabetical user overview with disk usage
./poster-search.sh -c -s username

# Find users with minimal collections
./poster-search.sh -c -s count-asc

# Find users with smallest disk footprint
./poster-search.sh -c -s size-asc
```

Use cases:
- `./poster-search.sh -i` - Start interactive mode for guided navigation
- `./poster-search.sh -c` - Get overall collection statistics with disk usage
- `./poster-search.sh -c -f jpg -s size-desc` - See top JPG contributors by disk usage
- `./poster-search.sh -c -s count-asc` - Identify users who might need more content
- `./poster-search.sh -c -s size-desc` - Identify users consuming the most storage space
- `./poster-search.sh -c -f png -s count-desc` - Find users with the most PNG files

## Performance

The script has been optimized for performance when calculating disk usage:
- Uses `find -printf` for efficient file size collection
- Single-pass directory traversal for both counting and size calculation
- Handles large collections (50,000+ files) efficiently
- Supports collections ranging from GB to TB in size

## Directory Structure

The script is designed to work with DAPS directory structure and expects images to be organized in the following way:
```
/etc/komodo/stacks/daps-ui/daps-ui/posters/  # Default DAPS posters directory
├── user1/                                   # DAPS sync username
│   ├── image1.jpg
│   └── image2.png
├── user2/
│   ├── image3.jpg
│   └── image4.png
└── user3/
    └── image5.jpg
```

**Configuration Options:**
- **Built-in default**: `/etc/komodo/stacks/daps-ui/daps-ui/posters`
- **External config**: Define custom paths in `poster-search.env`
- **Multiple paths**: Support for searching across multiple poster directories
- **Automatic detection**: Script creates example config on first run

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
