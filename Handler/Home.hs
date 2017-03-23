{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE QuasiQuotes       #-}
{-# LANGUAGE TemplateHaskell   #-}
{-# LANGUAGE TypeFamilies      #-}


module Handler.Home where

import Yesod
import Foundation
import Text.Hamlet (HtmlUrl, hamlet)
import Text.Blaze.Html.Renderer.String (renderHtml)
import Data.Text
import Network.HTTP.Types



getHomeR :: Handler ()
getHomeR = do
    maybeName <- lookupSession "username"
    case maybeName of
         Just name -> do
            addHeader "Location" $ append "http://localhost:3000/users/" name
            sendResponseStatus status301 ()
         Nothing -> do
            layout <- homeLayout
            sendResponseStatus status200 layout


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

deleteLogoutR :: Handler ()
deleteLogoutR = do
    maybeName <- lookupSession "username"
    case maybeName of
        Just name -> do
            deleteSession "username"
            addHeader "Location" ""
            sendResponseStatus status201 ()
        Nothing -> do
            addHeader "Location" ""
            sendResponseStatus status201 ()



homeLayout :: Handler Html
homeLayout = defaultLayout $ do
    setTitle "Calculator"
    addStylesheetRemote "https://maxcdn.bootstrapcdn.com/bootstrap/3.3.7/css/bootstrap.min.css"
    addScriptRemote "https://ajax.googleapis.com/ajax/libs/jquery/3.1.1/jquery.min.js"
    addScriptRemote "https://maxcdn.bootstrapcdn.com/bootstrap/3.3.7/js/bootstrap.min.js"
    addScriptRemote "https://cdnjs.cloudflare.com/ajax/libs/jquery-form-validator/2.3.26/jquery.form-validator.min.js"
    addScript $ StaticR main_js
    toWidget $(whamletFile "templates/main.hamlet")


signUpLayout:: Handler Html
signUpLayout = defaultLayout $ do
    setTitle "Sign Up"
    addStylesheetRemote "https://maxcdn.bootstrapcdn.com/bootstrap/3.3.7/css/bootstrap.min.css"
    addScriptRemote "https://ajax.googleapis.com/ajax/libs/jquery/3.1.1/jquery.min.js"
    addScriptRemote "https://maxcdn.bootstrapcdn.com/bootstrap/3.3.7/js/bootstrap.min.js"
    addScriptRemote "https://cdnjs.cloudflare.com/ajax/libs/jquery-form-validator/2.3.26/jquery.form-validator.min.js"
    addScript $ StaticR main_js
    toWidget $(whamletFile "templates/signup.hamlet")