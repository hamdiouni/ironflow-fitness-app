# AI System

The AI System provides personalized fitness and nutrition coaching using OpenAI's GPT-4 API.

## Setup

### 1. Get OpenAI API Key

1. Go to [OpenAI Platform](https://platform.openai.com/api-keys)
2. Sign up or log in
3. Create a new API key
4. Copy the key

### 2. Configure Environment

1. Open `.env` file in the project root
2. Replace `your_openai_api_key_here` with your actual API key:
   ```
   OPENAI_API_KEY=sk-...
   ```
3. **Important**: Never commit `.env` to version control

### 3. Initialize in App

The AI service is automatically initialized when the app starts. The `flutter_dotenv` package loads the `.env` file.

## Architecture

### Data Layer
- `ai_service.dart` - OpenAI API client with streaming support
- `ai_repository_impl.dart` - Repository implementation with chat history

### Domain Layer
- `ai_repository.dart` - Repository interface
- `chat_message.dart` - Chat message entity
- `ai_response.dart` - AI response entity with types

### Presentation Layer
- `ai_providers.dart` - Riverpod providers for dependency injection
- `ai_chat_screen.dart` - Chat UI (to be implemented in task 5.5)

## Features

### Current (Task 5.1)
- ✅ OpenAI API integration
- ✅ Error handling with custom exceptions
- ✅ Streaming response support
- ✅ Chat history management
- ✅ System prompt configuration

### Planned
- Context building from user data (Task 5.2)
- Chat UI (Task 5.5)
- AI coaching features (Tasks 5.7-5.9)

## Usage

```dart
// Get the repository
final aiRepository = ref.watch(aiRepositoryProvider);

// Send a message
final response = await aiRepository.sendMessage(
  'Generate a new workout program',
  context: userContext,
);

// Stream a response
aiRepository.streamMessage(
  'What should I eat today?',
  context: userContext,
).listen((chunk) {
  print(chunk);
});

// Get chat history
final history = await aiRepository.getChatHistory();

// Clear chat
await aiRepository.clearChatHistory();
```

## Error Handling

The AI service throws `AIServiceException` for API errors:

```dart
try {
  await aiRepository.sendMessage('Hello');
} on AIRepositoryException catch (e) {
  print('Error: ${e.message}');
  print('Code: ${e.code}');
}
```

Common error codes:
- `MISSING_API_KEY` - API key not configured
- `INVALID_API_KEY` - Invalid API key
- `RATE_LIMIT` - Rate limit exceeded
- `TIMEOUT` - Request timeout
- `SERVICE_ERROR` - OpenAI service error

## Testing

Run tests:
```bash
flutter test test/features/ai/
```

Tests include:
- API service error handling
- Repository message management
- Chat history tracking
- Response parsing

## Cost Considerations

- GPT-4 API calls cost money
- Monitor usage at [OpenAI Usage](https://platform.openai.com/account/usage/overview)
- Consider implementing rate limiting for production
- Cache responses when possible

## Next Steps

1. Implement context builder (Task 5.2)
2. Create chat UI (Task 5.5)
3. Implement AI coaching features (Tasks 5.7-5.9)
