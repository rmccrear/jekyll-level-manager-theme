// All Levels SPA - Show/Hide levels and navigation

document.addEventListener('DOMContentLoaded', function() {
  const levelSections = document.querySelectorAll('.level-section');
  const toggleAllBtn = document.getElementById('toggle-all');
  const collapseAllBtn = document.getElementById('collapse-all');
  const quickJumpContainer = document.getElementById('quick-jump-links');
  
  // Generate Quick Jump links from actual level sections on the page
  if (quickJumpContainer && levelSections.length > 0) {
    const links = [];
    levelSections.forEach(section => {
      const levelNum = section.getAttribute('data-level') || section.id.replace('level-', '');
      if (levelNum) {
        const link = document.createElement('a');
        link.href = `#level-${levelNum}`;
        link.className = 'level-jump-link';
        link.setAttribute('data-level', levelNum);
        link.textContent = levelNum;
        links.push(link);
      }
    });
    
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
  
  // Quick jump navigation (use event delegation since links are created dynamically)
  document.addEventListener('click', function(e) {
    if (e.target.classList.contains('level-jump-link')) {
      e.preventDefault();
      const levelNum = e.target.getAttribute('data-level');
      const targetSection = document.getElementById(`level-${levelNum}`);
      
      if (targetSection) {
        // Show the section
        targetSection.style.display = 'block';
        // Scroll to it
        targetSection.scrollIntoView({ behavior: 'smooth', block: 'start' });
        // Highlight briefly
        targetSection.classList.add('highlight');
        setTimeout(() => {
          targetSection.classList.remove('highlight');
        }, 2000);
      }
    }
  });
  
  // Hash-based navigation (e.g., #level-5)
  if (window.location.hash) {
    const targetLevel = window.location.hash.replace('#level-', '');
    const targetSection = document.getElementById(`level-${targetLevel}`);
    if (targetSection) {
      targetSection.style.display = 'block';
      targetSection.scrollIntoView({ behavior: 'smooth' });
    }
  }
  
  // Keyboard navigation (arrow keys)
  let currentLevel = 1;
  const maxLevel = levelSections.length;
  document.addEventListener('keydown', function(e) {
    if (e.key === 'ArrowDown' || e.key === 'ArrowUp') {
      e.preventDefault();
      if (e.key === 'ArrowDown' && currentLevel < maxLevel) {
        currentLevel++;
      } else if (e.key === 'ArrowUp' && currentLevel > 1) {
        currentLevel--;
      }
      
      const targetSection = document.getElementById(`level-${currentLevel}`);
      if (targetSection) {
        targetSection.style.display = 'block';
        targetSection.scrollIntoView({ behavior: 'smooth', block: 'center' });
      }
    }
  });
});

