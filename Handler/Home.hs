{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE QuasiQuotes       #-}
{-# LANGUAGE TemplateHaskell   #-}


module Handler.Home where

import Yesod
import Foundation

getHomeR :: Handler Html
getHomeR = page

page = defaultLayout $ do
    setTitle "Calculator"
    addStylesheetRemote "https://maxcdn.bootstrapcdn.com/bootstrap/3.3.7/css/bootstrap.min.css"
    addScriptRemote "https://ajax.googleapis.com/ajax/libs/jquery/3.1.1/jquery.min.js"
    addScriptRemote "https://maxcdn.bootstrapcdn.com/bootstrap/3.3.7/js/bootstrap.min.js"
    addScriptRemote "https://cdnjs.cloudflare.com/ajax/libs/jquery-form-validator/2.3.26/jquery.form-validator.min.js"
    toWidget $(whamletFile "templates/main.hamlet")
    toWidget [julius|function Operation(n1, n2, op) {
                         this.n1 = n1;
                         this.n2 = n2;
                         this.op = op;

                         this.toPath = function () {

                             switch (this.op) {
                                 case 'add':
                                     return "/additions/" + this.n1 + "/" + this.n2;
                                 case 'subtract':
                                     return "/subtractions/"+ this.n1 + "/" +  this.n2;
                                 case 'multiply':
                                     return "/multiplications/"+ this.n1 + "/" + this.n2;
                                 case 'divide':
                                     return "/divisions/"+ this.n1 + "/" + this.n2;
                                 default:
                                     throw new Error('operation not supported: ' + this.op)
                             }
                         };
                     }

                     function getPath() {
                         var localhost = "http://localhost:3000"
                         var operation = new Operation($('#first-operand').val(), $('#second-operand').val(), $('#operations').val()).toPath();
                         return localhost + operation;
                     }

                     $.validate({
                       form : '#calculator',
                       modules : 'security',
                       onError : function($form) {
                         return false; // Will stop the submission of the form
                       },
                       onSuccess : function($form) {
                         jQuery.ajax( {
                             type: "GET",
                             url: getPath(),
                             dataType: "json",
                             success: function (data, status, req) {
                                 $('#answer').text(JSON.parse(req.responseText).result);
                             }
                         });
                         return false; // Will stop the submission of the form
                       },
                     });
 |]


