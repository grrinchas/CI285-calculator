{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE QuasiQuotes       #-}
{-# LANGUAGE TemplateHaskell   #-}

module Handler.Signup where

import Yesod
import Foundation

getSignupR :: Handler Html
getSignupR = page

page = defaultLayout $ do
    setTitle "Sign Up"
    addStylesheetRemote "https://maxcdn.bootstrapcdn.com/bootstrap/3.3.7/css/bootstrap.min.css"
    addScriptRemote "https://ajax.googleapis.com/ajax/libs/jquery/3.1.1/jquery.min.js"
    addScriptRemote "https://maxcdn.bootstrapcdn.com/bootstrap/3.3.7/js/bootstrap.min.js"
    addScriptRemote "https://cdnjs.cloudflare.com/ajax/libs/jquery-form-validator/2.3.26/jquery.form-validator.min.js"
    toWidget $(whamletFile "templates/signup.hamlet")
    toWidget [julius|
               $.validate({
                 form : '#sign-up-form',
                 modules : 'security',
                 onError : function($form) {
                   return false; // Will stop the submission of the form
                 },
               /*  onSuccess : function($form) {
                   jQuery.ajax( {
                       type: "POST",
                       url: http://localhost:3000/users,
                       dataType: "json",
                       success: function (data, status, req) {
                           $('#answer').text(JSON.parse(req.responseText).result);
                       }
                   });
                   return false; // Will stop the submission of the form
                 }, */
               });
     |]
