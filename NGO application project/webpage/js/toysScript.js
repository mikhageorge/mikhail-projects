function removeFilters() {
    // Clear the selected options in all dropdown menus
    document.getElementById("ageFilter").value = "";
    document.getElementById("genderFilter").value = "";
    document.getElementById("categoryFilter").value = "";
    // Trigger the filtering function to update the organization list
    filterOrganizations();
  } 
  
  function filterOrganizations() {
      var age = document.getElementById("ageFilter").value;
      var gender = document.getElementById("genderFilter").value;
      var category = document.getElementById("categoryFilter").value;
      var offerings = document.querySelectorAll(".donation-link");
    
      offerings.forEach(function (offering) {
        var offeringAge = offering.getAttribute("age");
        var offeringGender = offering.getAttribute("gender");
        var offeringCategory = offering.getAttribute("category");
        var ageMatch = (age === "" || offeringAge === age);
        var genderMatch = (gender === "" || offeringGender === gender);
        var categoryMatch = (category === "" || offeringCategory === category);
    
        if (ageMatch && genderMatch && categoryMatch) {
          offering.style.display = "block";
        } else {
          offering.style.display = "none";
        }
      });
    }
    