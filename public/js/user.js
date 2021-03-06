$(document).ready(function(){
	$(".form-control").on("blur", function(){
		$(this).removeClass("error");
	});

	var params = window.location.search.substr(1).split("&");
	for(var i = 0; i < params.length; i++){
		var param = params[i].split("=");
		if(param[0] == "err") handleError(param[1]);
		if(param[0] == "msg") handleMessage(param[1]);
	}
	history.replaceState(null, document.title, window.location.pathname);
});

function handleError(err){
	if(err === "email_taken") highlightErrors(".form-signup", ["email"]);
	else if(err === "email_not_found") highlightErrors(".form-login", ["email"]);
	else if(err === "invalid_password") highlightErrors(".form-login", ["password"]);
}

function validateEmail(klass, allowBlank){
	var email = $(klass + " input[name=email]").val();
	if(allowBlank && email.length === 0) return true;
	return email.match(/.+@(.+\.)+.+/);
}

function validatePassword(klass, allowBlank){
	var password = $(klass + " input[name=password]").val();
	if(allowBlank && password.length === 0) return true;
	return password.length >= 6;
}

function validatePasswordConfirmation(klass){
	return $(klass + " input[name=password]").val() === $(klass + " input[name=password_confirmation]").val();
}

function highlightErrors(klass, fields){
	$(".error").removeClass("error");
	for(var i = 0; i < fields.length; i++){
		$(klass + " input[name=" + fields[i] + "]").addClass("error");
	}
	$(klass + " input[name=" + fields[0] + "]").focus();
}

function validateSignup(){
	var KLASS = ".form-signup";
	var errors = [];
	if(!validateEmail(KLASS)) errors.push("email");
	if(!validatePassword(KLASS)) errors.push("password");
	if(!validatePasswordConfirmation(KLASS)) errors.push("password_confirmation");

	if(errors.length === 0) return true;
	highlightErrors(KLASS, errors);
	return false;
}

function validateLogin(){
	var KLASS = ".form-login";
	var errors = [];
	if(!validateEmail(KLASS)) errors.push("email");
	if(!validatePassword(KLASS)) errors.push("password");

	if(errors.length === 0) return true;
	highlightErrors(KLASS, errors);
	return false;
}
