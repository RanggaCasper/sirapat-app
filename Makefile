# Run app in debug mode
run:
	@flutter run

# Run app in release mode
run-release:
	@flutter run --release

# Get dependencies
get:
	@flutter pub get

# Clean build files
clean:
	@flutter clean

# Build Android APK (release)
build-android:
	@flutter build apk --release --target-platform android-arm64

# Build Android APK (debug)
build-android-debug:
	@flutter build apk --debug

# Build Android App Bundle
build-appbundle:
	@flutter build appbundle --release

# Build iOS
build-ios:
	@flutter build ios --release

# Generate app icons
generate-icons:
	@flutter pub run flutter_launcher_icons

# Run code generation
generate:
	@flutter pub run build_runner build --delete-conflicting-outputs

# Run tests
test:
	@flutter test

# Format code
format:
	@flutter format lib/

# Analyze code
analyze:
	@flutter analyze

# Install dependencies and clean
setup:
	@flutter clean
	@flutter pub get
	@flutter pub run flutter_launcher_icons

# Create GitHub release tag
release:
	@echo "Current version in pubspec.yaml:"
	@grep "version:" pubspec.yaml
	@echo ""
	@echo "Enter new version (e.g., 1.0.1):"
	@read VERSION && \
	git add . && \
	git commit -m "Release v$$VERSION" && \
	git tag v$$VERSION && \
	git push origin main && \
	git push origin v$$VERSION && \
	echo "Release v$$VERSION created! Check GitHub Actions for build status."

# View GitHub workflow status (requires GitHub CLI)
workflow-status:
	@gh run list --workflow=build.yml --limit 5

# Download latest release artifacts
download-release:
	@gh release download --pattern "*.apk" --pattern "*.aab"