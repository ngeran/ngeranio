document.addEventListener('DOMContentLoaded', () => {

  // ============================================
  // 1. Scroll Reveal
  // ============================================
  const revealObserver = new IntersectionObserver((entries) => {
    entries.forEach(entry => {
      if (entry.isIntersecting) {
        entry.target.classList.add('revealed');
        revealObserver.unobserve(entry.target);
      }
    });
  }, { threshold: 0.1 });

  document.querySelectorAll('.scroll-reveal').forEach(el => {
    revealObserver.observe(el);
  });

  // ============================================
  // 2. Copy to Clipboard for Code Blocks
  // ============================================
  document.querySelectorAll('pre code').forEach(block => {
    const pre = block.parentElement;
    const wrapper = document.createElement('div');
    wrapper.className = 'ide-block relative mb-6';

    const header = document.createElement('div');
    header.className = 'ide-header';
    header.innerHTML = `
      <div class="ide-dots">
        <span style="background: rgba(255,180,171,0.2); border: 1px solid rgba(255,180,171,0.4);"></span>
        <span style="background: rgba(232,133,74,0.2); border: 1px solid rgba(232,133,74,0.4);"></span>
        <span style="background: rgba(77,224,130,0.2); border: 1px solid rgba(77,224,130,0.4);"></span>
      </div>
      <button class="copy-btn text-on-surface-variant hover:text-white transition-colors" title="Copy">
        <span class="material-symbols-outlined text-base">content_copy</span>
      </button>
    `;

    pre.parentNode.insertBefore(wrapper, pre);
    wrapper.appendChild(header);
    wrapper.appendChild(pre);

    const btn = header.querySelector('.copy-btn');
    btn.addEventListener('click', () => {
      navigator.clipboard.writeText(block.textContent).then(() => {
        btn.innerHTML = '<span class="material-symbols-outlined text-base text-primary">done</span>';
        setTimeout(() => {
          btn.innerHTML = '<span class="material-symbols-outlined text-base">content_copy</span>';
        }, 2000);
      });
    });
  });

  // ============================================
  // 3. Active TOC Highlighting
  // ============================================
  const tocSidebar = document.getElementById('toc-sidebar');
  if (tocSidebar) {
    const headings = document.querySelectorAll('article h2, article h3, article h4');
    const tocLinks = tocSidebar.querySelectorAll('a');

    if (headings.length > 0 && tocLinks.length > 0) {
      const tocObserver = new IntersectionObserver((entries) => {
        entries.forEach(entry => {
          if (entry.isIntersecting) {
            const id = entry.target.getAttribute('id');
            tocLinks.forEach(link => {
              link.classList.remove('text-white');
              if (link.getAttribute('href') === `#${id}`) {
                link.classList.add('text-white');
              }
            });
          }
        });
      }, {
        rootMargin: '-20% 0px -70% 0px',
        threshold: 0
      });

      headings.forEach(h => tocObserver.observe(h));
    }
  }

  // ============================================
  // 4. Article Hover Inset Border
  // ============================================
  document.querySelectorAll('.article-entry').forEach(entry => {
    entry.addEventListener('mouseenter', () => {
      entry.style.boxShadow = 'inset 4px 0 0 0 #4de082';
    });
    entry.addEventListener('mouseleave', () => {
      entry.style.boxShadow = 'none';
    });
  });

  // ============================================
  // 5. Grid Parallax
  // ============================================
  document.addEventListener('mousemove', (e) => {
    const grid = document.querySelector('.bg-grid');
    if (grid) {
      const x = (e.clientX / window.innerWidth) * 100;
      const y = (e.clientY / window.innerHeight) * 100;
      grid.style.backgroundPosition = `${x * 0.05}px ${y * 0.05}px`;
    }
  });

});
