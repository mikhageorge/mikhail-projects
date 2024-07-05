$(document).ready(function () {
  
    // Hide error messages initially
    $("#emptyfirstname").hide();
    $("#emptylastname").hide();
    $("#emptyemail").hide();
    $("#incorrectemail").hide();
    $("#emptynumber").hide();
    $("#incorrectnumber").hide();
    $("#emptypassword").hide();
    $("#emptypassword2").hide();
    $("#incorrectpassword2").hide();
    $("#emptyaddress").hide();
    $("#emptyarea").hide();
    $("#emptygovernorate").hide();
    
    // Set initial error states
    let errors = {
        firstname: true,
        lastname: true,
        email: true,
        contactnumber: true,
        password: true,
        confirmpassword: true,
        address: true,
        area: true,
        governorate: true
    };

    // Function to validate first name
    $("#firstname").keyup(function () {
        let firstnameValue = $(this).val().trim();
        if (firstnameValue === "") {
            $("#emptyfirstname").show();
            errors.firstname = true;
        } else {
            $("#emptyfirstname").hide();
            errors.firstname = false;
        }
        checkForm();
    });

    // Function to validate last name
    $("#Lastname").keyup(function () {
        let lastnameValue = $(this).val().trim();
         if (lastnameValue === "") {
            $("#emptylastname").show();
            errors.lastname = true;
        } else {
            $("#emptylastname").hide();
            errors.lastname = false;
        }
        checkForm();
    });

    // Function to validate email
    $("#Email").keyup(function () {
        let emailValue = $(this).val().trim();
        // Add your validation logic here
        // Example: Check if email is in valid format
    });

    // Function to validate contact number
    $("#contactnumber").keyup(function () {
        let contactnumberValue = $(this).val().trim();
        if (contactnumberValue === "") {
            $("#incorrectnumber").hide();
            $("#emptynumber").show();
            errors.contactnumber = true;
        } else if (contactnumberValue.length !== 11 || !contactnumberValue.startsWith("01")) {
            $("#emptynumber").hide();
            $("#incorrectnumber").show();
            errors.contactnumber = true;
        } else {
            $("#emptynumber").hide();
            $("#incorrectnumber").hide();
            errors.contactnumber = false;
        }
        checkForm();
    });

    // Function to validate password
    $("#password").keyup(function () {
        let passwordValue = $(this).val().trim();
        if (passwordValue === "") {
            $("#emptypassword").show();
            errors.password = true;
        } else {
            $("#emptypassword").hide();
            errors.password = false;
        }
        checkForm();
    });

    // Function to validate confirm password
    $("#confirmpassword").keyup(function () {
        let confirmPasswordValue = $(this).val().trim();
        let passwordValue = $("#password").val().trim();
        if (confirmPasswordValue === "") {
            $("#emptypassword2").show();
            errors.confirmpassword = true;
        } else if (confirmPasswordValue !== passwordValue) {
            $("#emptypassword2").hide();
            $("#incorrectpassword2").show();
            errors.confirmpassword = true;
        } else {
            $("#emptypassword2").hide();
            $("#incorrectpassword2").hide();
            errors.confirmpassword = false;
        }
        checkForm();
    });

    // Function to validate address
    $("#address").keyup(function () {
        let addressValue = $(this).val().trim();
        if (addressValue === "") {
            $("#emptyaddress").show();
            errors.address = true;
        } else {
            $("#emptyaddress").hide();
            errors.address = false;
        }
        checkForm();
    });

    // Function to validate area
    $("#area").keyup(function () {
        let areaValue = $(this).val().trim();
        if (areaValue === "") {
            $("#emptyarea").show();
            errors.area = true;
        } else {
            $("#emptyarea").hide();
            errors.area = false;
        }
        checkForm();
    });

    // Function to validate governorate
    $("#governorate").keyup(function () {
        let governorateValue = $(this).val().trim();
        if (governorateValue === "") {
            $("#emptygovernorate").show();
            errors.governorate = true;
        } else {
            $("#emptygovernorate").hide();
            errors.governorate = false;
        }
        checkForm();
    });

    // Function to check form validity
    function checkForm() {
        let isValid = true;
        for (let error in errors) {
            if (errors[error]) {
                isValid = false;
                break;
            }
        }
        if (isValid) {
            $(".form-submit-btn input[type='submit']").prop("disabled", false);
        } else {
            $(".form-submit-btn input[type='submit']").prop("disabled", true);
        }
    }

    // Prevent default form submission
    $("#myForm").submit(function (event) {
        event.preventDefault();
        // Handle form submission here (e.g., sending data to server)
        let allErrorsFalse = true;
        for (let error in errors) {
            if (errors[error]) {
                allErrorsFalse = false;
                break;
            }
        }
        if (allErrorsFalse) {
            window.location.href = "indexlogin.html";
        }
    });

});
