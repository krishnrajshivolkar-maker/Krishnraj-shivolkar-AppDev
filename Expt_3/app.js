const countEl = document.getElementById('count');
const increaseBtn = document.getElementById('increase');
const decreaseBtn = document.getElementById('decrease');
const resetBtn = document.getElementById('reset');

let count = 0;

// Increase
increaseBtn.addEventListener('click', () => {
  count++;
  updateDisplay();
});

// Decrease
decreaseBtn.addEventListener('click', () => {
  count--;
  updateDisplay();
});

// Reset
resetBtn.addEventListener('click', () => {
  count = 0;
  updateDisplay();
});

// Update UI
function updateDisplay() {
  countEl.textContent = count;
}
