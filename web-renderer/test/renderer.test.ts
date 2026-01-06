// Mock mermaid before importing the source
jest.mock('mermaid', () => ({
  initialize: jest.fn(),
  run: jest.fn(),
}));

// We import the index file to trigger the side-effect of setting window.renderMarkdown
import '../src/index';
import mermaid from 'mermaid'; // This will be the mocked version

describe('Markdown Renderer', () => {
  beforeEach(() => {
    // Setup the DOM element that index.ts expects
    document.body.innerHTML = '<div id="markdown-preview"></div>';
    jest.clearAllMocks();
  });

  test('should render mermaid diagram using mermaid.run API', async () => {
    const markdown = `
# Title
\`\`\`mermaid
graph TD;
    A-->B;
\`\`\`
    `;

    // Execution
    await window.renderMarkdown(markdown);

    // Verification
    const preview = document.getElementById('markdown-preview');
    expect(preview).toBeTruthy();
    
    // Check if the mermaid block was transformed into a div.mermaid
    const mermaidDiv = preview?.querySelector('.mermaid');
    expect(mermaidDiv).toBeTruthy();
    expect(mermaidDiv?.textContent).toContain('graph TD');
    
    // Verify mermaid.run was called
    expect(mermaid.run).toHaveBeenCalledWith({
        querySelector: '.mermaid'
    });
  });

  test('should rewrite relative image paths using baseUrl', async () => {
    const markdown = '![img](./pic.png)';
    
    // Execution
    await window.renderMarkdown(markdown, { baseUrl: '/Users/me/docs' });

    // Verification
    const preview = document.getElementById('markdown-preview');
    const img = preview?.querySelector('img');
    expect(img).toBeTruthy();
    // Expect local-resource scheme and clean path
    expect(img?.getAttribute('src')).toBe('local-resource:///Users/me/docs/pic.png');
  });
});
