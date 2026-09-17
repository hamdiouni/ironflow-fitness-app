Write-Host "🔧 Fixing Freezed Files..." -ForegroundColor Cyan
Write-Host ""

Write-Host "Step 1: Deleting freezed and generated files..." -ForegroundColor Yellow
Get-ChildItem -Recurse -Include *.freezed.dart,*.g.dart | Remove-Item -Force
Write-Host "✅ Deleted freezed and generated files" -ForegroundColor Green
Write-Host ""

Write-Host "Step 2: Deleting build cache..." -ForegroundColor Yellow
Remove-Item -Recurse -Force .dart_tool -ErrorAction SilentlyContinue
Write-Host "✅ Deleted build cache" -ForegroundColor Green
Write-Host ""

Write-Host "Step 3: Cleaning Flutter..." -ForegroundColor Yellow
flutter clean
Write-Host "✅ Flutter cleaned" -ForegroundColor Green
Write-Host ""

Write-Host "Step 4: Getting dependencies..." -ForegroundColor Yellow
flutter pub get
Write-Host "✅ Dependencies installed" -ForegroundColor Green
Write-Host ""

Write-Host "Step 5: Running build_runner..." -ForegroundColor Yellow
Write-Host "⏳ THIS WILL TAKE 5-10 MINUTES - PLEASE BE PATIENT!" -ForegroundColor Cyan
Write-Host "⏳ Do not interrupt this process..." -ForegroundColor Cyan
Write-Host ""
dart run build_runner build --delete-conflicting-outputs
Write-Host "✅ Build complete!" -ForegroundColor Green
Write-Host ""

Write-Host "Step 6: Running the app..." -ForegroundColor Yellow
Write-Host "🚀 Starting IronFlow in Chrome..." -ForegroundColor Cyan
Write-Host "📝 Login with: demo@ironflow.com / password123" -ForegroundColor Cyan
Write-Host ""
flutter run -d chrome
