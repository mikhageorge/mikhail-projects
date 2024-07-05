function removeFilters() {
    // Clear the selected options in all dropdown menus
    document.getElementById("subjectFilter").value = "";
    document.getElementById("governorateFilter").value = "";
    document.getElementById("areaFilter").value = "";

    // Trigger the filtering function to update the organization list
    filterOrganizations();
  } 
  
  function filterOrganizations() {
      var subject = document.getElementById("subjectFilter").value;
      var governorate = document.getElementById("governorateFilter").value;
      var area = document.getElementById("areaFilter").value;
      var offerings = document.querySelectorAll(".donation-link");
    
      offerings.forEach(function (offering) {
        var offeringSubject = offering.getAttribute("subject");
        var offeringGovernorate = offering.getAttribute("governorate");
        var offeringArea = offering.getAttribute("area");
        var subjectMatch = (subject === "" || offeringSubject === subject);
        var governorateMatch = (governorate === "" || offeringGovernorate === governorate);
        var areaMatch = (area === "" || offeringArea === area);
    
        if (subjectMatch && governorateMatch && areaMatch) {
          offering.style.display = "block";
        } else {
          offering.style.display = "none";
        }
      });
    }
    