function removeFilters() {
    // Clear the selected options in all dropdown menus
    document.getElementById("filter").value = "";
    // Trigger the filtering function to update the organization list
    filterOrganizations();
  }

  function filterOrganizations() {
    var type = document.getElementById("filter").value;
    

    var offerings = document.querySelectorAll(".donation-link");

    offerings.forEach(function (offering) {
      var offeringType = offering.getAttribute("type");
      

      var typeMatch = (type === "" || offeringType === type );
      

      if (typeMatch) {
        offering.style.display = "block";
      } else {
        offering.style.display = "none";
      }
    });
  }



  document.querySelectorAll('.read-more').forEach(function(button) {
    button.addEventListener('click', function(event) {
        event.preventDefault(); // Prevent default behavior of the button (e.g., submitting a form or following a link)
        event.stopPropagation(); // Prevent click event from propagating to parent elements
        
        // Select the item-about paragraph associated with the clicked button
        var itemAbout = this.parentElement.querySelector('.item-about');
        
        // Toggle the max-height property of the item-about paragraph
        if (itemAbout.style.maxHeight === '100px') {
            itemAbout.style.maxHeight = '17px';
            this.textContent = 'Read full about'; // Change button text to 'Read full about'

        } else {
            itemAbout.style.maxHeight = '100px';
            this.textContent = 'Read less'; // Change button text to 'Read less'

        }
        
        // Add a class to trigger the pulse animation
        this.classList.add('pulse-animation');
        
        // Remove the class after the animation duration to allow it to replay
        setTimeout(() => {
            this.classList.remove('pulse-animation');
        }, 1000); // Adjust the duration (in milliseconds) to match the animation duration
    });
});
