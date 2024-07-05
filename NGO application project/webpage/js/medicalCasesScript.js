function removeFilters() {
    // Clear the selected options in all dropdown menus
    document.getElementById("specialtyFilter").value = "";
    document.getElementById("organizationFilter").value = "";
    document.getElementById("governorateFilter").value = "";
    document.getElementById("areaFilter").value = "";

    // Trigger the filtering function to update the organization list
    filterOrganizations();
  } 
  
  function filterOrganizations() {
      var specialty = document.getElementById("specialtyFilter").value;
      var organization = document.getElementById("organizationFilter").value;
      var governorate = document.getElementById("governorateFilter").value;
      var area = document.getElementById("areaFilter").value;
      var offerings = document.querySelectorAll(".donation-link");
    
      offerings.forEach(function (offering) {
        var offeringSpecialty = offering.getAttribute("specialty");
        var offeringOrganization= offering.getAttribute("organization");
        var offeringGovernorate = offering.getAttribute("governorate");
        var offeringArea = offering.getAttribute("area");
        var specialtyMatch = (specialty === "" || offeringSpecialty === specialty);
        var organizationMatch = (organization === "" || offeringOrganization === organization);
        var governorateMatch = (governorate === "" || offeringGovernorate === governorate);
        var areaMatch = (area === "" || offeringArea === area);
    
        if (specialtyMatch&& organizationMatch && governorateMatch && areaMatch) {
          offering.style.display = "block";
        } else {
          offering.style.display = "none";
        }
      });
    }
    