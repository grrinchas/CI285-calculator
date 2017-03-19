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
    addScriptRemote "https://cdn.rawgit.com/grrinchas/6f0b26ec1aeeb0e9bdd27cfd3f58ce5c/raw/a720bc5a81496ba223a5c129ff29eb2197104335/main.js"
    toWidget $(whamletFile "templates/main.hamlet")


