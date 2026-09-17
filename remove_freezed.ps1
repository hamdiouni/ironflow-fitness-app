# Script to remove all freezed and generated files
Write-Host "Removing all .freezed.dart files..." -ForegroundColor Yellow
Get-ChildItem -Path "lib" -Filter "*.freezed.dart" -Recurse | Remove-Item -Force
Write-Host "Removed .freezed.dart files" -ForegroundColor Green

Write-Host "Removing all .g.dart files..." -ForegroundColor Yellow
Get-ChildItem -Path "lib" -Filter "*.g.dart" -Recurse | Remove-Item -Force
Write-Host "Removed .g.dart files" -ForegroundColor Green

Write-Host "Done! All generated files removed." -ForegroundColor Green
