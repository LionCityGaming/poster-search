# Poster Image Search Script

A bash script for efficiently searching and organizing poster image files with user-based prioritization and flexible filtering options. This script is designed to work in conjunction with [DAPS (Drazzilb's Arr PMM Scripts)](https://github.com/Drazzilb08/daps) and [DAPS-UI](https://github.com/zarskie/daps-ui/wiki).

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
chmod +x search.sh
```

3. (Optional) Create a symbolic link to make it available system-wide:
```bash
sudo ln -s "$(pwd)/search.sh" /usr/local/bin/imgsearch
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
./search.sh [search_term]
```

### List All Users
```bash
./search.sh -l
```

### Filter by Format
```bash
# Show all PNG files
./search.sh -f png

# Show all JPG files
./search.sh -f jpg

# Search PNGs with term
./search.sh -f png searchterm
```

### Filter by Username
```bash
./search.sh -u username searchterm
```

### Sort Options
```bash
./search.sh -s priority searchterm    # Sort by predefined priority (default)
./search.sh -s username searchterm    # Sort alphabetically by username
./search.sh -s filename searchterm    # Sort alphabetically by filename
./search.sh -s year-asc searchterm   # Sort by year, oldest first
./search.sh -s year-desc searchterm  # Sort by year, newest first
```

### Combining Options
```bash
./search.sh -u username -f png -s priority searchterm
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
