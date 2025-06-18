# Poster Image Search Script

A bash script for efficiently searching poster image files with user-based prioritization and flexible filtering options. This script is designed to work in conjunction with [DAPS (Drazzilb's Arr PMM Scripts)](https://github.com/Drazzilb08/daps) and [DAPS-UI](https://github.com/zarskie/daps-ui/wiki).

## Features

- **Interactive menu-driven interface** with enhanced navigation patterns
- **Collection statistics** with file count and disk usage per user
- **Smart search** across multiple user directories with format filtering
- **Priority-based sorting** of trusted contributors  
- **External configuration** via `poster-search.env` for portability
- **Adaptive color output** with automatic terminal compatibility detection
- **Multiple format support** (JPG, JPEG, PNG) with flexible filtering
- **Advanced sorting options** for both search results and collection statistics

## Quick Start

1. **Clone and setup**:
```bash
git clone https://github.com/LionCityGaming/poster-search.git
cd poster-search
chmod +x poster-search.sh
```

2. **Configure** (recommended):
```bash
# First run creates example config
./poster-search.sh -h
# Copy and customize
cp poster-search.env.example poster-search.env
nano poster-search.env  # Edit paths and users
```

3. **Start interactive mode**:
```bash
./poster-search.sh -i
```

## Latest Version: 0.7.5

### Recent Changes (v0.7.5):
- **Fixed collection statistics accuracy** - Restored `-mindepth 1` in file counting to prevent double-counting
- **Enhanced macOS compatibility** - Improved cross-platform support for file size calculations
- **Stable configuration system** - Refined external config loading with better error handling
- **Maintained color support** - Preserved user-specific color coding from configuration files

## Essential Usage

### Interactive Mode (Recommended)
```bash
./poster-search.sh -i
```
Features an intuitive menu system with:
- Main menu with 5 primary options
- Consistent navigation (option 1 always returns to main menu)
- Collection statistics with sorting options
- Advanced search configuration
- Visual feedback and status indicators

### Command Line Usage
```bash
# Basic search
./poster-search.sh movie

# Collection statistics with disk usage
./poster-search.sh -c

# Filter by user and format
./poster-search.sh -u username -f png searchterm

# Sort collection by disk usage
./poster-search.sh -c -s size-desc
```

## Key Command Options

| Option | Description |
|--------|-------------|
| `-i` | **Interactive mode** - Enhanced menu-driven interface |
| `-c` | **Collection statistics** - File count and disk usage per user |
| `-u username` | Filter by username (partial match) |
| `-f format` | Filter by format (jpg, jpeg, png, all) |
| `-s sort` | Sort results (see sorting options below) |
| `-l` | List all configured users |
| `-v` | Verbose output with full paths |

### Sorting Options

**For search results (`-s`):**
- `priority` - User priority order (default)
- `username` - Alphabetical by user
- `filename` - Alphabetical by filename
- `year-asc/year-desc` - By year in filename

**For collection statistics (`-c -s`):**
- `priority` - User priority order (default)
- `username` - Alphabetical by user
- `count-asc/count-desc` - By file count
- `size-asc/size-desc` - By disk usage

## Configuration

Create `poster-search.env` in the script directory:

```bash
# Poster directory paths (comma-separated)
POSTER_PATHS="/etc/komodo/stacks/daps-ui/daps-ui/posters,/additional/paths"

# User configuration with colors (comma-separated user:color pairs)
USERS_CONFIG="LionCityGaming:1;31,IamSpartacus:1;32,Drazzilb:1;34"
```

### Color Codes:
- `0;31` = Dark Red, `1;31` = Light Red
- `0;32` = Dark Green, `1;32` = Light Green  
- `0;34` = Dark Blue, `1;34` = Light Blue
- `91-97` = Bright colors (91=bright red, 92=bright green, etc.)

## Collection Management Examples

```bash
# Get overview of entire collection
./poster-search.sh -c

# Find users with most content
./poster-search.sh -c -s count-desc

# Find users using most disk space  
./poster-search.sh -c -s size-desc

# Analyze PNG distribution
./poster-search.sh -c -f png -s size-desc

# Interactive mode for guided interface
./poster-search.sh -i
```

Example collection statistics output:
```
File count and disk usage per user:
===================================
LionCityGaming     1234 files   [1.2 GB]
IamSpartacus        892 files   [856.3 MB]
Drazzilb            567 files   [445.7 MB]
===================================
Total Count: 2693 files [2.5 GB]
```

## Prerequisites

- [DAPS](https://github.com/Drazzilb08/daps) installation
- Bash shell (version 4.0+)
- Access to DAPS posters directory
- Terminal with basic color support (optional)

## Directory Structure

The script expects images organized by user:
```
/posters/
├── user1/
│   ├── movie1.jpg
│   └── show1.png
├── user2/
│   └── movie2.jpg
```

## Performance

Optimized for large collections:
- Single-pass directory traversal
- Efficient file size calculation
- Handles 50,000+ files
- Supports GB to TB collections
- Fast interactive menu transitions

## Related Links

- [DAPS](https://github.com/Drazzilb08/daps) - Docker Automated Plex Synchronization
- [DAPS-UI](https://github.com/zarskie/daps-ui) - Web interface for DAPS
- [DAPS-UI Wiki](https://github.com/zarskie/daps-ui/wiki) - Documentation
- [DAPS Discord](https://discord.gg/FT6wcxqyZ5) - Official community

## Contributing

1. Fork the repository
2. Create feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit changes (`git commit -m 'Add AmazingFeature'`)
4. Push to branch (`git push origin feature/AmazingFeature`)
5. Open Pull Request

## License

MIT License - see [LICENSE](LICENSE) file for details.
