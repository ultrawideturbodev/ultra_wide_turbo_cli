# Todo List: Manual Update Command

## 1. Command Layer
- [✓] Add `update` to [[TurboCommandType]]
  - [✓] Add command name and argument
  - [✓] Add help text and description
  - [✓] No options or flags needed

## 2. Service Layer
- [✓] Enhance [[UpdateService]]
  - [✓] Add method for manual updates
  - [✓] Show current and latest version
  - [✓] Clear success/failure messages
  - [✓] Reuse existing update functionality

## 3. Test Implementation
- [ ] Create [[Test: Manual Update]]
  - [ ] Test when no update available
  - [ ] Test when update available and successful
  - [ ] Test when update fails

## 4. Documentation
- [ ] Update README.md with new command
- [ ] Update CHANGELOG.md for 0.1.9
- [ ] Update version to 0.1.9 