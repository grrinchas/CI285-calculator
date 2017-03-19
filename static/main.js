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
    var localhost = "http://localhost:3000";
    var operation = new Operation($('#first-operand').val(), $('#second-operand').val(), $('#operations').val()).toPath();
    return localhost + operation;
}

$.validate({
    form: '#calculator',
    modules: 'security',
    onError: function ($form) {
        return false;
    },
    onSuccess: function ($form) {
        jQuery.ajax({
            type: "GET",
            url: getPath(),
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

                if(!$('#sign-up-success').length){
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
