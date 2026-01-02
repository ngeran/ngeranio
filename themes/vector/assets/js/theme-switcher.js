/**
 * Theme Switcher for ngeran[io] Blog
 * Handles dark/light mode toggling with system preference detection
 * and localStorage persistence
 */

(function() {
  'use strict';

  const THEME_KEY = 'ngeran-theme';
  const DARK_THEME = 'dark';
  const LIGHT_THEME = 'light';

  // Get theme from localStorage or system preference
  function getInitialTheme() {
    const storedTheme = localStorage.getItem(THEME_KEY);
    if (storedTheme) {
      return storedTheme;
    }

    // Check system preference
    if (window.matchMedia && window.matchMedia('(prefers-color-scheme: dark)').matches) {
      return DARK_THEME;
    }

    return LIGHT_THEME;
  }

  // Apply theme to document
  function applyTheme(theme) {
    const html = document.documentElement;
    const body = document.body;

    if (theme === DARK_THEME) {
      html.classList.add(DARK_THEME);
      html.classList.remove(LIGHT_THEME);
      body.classList.add('bg-gray-900', 'text-gray-100');
      body.classList.remove('bg-gray-50', 'text-gray-900');
    } else {
      html.classList.add(LIGHT_THEME);
      html.classList.remove(DARK_THEME);
      body.classList.add('bg-gray-50', 'text-gray-900');
      body.classList.remove('bg-gray-900', 'text-gray-100');
    }

    // Update toggle button icon
    updateToggleButton(theme);
  }

  // Update toggle button appearance
  function updateToggleButton(theme) {
    const toggleBtn = document.getElementById('theme-toggle');
    if (!toggleBtn) return;

    const icon = toggleBtn.querySelector('svg');
    if (!icon) return;

    if (theme === DARK_THEME) {
      // Show sun icon
      icon.innerHTML = '<circle cx="12" cy="12" r="5"></circle><line x1="12" y1="1" x2="12" y2="3"></line><line x1="12" y1="21" x2="12" y2="23"></line><line x1="4.22" y1="4.22" x2="5.64" y2="5.64"></line><line x1="18.36" y1="18.36" x2="19.78" y2="19.78"></line><line x1="1" y1="12" x2="3" y2="12"></line><line x1="21" y1="12" x2="23" y2="12"></line><line x1="4.22" y1="19.78" x2="5.64" y2="18.36"></line><line x1="18.36" y1="5.64" x2="19.78" y2="4.22"></line>';
      toggleBtn.setAttribute('aria-label', 'Switch to light mode');
      toggleBtn.setAttribute('title', 'Switch to light mode');
    } else {
      // Show moon icon
      icon.innerHTML = '<path d="M21 12.79A9 9 0 1 1 11.21 3 7 7 0 0 0 21 12.79z"></path>';
      toggleBtn.setAttribute('aria-label', 'Switch to dark mode');
      toggleBtn.setAttribute('title', 'Switch to dark mode');
    }
  }

  // Toggle theme
  function toggleTheme() {
    const currentTheme = localStorage.getItem(THEME_KEY) || getInitialTheme();
    const newTheme = currentTheme === DARK_THEME ? LIGHT_THEME : DARK_THEME;

    localStorage.setItem(THEME_KEY, newTheme);
    applyTheme(newTheme);

    // Dispatch custom event for other components
    window.dispatchEvent(new CustomEvent('themeChanged', { detail: { theme: newTheme } }));
  }

  // Initialize theme switcher
  function init() {
    // Apply initial theme immediately to prevent flash
    const initialTheme = getInitialTheme();
    applyTheme(initialTheme);

    // Create and inject toggle button
    const toggleBtn = document.createElement('button');
    toggleBtn.id = 'theme-toggle';
    toggleBtn.className = 'p-2 rounded-lg hover:bg-gray-200 dark:hover:bg-gray-700 transition-colors duration-200 focus:outline-none focus:ring-2 focus:ring-[#5e81ac]';
    toggleBtn.setAttribute('aria-label', 'Toggle theme');
    toggleBtn.innerHTML = '<svg xmlns="http://www.w3.org/2000/svg" width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"></svg>';

    toggleBtn.addEventListener('click', toggleTheme);

    // Insert button into navigation
    const navContainer = document.querySelector('nav .mx-auto');
    if (navContainer) {
      const desktopMenu = navContainer.querySelector('.hidden.lg\\:flex');
      if (desktopMenu) {
        const buttonWrapper = document.createElement('div');
        buttonWrapper.className = 'flex items-center';
        buttonWrapper.appendChild(toggleBtn);
        navContainer.appendChild(buttonWrapper);
      }
    }

    // Listen for system theme changes
    if (window.matchMedia) {
      const darkModeQuery = window.matchMedia('(prefers-color-scheme: dark)');
      darkModeQuery.addEventListener('change', (e) => {
        // Only auto-switch if user hasn't set a preference
        if (!localStorage.getItem(THEME_KEY)) {
          const newTheme = e.matches ? DARK_THEME : LIGHT_THEME;
          applyTheme(newTheme);
        }
      });
    }
  }

  // Run on DOM ready
  if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', init);
  } else {
    init();
  }

  // Expose toggleTheme globally for manual triggering
  window.toggleTheme = toggleTheme;
  window.getCurrentTheme = () => localStorage.getItem(THEME_KEY) || getInitialTheme();

})();
