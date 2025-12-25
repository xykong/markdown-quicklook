import 'github-markdown-css/github-markdown.css';
import 'highlight.js/styles/github.css';
import 'katex/dist/katex.min.css';

import MarkdownIt from 'markdown-it';
import mermaid from 'mermaid';
import hljs from 'highlight.js';

// Import MarkdownIt plugins
// Note: Some of these might require specific type definitions or ignore rules if types aren't found
// @ts-ignore
import mk from 'markdown-it-katex';
// @ts-ignore
import emoji from 'markdown-it-emoji';
// @ts-ignore
import footnote from 'markdown-it-footnote';
// @ts-ignore
import taskLists from 'markdown-it-task-lists';
// @ts-ignore
import mark from 'markdown-it-mark';
// @ts-ignore
import sub from 'markdown-it-sub';
// @ts-ignore
import sup from 'markdown-it-sup';

// Configure Mermaid
mermaid.initialize({
    startOnLoad: false,
    theme: 'default'
});

// Configure MarkdownIt
const md: MarkdownIt = new MarkdownIt({
    html: true,
    breaks: true,
    linkify: true,
    typographer: true,
    highlight: function (str: string, lang: string): string {
        if (lang && hljs.getLanguage(lang)) {
            try {
                return '<pre class="hljs"><code>' +
                    hljs.highlight(str, { language: lang, ignoreIllegals: true }).value +
                    '</code></pre>';
            } catch (__) { }
        }
        const codeClass = lang ? 'language-' + lang : '';
        return '<pre class="hljs"><code class="' + codeClass + '">' + md.utils.escapeHtml(str) + '</code></pre>';
    }
});

// Use plugins
md.use(mk);
md.use(emoji);
md.use(footnote);
md.use(taskLists);
md.use(mark);
md.use(sub);
md.use(sup);

// Define global interface for window
declare global {
    interface Window {
        renderMarkdown: (text: string) => void;
    }
}

// Render function called by Swift
window.renderMarkdown = function (text: string) {
    const outputDiv = document.getElementById('markdown-preview');
    if (!outputDiv) return;

    // 1. Render Markdown to HTML
    let html = md.render(text);

    // 2. Render Mermaid diagrams
    // Strategy: Find mermaid code blocks and replace them with div for mermaid to process
    // But markdown-it usually renders them as <pre><code class="language-mermaid">...</code></pre>
    
    // We can use a custom renderer for mermaid blocks, or post-process.
    // Let's post-process for simplicity.
    const tempDiv = document.createElement('div');
    tempDiv.innerHTML = html;
    
    const mermaidBlocks = tempDiv.querySelectorAll('pre code.language-mermaid');
    mermaidBlocks.forEach((block, index) => {
        const pre = block.parentElement;
        if (pre) {
            const div = document.createElement('div');
            div.classList.add('mermaid');
            div.textContent = block.textContent || '';
            div.id = `mermaid-${index}`;
            pre.replaceWith(div);
        }
    });

    outputDiv.innerHTML = tempDiv.innerHTML;

    // 3. Trigger Mermaid rendering
    mermaid.run({
        querySelector: '.mermaid'
    });
};

console.log('Markdown Renderer Loaded');
