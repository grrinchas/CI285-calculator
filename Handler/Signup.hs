{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE QuasiQuotes       #-}
{-# LANGUAGE TemplateHaskell   #-}

module Handler.Signup where

import Yesod
import Foundation
import Yesod.Static
import Network.HTTP.Types
import Data.Text

getSignupR :: Handler ()
getSignupR = do
    maybeName <- lookupSession "username"
    case maybeName of
         Just name -> do
            addHeader "Location" $ append "http://localhost:3000/users/" name
            sendResponseStatus status301 ()
         Nothing -> do
            layout <- signUpLayout
            sendResponseStatus status200 layout

signUpLayout:: Handler Html
signUpLayout = defaultLayout $ do
    setTitle "Sign Up"
    addStylesheetRemote "https://maxcdn.bootstrapcdn.com/bootstrap/3.3.7/css/bootstrap.min.css"
    addScriptRemote "https://ajax.googleapis.com/ajax/libs/jquery/3.1.1/jquery.min.js"
    addScriptRemote "https://maxcdn.bootstrapcdn.com/bootstrap/3.3.7/js/bootstrap.min.js"
    addScriptRemote "https://cdnjs.cloudflare.com/ajax/libs/jquery-form-validator/2.3.26/jquery.form-validator.min.js"
    addScript $ StaticR main_js
    toWidget $(whamletFile "templates/signup.hamlet")
