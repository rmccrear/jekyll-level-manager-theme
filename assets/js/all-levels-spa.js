// All Levels SPA - Show/Hide levels and navigation

document.addEventListener('DOMContentLoaded', function() {
  const levelSections = document.querySelectorAll('.level-section');
  const toggleAllBtn = document.getElementById('toggle-all');
  const collapseAllBtn = document.getElementById('collapse-all');
  const focusModeBtn = document.getElementById('focus-mode');
  const quickJumpContainer = document.getElementById('quick-jump-links');
  
  // Focus mode state
  let focusMode = false;
  
        // Generate Quick Jump links: simple sequential numbering (1, 2, 3...)
        // Count the number of level sections and create links from 1 to that count
        if (quickJumpContainer && levelSections.length > 0) {
          const links = [];
          const levelCount = levelSections.length;
          
          // Create links for levels 1 through levelCount
          for (let i = 1; i <= levelCount; i++) {
            const link = document.createElement('a');
            link.href = `#level-${i}`;
            link.className = 'level-jump-link';
            link.setAttribute('data-level', i);
            link.textContent = i;
            links.push(link);
          }
          
          // Clear container and add links with separators
          quickJumpContainer.innerHTML = '';
          links.forEach((link, index) => {
            quickJumpContainer.appendChild(link);
            if (index < links.length - 1) {
              quickJumpContainer.appendChild(document.createTextNode(' | '));
            }
          });
        } else if (quickJumpContainer) {
          quickJumpContainer.textContent = 'No levels available';
        }
  
  // Function to show only a specific level (for focus mode)
  function showOnlyLevel(levelNum) {
    levelSections.forEach(section => {
      const sectionLevel = section.getAttribute('data-level') || section.id.replace('level-', '');
      if (sectionLevel === String(levelNum)) {
        section.style.display = 'block';
        section.scrollIntoView({ behavior: 'smooth', block: 'start' });
      } else {
        section.style.display = 'none';
      }
    });
  }
  
  // Function to show all levels (exit focus mode)
  function showAllLevels() {
    levelSections.forEach(section => {
      section.style.display = 'block';
    });
  }
  
  // Function to update UI based on focus mode state
  function updateFocusModeUI() {
    if (focusMode) {
      focusModeBtn.textContent = 'Exit Focus Mode';
      focusModeBtn.classList.add('active');
    } else {
      focusModeBtn.textContent = 'Focus Mode';
      focusModeBtn.classList.remove('active');
    }
  }
  
  // Initially show all levels
  let allExpanded = true;
  
  // Toggle all levels
  toggleAllBtn.addEventListener('click', function() {
    allExpanded = !allExpanded;
    levelSections.forEach(section => {
      if (allExpanded) {
        section.style.display = 'block';
        toggleAllBtn.textContent = 'Collapse All';
      } else {
        section.style.display = 'none';
        toggleAllBtn.textContent = 'Show All Levels';
      }
    });
  });
  
  // Collapse all
  collapseAllBtn.addEventListener('click', function() {
    levelSections.forEach(section => {
      section.style.display = 'none';
    });
    allExpanded = false;
    toggleAllBtn.textContent = 'Show All Levels';
  });
  
  // Focus Mode toggle
  focusModeBtn.addEventListener('click', function() {
    focusMode = !focusMode;
    updateFocusModeUI();
    
    if (focusMode) {
      // Enter focus mode - show only current level or first level
      const hash = window.location.hash;
      if (hash && hash.startsWith('#level-')) {
        const targetLevel = hash.replace('#level-', '');
        showOnlyLevel(targetLevel);
      } else if (levelSections.length > 0) {
        // Show first level by default
        showOnlyLevel(1);
        window.location.hash = '#level-1';
      }
    } else {
      // Exit focus mode - show all levels
      showAllLevels();
    }
  });
  
  // Quick jump navigation (use event delegation since links are created dynamically)
  document.addEventListener('click', function(e) {
    if (e.target.classList.contains('level-jump-link')) {
      e.preventDefault();
      const levelNum = e.target.getAttribute('data-level');
      
      // Update URL hash
      window.location.hash = `#level-${levelNum}`;
      
      if (focusMode) {
        // In focus mode, show only this level
        showOnlyLevel(levelNum);
      } else {
        // Normal mode: show the section and scroll to it
        const targetSection = document.getElementById(`level-${levelNum}`);
        if (targetSection) {
          targetSection.style.display = 'block';
          targetSection.scrollIntoView({ behavior: 'smooth', block: 'start' });
          // Highlight briefly
          targetSection.classList.add('highlight');
          setTimeout(() => {
            targetSection.classList.remove('highlight');
          }, 2000);
        }
      }
    }
  });
  
  // Hash-based navigation (e.g., #level-5)
  function handleHashChange() {
    const hash = window.location.hash;
    if (hash && hash.startsWith('#level-')) {
      const targetLevel = hash.replace('#level-', '');
      
      if (focusMode) {
        // In focus mode, show only this level
        showOnlyLevel(targetLevel);
      } else {
        // Normal mode: show the section
        const targetSection = document.getElementById(`level-${targetLevel}`);
        if (targetSection) {
          targetSection.style.display = 'block';
          targetSection.scrollIntoView({ behavior: 'smooth' });
        }
      }
    }
  }
  
  // Handle initial hash
  if (window.location.hash) {
    handleHashChange();
  }
  
  // Listen for hash changes (for browser back/forward and anchor clicks)
  window.addEventListener('hashchange', handleHashChange);
  
  // Keyboard navigation (arrow keys)
  let currentLevel = 1;
  const maxLevel = levelSections.length;
  
  // Update current level from hash if present
  if (window.location.hash && window.location.hash.startsWith('#level-')) {
    const hashLevel = parseInt(window.location.hash.replace('#level-', ''));
    if (!isNaN(hashLevel)) {
      currentLevel = hashLevel;
    }
  }
  
  document.addEventListener('keydown', function(e) {
    if (e.key === 'ArrowDown' || e.key === 'ArrowUp') {
      e.preventDefault();
      if (e.key === 'ArrowDown' && currentLevel < maxLevel) {
        currentLevel++;
      } else if (e.key === 'ArrowUp' && currentLevel > 1) {
        currentLevel--;
      }
      
      // Update hash
      window.location.hash = `#level-${currentLevel}`;
      
      if (focusMode) {
        // In focus mode, show only this level
        showOnlyLevel(currentLevel);
      } else {
        // Normal mode: show and scroll to section
        const targetSection = document.getElementById(`level-${currentLevel}`);
        if (targetSection) {
          targetSection.style.display = 'block';
          targetSection.scrollIntoView({ behavior: 'smooth', block: 'center' });
        }
      }
    }
  });
  
  // Initialize focus mode button UI
  updateFocusModeUI();
});

