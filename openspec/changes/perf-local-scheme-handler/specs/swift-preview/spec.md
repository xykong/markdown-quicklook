## ADDED Requirements

### Requirement: Local Scheme Handler Registration
The preview extension SHALL register `LocalSchemeHandler` as the URL scheme handler for the `local-md` scheme in `WKWebViewConfiguration` during `viewDidLoad`, before the `WKWebView` instance is created.

#### Scenario: Handler registered at init time
- **WHEN** `viewDidLoad` is called
- **THEN** a `LocalSchemeHandler` instance is set via `webConfiguration.setURLSchemeHandler(_:forURLScheme:)` with scheme `"local-md"`
- **AND** the handler's `baseDirectory` is updated each time `preparePreviewOfFile()` is called

### Requirement: File Directory as Base for Image Resolution
The preview extension SHALL set `LocalSchemeHandler.baseDirectory` to the parent directory of the markdown file being previewed, enabling the handler to resolve relative image paths.

#### Scenario: Preview of file with local images
- **WHEN** `preparePreviewOfFile(at:completionHandler:)` is called with a URL pointing to a markdown file
- **THEN** `localSchemeHandler.baseDirectory` is set to `url.deletingLastPathComponent()`
- **AND** subsequent `local-md://` requests from WebKit are resolved relative to that directory

## REMOVED Requirements

### Requirement: Synchronous Image Data Collection
**Reason**: `collectImageData(from:content:)` read all referenced image files synchronously on the main thread and base64-encoded them into a dictionary passed to JS. This is replaced by the on-demand `LocalSchemeHandler` which lets WebKit fetch only the images it actually needs to display.
**Migration**: Remove `collectImageData()` call from `preparePreviewOfFile()` and delete the method body. Pass `baseUrl` (already present) instead of `imageData` in the options dictionary.

#### Scenario: Image loading without pre-collection
- **WHEN** `preparePreviewOfFile()` completes
- **THEN** no image files are read from disk before `renderMarkdown()` is called
- **AND** images are loaded on-demand by WebKit via the `local-md://` scheme handler
