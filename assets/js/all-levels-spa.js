// All Levels SPA - Show/Hide levels and navigation

document.addEventListener('DOMContentLoaded', function() {
  const levelSections = document.querySelectorAll('.level-section');
  const toggleAllBtn = document.getElementById('toggle-all');
  const collapseAllBtn = document.getElementById('collapse-all');
  const jumpLinks = document.querySelectorAll('.level-jump-link');
  
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
  
  // Quick jump navigation
  jumpLinks.forEach(link => {
    link.addEventListener('click', function(e) {
      e.preventDefault();
      const levelNum = this.getAttribute('data-level');
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
    });
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
  document.addEventListener('keydown', function(e) {
    if (e.key === 'ArrowDown' || e.key === 'ArrowUp') {
      e.preventDefault();
      if (e.key === 'ArrowDown' && currentLevel < 20) {
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

