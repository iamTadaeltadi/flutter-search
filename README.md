# Flutter Search Task

A high-performance Flutter search feature with the ability to search by username, occupation, and name. Built with scalability and performance in mind.

## Features

- **Multi-field Search**: Search across username, name, and occupation simultaneously
- **Real-time Search**: Debounced search with 300ms delay for optimal performance
- **Scalable Architecture**: Inverted index-based search algorithm for O(1) lookups
- **Categorized Results**: Separate sections for usernames and categories
- **Clean UI**: Modern, responsive design matching the provided reference images
- **Performance Optimized**: Handles large datasets and many simultaneous users efficiently

## Architecture

### Models
- **User**: Represents a user with profile information, rating, and skills
- **SearchResult**: Contains search match information with relevance scoring

### Services
- **SearchService**: High-performance search engine with:
  - Inverted indexes for fast lookups
  - Partial matching support
  - Relevance-based ranking
  - Support for username, name, occupation, and category searches
  
- **DataService**: Provides sample data for testing

### Widgets
- **SearchBarWidget**: Custom search input with clear button
- **UserResultCard**: Displays user search results with profile information
- **CategoryChip**: Interactive category chips for filtering

### Screens
- **SearchScreen**: Main search interface with real-time results

## Performance Considerations

1. **Inverted Indexes**: Pre-built indexes for O(1) lookup performance
2. **Debouncing**: 300ms delay prevents excessive search operations
3. **Efficient Algorithms**: Relevance scoring and smart filtering
4. **Scalable Design**: Can handle thousands of users efficiently
5. **Memory Efficient**: Uses sets and maps for fast deduplication

## Getting Started

### Prerequisites
- Flutter SDK (3.0.0 or higher)
- Dart SDK (3.0.0 or higher)

### Installation

1. Clone the repository:
```bash
git clone <repository-url>
cd flutter-search-task
```

2. Install dependencies:
```bash
flutter pub get
```

3. Run the app:
```bash
flutter run
```

## Usage

1. Start typing in the search bar to search by:
   - **Username**: e.g., "@master_carpenter"
   - **Name**: e.g., "Bob Wilson"
   - **Occupation**: e.g., "Carpenter" or "Car Mechanic"

2. Results are displayed in sections:
   - **Matching Usernames**: Users whose usernames match the query
   - **Matching Categories**: Categories and occupations matching the query

3. Tap on a category chip to search for that category

4. Tap the clear button (X) to reset the search

## Sample Queries

- "mast" - Finds users with "mast" in username (e.g., @master_carpenter)
- "car" - Finds car mechanics, car painters, and related categories
- "bob" - Finds users named Bob
- "carpenter" - Finds carpenters and related skills

## Code Structure

```
lib/
├── main.dart                 # App entry point
├── models/
│   ├── user.dart            # User data model
│   └── search_result.dart    # Search result model
├── services/
│   ├── search_service.dart  # Search engine implementation
│   └── data_service.dart    # Sample data provider
├── screens/
│   └── search_screen.dart   # Main search screen
└── widgets/
    ├── search_bar_widget.dart    # Search input widget
    ├── user_result_card.dart     # User result display
    └── category_chip.dart        # Category chip widget
```

## Best Practices Implemented

1. **Separation of Concerns**: Clear separation between models, services, and UI
2. **Reusable Components**: Modular widget design
3. **Performance Optimization**: Debouncing, indexing, and efficient algorithms
4. **Error Handling**: Try-catch blocks and user feedback
5. **Clean Code**: Well-documented, maintainable code structure
6. **Scalability**: Designed to handle growth in data and users

## Future Enhancements

- Backend API integration
- Caching for offline support
- Advanced filtering options
- Search history
- User favorites/bookmarks
- Pagination for large result sets
- Analytics and search insights

## License

This project is created for demonstration purposes.


