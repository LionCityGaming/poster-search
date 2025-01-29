# Poster Image Search Script

A bash script for efficiently searching poster image files with user-based prioritization and flexible filtering options. This script is designed to work in conjunction with [DAPS (Drazzilb's Arr PMM Scripts)](https://github.com/Drazzilb08/daps) and [DAPS-UI](https://github.com/zarskie/daps-ui/wiki).

## Overview

This script enhances the poster browsing capabilities for DAPS users by providing:
- Quick searching through user-synchronized poster directories
- Priority-based sorting of trusted users' contributions
- Format-specific filtering
- Color-coded output for easy user identification

For information about setting up DAPS and DAPS-UI, please refer to:
- [DAPS Documentation](https://github.com/Drazzilb08/daps)
- [DAPS-UI Wiki](https://github.com/zarskie/daps-ui/wiki)

## Features

- Search for images by filename across multiple user directories
- Filter results by file format (JPG, JPEG, PNG)
- Sort results by various criteria including custom priority order
- Color-coded output for different users
- User-specific filtering
- Support for JPG, JPEG, and PNG files

## Version History

**Current Version:** 0.1.1

Changes from 0.1.0:
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

The script uses two main configuration arrays:
- `user_order`: Defines the priority order of users in your DAPS community
- `colors`: Maps users to their display colors for easy visual identification

The default search path is configured for a standard DAPS installation:
```bash
readonly SEARCH_PATH="/volume2/docker/dockge/stacks/daps/posters"
```

Modify this path according to your DAPS installation directory if different.

## Usage

### Basic Search
```bash
./poster-search.sh [search_term]
```

![WindowsTerminal_SbSkiJ1JIQ](https://github.com/user-attachments/assets/51047342-f6ab-4948-acba-7ca440ddc475)


### List All Users
```bash
./poster-search.sh -l
```

![WindowsTerminal_BummCFNLZ1](https://github.com/user-attachments/assets/66c96121-ebc9-4cd2-bee3-f6837771a0ad)


### Filter by Format
```bash
# Show all PNG files
./poster-search.sh -f png

![WindowsTerminal_4cqr5BcaD2](https://github.com/user-attachments/assets/2303017a-bc4a-4db1-b274-319711e9f182)

# Show all JPG files
./poster-search.sh -f jpg

# Search PNGs with term
./poster-search.sh -f png searchterm
```

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

## Command Line Options

| Option | Description |
|--------|-------------|
| -h | Show help text |
| -l | List all synced drives |
| -u username | Filter results by username (case insensitive, partial match) |
| -f format | Filter by file format (jpg, jpeg, png, or all) |
| -s sort_option | Sort results (priority, username, filename, year-asc, year-desc) |

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

## Acknowledgments

- Users who contributed to feature requests and testing
- Inspiration from similar image organization tools
