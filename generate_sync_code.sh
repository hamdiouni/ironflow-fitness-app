#!/bin/bash

# Script to generate Freezed code for sync entities

echo "🔨 Generating Freezed code for sync entities..."
echo ""

# Run build_runner
flutter pub run build_runner build --delete-conflicting-outputs

echo ""
echo "✅ Code generation complete!"
echo ""
echo "Generated files:"
echo "  - lib/features/sync/domain/entities/sync_action.freezed.dart"
echo "  - lib/features/sync/domain/entities/sync_action.g.dart"
echo "  - lib/features/sync/domain/entities/sync_status.freezed.dart"
echo "  - lib/features/sync/domain/entities/sync_status.g.dart"
echo ""
echo "Next steps:"
echo "  1. Update Firestore security rules (see SYNC_QUICK_START.md)"
echo "  2. Add CompactSyncIndicator to app bar"
echo "  3. Test sync functionality"
echo ""
