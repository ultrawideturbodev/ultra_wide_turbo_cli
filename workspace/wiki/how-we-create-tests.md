---
document_type: wiki
goal: document how we create and structure tests in the project
gpt_action: follow these steps when creating new tests
---

CONTEXT: The [[GPT Agent]] NEEDS to create tests for new functionality following our testing standards and protocols.

1. GIVEN [[GPT Agent]] STARTS test creation
   1. THEN [[GPT Agent]] READ [[your-milestones]]
      1. AND [[GPT Agent]] EXTRACT Gherkin scenarios
      2. AND [[GPT Agent]] MAP scenarios to test groups
   2. IF [[milestones]] ARE missing
      1. THEN [[GPT Agent]] REQUEST clarification

2. WHEN [[GPT Agent]] PREPARES test environment
   1. THEN [[GPT Agent]] SETUP services
      ```dart
      setUpAll(() async {
        // Initialize app and services
        await AppSetup.initialise();
        storageService = LocalStorageService.locate;
        commandService = CommandService.locate;

        // Wait for services to be ready
        await storageService.isReady;
        await commandService.isReady;

        // Create temp directory for testing
        tempDir = await Directory.systemTemp.createTemp('test_dir');
        IOOverrides.global = _TestIOOverrides(tempDir);
      });
      ```
   2. AND [[GPT Agent]] IMPLEMENT cleanup
      ```dart
      tearDownAll(() async {
        // Clean up temp directory
        IOOverrides.global = null;
        if (tempDir.existsSync()) {
          await tempDir.delete(recursive: true);
        }
      });

      setUp(() async {
        // Reset storage before each test
        await storageService.clearTags();
        await storageService.clearSources();
        await storageService.clearRelations();

        // Wait for storage operations to complete
        await Future.delayed(const Duration(milliseconds: 100));
      });
      ```

3. GIVEN [[test environment]] IS ready
   1. THEN [[GPT Agent]] CREATE feature group
      ```dart
      group('Feature: Tag Source Command', () {
        // Feature tests here
      });
      ```
   2. AND [[GPT Agent]] CREATE scenario groups
      ```dart
      group('Scenario: Create new source', () {
        test('GIVEN valid input...', () async {
          // Test steps here
        });
      });
      ```
   3. IF [[scenario]] NEEDS Gherkin style
      1. THEN [[GPT Agent]] USE:
         - GIVEN: Setup conditions
         - WHEN: Action performed
         - THEN: Expected outcome
         - AND: Additional conditions

4. WHEN [[GPT Agent]] HANDLES async operations
   1. THEN [[GPT Agent]] WAIT for completion
      ```dart
      // Wait for storage operations to complete
      await Future.delayed(const Duration(milliseconds: 300));
      ```
   2. AND [[GPT Agent]] VERIFY results
      ```dart
      final storage = storageService.localStorageDto;
      final source = storage.turboSources.firstWhere(
        (s) => s.id.toLowerCase().startsWith('test_dir'),
        orElse: () => throw Exception('Source not found'),
      );
      expect(source, isNotNull);
      ```

5. GIVEN [[test]] HAS failures
   1. THEN [[GPT Agent]] FOCUS on one test
   2. AND [[GPT Agent]] IDENTIFY failure point
   3. AND [[GPT Agent]] ADD debug information
   4. AND [[GPT Agent]] FIX root cause
   5. AND [[GPT Agent]] VERIFY other tests

# ✅ Verification

1. GIVEN [[test suite]] IS complete
   1. THEN [[GPT Agent]] VERIFY coverage
      1. AND [[GPT Agent]] CHECK milestones
      2. AND [[GPT Agent]] CHECK scenarios
      3. AND [[GPT Agent]] CHECK edge cases
      4. AND [[GPT Agent]] CHECK errors

2. WHEN [[GPT Agent]] VERIFIES isolation
   1. THEN [[GPT Agent]] ENSURE:
      1. Tests USE temporary directories
      2. State IS reset between tests
      3. Tests HAVE no real data interaction
      4. Cleanup IS thorough

3. IF [[test suite]] NEEDS reliability check
   1. THEN [[GPT Agent]] VERIFY:
      1. Async operations ARE handled
      2. Tests ARE not flaky
      3. Failures HAVE clear messages
      4. Results ARE consistent 