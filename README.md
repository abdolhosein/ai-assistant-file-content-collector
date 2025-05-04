# File Content Collector

A comprehensive and powerful Bash script that collects and combines file contents from selected directories and file types into a single output file, with an interactive selection interface.
It's a good choice to gather file content of your project in a row and in a selective manner when you want to talk to AI bots to help you on your codes!
It's shell-script nature makes its flexible and useful in any environment and it's iteractive environment will makes more help by decreasing your concerns! 

## Features

- 🖥️ **Interactive menu system** with keyboard navigation (arrows + spacebar)
- 📂 **Flexible directory scanning** (including subdirectories)
- 🔍 **File type detection** (with support for no-extension files)
- 🎨 **Colorized interface** for better user experience
- 🏗️ **Configurable** via command-line or interactive prompts
- 🐧 **Cross-platform** (works on both Linux and macOS)

## Installation

1. **Clone the repository**:
   ```bash
   git clone https://github.com/yourusername/file-content-collector.git
   cd file-content-collector
   ```

2. **Make the script executable**:
   ```bash
   chmod +x file_collector.sh
   ```

## Usage

**Basic Interactive Mode**
   ```bash
   ./file_collector.sh
   ```

**Command-Line Options**
   ```bash
   ./file_collector.sh -d /path/to/directory -o output_filename.txt
   ```

| Option      | Description              | Default Value         |
| ----------- | ------------------------ | --------------------- |
| -d          | Target directory to scan | Current directory (.) |
| -o          | Output filename          | combined_contents.txt |
| -h          | Show help message        | N/A                   |

**Interactive Controls**

| Key                       | Action                     |
| ------------------------- | -------------------------- |
| <kbd>↑</kbd>/<kbd>↓</kbd> | Move between items         |
| <kbd>←</kbd>/<kbd>→</kbd> | Change pages               |
| <kbd>Space</kbd>          | Toggle selection           |
| <kbd>Enter</kbd>          | Confirm selection          |
| <kbd>a</kbd>              | Select all visible items   |
| <kbd>u</kbd>              | Unselect all visible items |
| <kbd>q</kbd>              | Quit without saving        |

##Example Workflow

1. Run the script:
   ```bash
   ./file_collector.sh -d ~/projects
   ```

2. Navigate directories with arrows, select with spacebar

3. Choose file types to include

4. Script generates `combined_contents.txt` with:
   ```
   ===== path/to/file1.txt =====
   [file content]

   ===== path/to/file2.log =====
   [file content]
   ```

## Example Output 📄

```
   ===== path/to/file1.txt =====
   [file content]

   ===== path/to/file2.log =====
   [file content]
```

## Compatibility ✔️

- ✅ macOS (Bash 3.2+)  (Tested!)
- ✅ Linux (Bash 4.0+)  
- ✅ Windows WSL  

## License 📜

MIT License - See [LICENSE](LICENSE) for details
