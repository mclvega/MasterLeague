<!-- Use this file to provide workspace-specific custom instructions to Copilot. For more details, visit https://code.visualstudio.com/docs/copilot/copilot-customization#_use-a-githubcopilotinstructionsmd-file -->
## Flutter Football Master League App

This Flutter application is designed to manage and organize football master leagues. It provides comprehensive tools for:

### Features
- **File Import**: Read player data from text files or Excel sheets from local directories or URLs
- **Player Management**: View, organize, and manage player rosters for each team/user
- **Free Agents**: Track available players not assigned to any team
- **Player Valuation**: Display and manage player prices and market values  
- **Competition Management**: Organize various cups, leagues, and tournaments
- **Team Overview**: Comprehensive team management and player allocation

### Technical Stack
- Flutter framework for cross-platform mobile development
- Excel file reading capabilities
- HTTP requests for URL-based file importing
- Clean architecture with proper state management
- Responsive UI design for various screen sizes

### Development Guidelines
- Follow Flutter best practices and material design principles
- Implement proper error handling for file operations
- Use appropriate state management (Provider/Bloc)
- Ensure smooth user experience with loading states
- Implement proper data validation and parsing

### How to Run
1. Ensure Flutter is installed and configured
2. Run `flutter pub get` to install dependencies  
3. Run `flutter run` to launch the app
4. Choose target platform (Windows/Web)

### Project Structure
- `/lib/models/` - Data models (Player, Team, Competition)
- `/lib/providers/` - State management with Provider
- `/lib/screens/` - UI screens and pages
- `/lib/services/` - Business logic and file import services
- `/lib/widgets/` - Reusable UI components
- `/lib/utils/` - Utilities and theme configuration

### Key Features Implemented
✅ File import from Excel/CSV (local and URL)
✅ Player management and search
✅ Team organization and roster management
✅ Free agents tracking
✅ Competition and league management
✅ Responsive Material Design UI
✅ Cross-platform support (Windows/Web)