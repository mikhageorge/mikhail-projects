document.addEventListener("DOMContentLoaded", function() {
  const donateButtons = document.querySelectorAll('.donate-btn');

  donateButtons.forEach(button => {
    button.addEventListener('click', function() {
      const quantityContainer = this.nextElementSibling;
      const quantityElement = quantityContainer.querySelector('.quantity-number');
      quantityContainer.classList.toggle('active');
      if (quantityContainer.classList.contains('active')) {
        button.style.display = 'none';
        // Set initial value of counter to 1
        quantityElement.textContent = '1';
      } else {
        button.style.display = 'inline-block';
      }
    });
  });

  const increaseButtons = document.querySelectorAll('.increase');
  const decreaseButtons = document.querySelectorAll('.decrease');

  increaseButtons.forEach(button => {
    button.addEventListener('click', function() {
      const quantityElement = this.parentElement.querySelector('.quantity-number');
      let quantity = parseInt(quantityElement.textContent);
      if (quantity < 5) {
        quantityElement.textContent = ++quantity;
      } else {
        alert('Thank you for your generosity! However, we have reached our maximum donation limit for this item. Your support is greatly appreciated. Kindly proceed to delivery.');
      }
      toggleDonateButtonVisibility(this.parentElement);
    });
  });

  decreaseButtons.forEach(button => {
    button.addEventListener('click', function() {
      const quantityElement = this.parentElement.querySelector('.quantity-number');
      let quantity = parseInt(quantityElement.textContent);
      if (quantity > 1) {
        quantityElement.textContent = --quantity;
      }
      toggleDonateButtonVisibility(this.parentElement);
    });
  });

  function toggleDonateButtonVisibility(container) {
    const donateButton = container.previousElementSibling;
    const quantityElement = container.querySelector('.quantity-number');
    if (parseInt(quantityElement.textContent) > 1) {
      donateButton.style.display = 'none';
    } else {
      donateButton.style.display = 'inline-block';
      container.classList.remove('active');
    }
  }

  const deliveryBtn = document.querySelector('.delivery-btn');
  const quantityNumber = document.querySelector('.quantity-number');

  deliveryBtn.addEventListener('click', function() {
    if (parseInt(quantityNumber.textContent) === 0) {
      alert('Please select a quantity before proceeding to delivery.');
    } else {
      window.location.href = 'checkoutdelivery.html';
    }
  });
});

