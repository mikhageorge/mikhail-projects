function removeFilters() {
    // Clear the selected options in all dropdown menus
    document.getElementById("hospitalFilter").value = "";
    document.getElementById("governorateFilter").value = "";
    document.getElementById("areaFilter").value = "";

    // Trigger the filtering function to update the organization list
    filterOrganizations();
  } 
  
  function filterOrganizations() {
      var hospital = document.getElementById("hospitalFilter").value;
      var governorate = document.getElementById("governorateFilter").value;
      var area = document.getElementById("areaFilter").value;
      var offerings = document.querySelectorAll(".donation-link");
    
      offerings.forEach(function (offering) {
        var offeringHospital = offering.getAttribute("hospital");
        var offeringGovernorate = offering.getAttribute("governorate");
        var offeringArea = offering.getAttribute("area");
        var hospitalMatch = (hospital === "" || offeringHospital === hospital);
        var governorateMatch = (governorate === "" || offeringGovernorate === governorate);
        var areaMatch = (area === "" || offeringArea === area);
    
        if (hospitalMatch && governorateMatch && areaMatch) {
          offering.style.display = "block";
        } else {
          offering.style.display = "none";
        }
      });
    }
    