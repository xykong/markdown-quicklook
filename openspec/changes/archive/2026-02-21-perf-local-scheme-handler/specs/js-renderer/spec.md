## MODIFIED Requirements

### Requirement: Local Image URL Rendering
The renderer SHALL resolve local image references by generating `local-md:///` scheme URLs (using the `baseUrl` option to form absolute paths), instead of looking up pre-collected base64 data from the `imageData` option.

#### Scenario: Relative image path resolved via scheme URL
- **WHEN** `renderMarkdown()` is called with markdown containing `![alt](./image.png)` and `options.baseUrl` is set to the markdown file's parent directory
- **THEN** the rendered `<img>` tag's `src` attribute is set to `local-md:///absolute/path/to/image.png`
- **AND** WebKit fetches the image via the registered `LocalSchemeHandler`

#### Scenario: Embedded base64 images preserved
- **WHEN** markdown contains an image with a `data:image/...;base64,...` src
- **THEN** the `src` is left unchanged (no `local-md://` conversion)

#### Scenario: Network image URLs preserved
- **WHEN** markdown contains an image with an `http://` or `https://` URL
- **THEN** the `src` is left unchanged (no `local-md://` conversion)

## REMOVED Requirements

### Requirement: Base64 to Blob URL Conversion
**Reason**: With `LocalSchemeHandler` serving images directly, JS no longer receives base64-encoded image data and does not need to convert it to Blob URLs. This eliminates `atob()`, `Uint8Array`, and `URL.createObjectURL()` processing from the render path.
**Migration**: Remove the base64-to-blob conversion block from `renderMarkdown()` in `index.ts`. Remove the `imageData` parameter from the `renderMarkdown` function signature and all related TypeScript type definitions.

#### Scenario: No base64 blob conversion on render
- **WHEN** `renderMarkdown()` is called with any markdown content
- **THEN** no `atob()`, `Uint8Array`, or `URL.createObjectURL()` calls are made
- **AND** image display is handled entirely by WebKit via the `local-md://` scheme
