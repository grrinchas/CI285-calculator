function Operation(n1, n2, op) {
    this.n1 = n1;
    this.n2 = n2;
    this.op = op;

    this.toPath = function () {

        switch (this.op) {
            case 'add':
                return "/additions/" + this.n1 + "/" + this.n2;
            case 'subtract':
                return "/subtractions/" + this.n1 + "/" + this.n2;
            case 'multiply':
                return "/multiplications/" + this.n1 + "/" + this.n2;
            case 'divide':
                return "/divisions/" + this.n1 + "/" + this.n2;
            default:
                throw new Error('operation not supported: ' + this.op)
        }
    };
}

function getPath() {
    return new Operation($('#first-operand').val(), $('#second-operand').val(), $('#operations').val()).toPath();
}

$.validate({
    form: '#calculator-user',
    onError: function ($form) {
        return false;
    },
    onSuccess: function ($form) {
        jQuery.ajax({
            type: "PUT",
            url: "http://localhost:3000" + getPath() + $('#save').attr("value"),
            success: function (data, status, req) {
                var answer = JSON.parse(req.responseText).result;
                $('#answer').text(answer);

                if ($('#saved-success').length) {
                    $('#saved-success').remove();
                }

                $('#save-success').after("<div class='col-md-4'id='saved-success'>" + "<div class='alert alert-success'>" +
                    answer + " has been saved. Check your calculation <a href='/history'>history</a>." + "</div>" + "</div>");
            }
        });
        return false;
    }
});

$('#logout').click(function (e) {
    e.preventDefault();
    $.ajax({
        type: 'DELETE',
        url: "http://localhost:3000/logout",
        success: function (data) {
            window.location.href = "/"
        }
    });

});


$.validate({
    form: '#calculator',
    onError: function ($form) {
        return false;
    },
    onSuccess: function ($form) {
        jQuery.ajax({
            type: "GET",
            url: "http://localhost:3000" + getPath(),
            dataType: "json",
            success: function (data, status, req) {
                $('#answer').text(JSON.parse(req.responseText).result);
            }
        });
        return false;
    }
});


function User(username, password) {
    this.username = username;
    this.password = password;
}


$.validate({
    form: '#login',
    onSuccess: function () {
        jQuery.ajax({
            sync: false,
            type: "GET",
            url: "http://localhost:3000/users/" + $('#login-username').val(),
            beforeSend: function (xhr) {
                var username = $('#login-username').val();
                var password = $('#login-password').val();
                var encoded = btoa(username + ":" + password);
                xhr.setRequestHeader("Authorization", "Basic " + encoded);
            },
            success: function (data, status, req) {
                $('#login')[0].reset();
                $('body').html(data);
            },

            statusCode: {
                404: function () {
                    if (!$('#wrong-name-pass').length) {
                        $('#login').prepend('<span id= "wrong-name-pass" style="color: #d9534f"> Incorrect username or password </span>');
                    }
                },
                401: function () {
                    if (!$('#wrong-name-pass').length) {
                        $('#login').prepend('<span id= "wrong-name-pass" style="color: #d9534f"> Incorrect username or password </span>');
                    }
                }
            }
        });
        return false;
    }
});

$.validate({
    form: '#sign-up-form',
    modules: 'security',
    onError: function () {
        return false;
    },

    onSuccess: function () {
        jQuery.ajax({
            type: 'POST',
            url: 'http://localhost:3000/users',
            data: JSON.stringify(new User($('#sign-up-username').val(), $('#sign-up-password').val())),
            success: function (data, status, req) {
                $('#sign-up-form')[0].reset();

                if (!$('#sign-up-success').length) {
                    $('#sign-up-form').prepend('<div class="alert alert-success" id="sign-up-success">' +
                        '<strong>Congratulations!</strong>Your registration was successful. Now you can login.</div>');
                }
            },
            statusCode: {
                409: function () {
                    $('#sign-up-username').parent().addClass('has-error');
                    $('#sign-up-username').after('<span class="help-block form-error">Username is already taken</span>');
                }
            }
        });
        return false;
    }
});

$(document).ready(function () {
    $(".dropdown-toggle").dropdown();
});