function removeFilters() {
  // Clear the selected options in all dropdown menus
  document.getElementById("ageFilter").value = "";
  document.getElementById("genderFilter").value = "";
  document.getElementById("seasonFilter").value = "";
  // Trigger the filtering function to update the organization list
  filterOrganizations();
} 

function filterOrganizations() {
    var age = document.getElementById("ageFilter").value;
    var gender = document.getElementById("genderFilter").value;
    var season = document.getElementById("seasonFilter").value;
    var offerings = document.querySelectorAll(".donation-link");
  
    offerings.forEach(function (offering) {
      var offeringAge = offering.getAttribute("age");
      var offeringGender = offering.getAttribute("gender");
      var offeringSeason = offering.getAttribute("season");
      var ageMatch = (age === "" || offeringAge === age);
      var genderMatch = (gender === "" || offeringGender === gender);
      var seasonMatch = (season === "" || offeringSeason === season);
  
      if (ageMatch && genderMatch && seasonMatch) {
        offering.style.display = "block";
      } else {
        offering.style.display = "none";
      }
    });
  }
  