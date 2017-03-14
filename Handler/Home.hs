{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE QuasiQuotes       #-}
{-# LANGUAGE TemplateHaskell   #-}


module Handler.Home where

import Yesod.Core
import Foundation

getHomeR :: Handler Html
getHomeR = defaultLayout $ do
    addStylesheetRemote "https://maxcdn.bootstrapcdn.com/bootstrap/3.3.7/css/bootstrap.min.css"
    addScriptRemote "https://ajax.googleapis.com/ajax/libs/jquery/3.1.1/jquery.min.js"
    addScriptRemote "https://maxcdn.bootstrapcdn.com/bootstrap/3.3.7/js/bootstrap.min.js"
    toWidget $(whamletFile "templates/default-layout.hamlet")
