/// Riverpod 3 retries a failing provider automatically by default. Every
/// provider here fails for terminal reasons (a database read, a missing
/// key) where retrying just delays the error screen, and the UI already
/// offers an explicit Retry (ErrorView). So retry is off app-wide; pass
/// this to every ProviderScope and ProviderContainer, tests included.
Duration? noAutomaticRetry(int retryCount, Object error) => null;
