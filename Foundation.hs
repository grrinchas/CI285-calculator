{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE TemplateHaskell   #-}
{-# LANGUAGE TypeFamilies      #-}
{-# LANGUAGE ViewPatterns      #-}
{-# LANGUAGE QuasiQuotes           #-}

module Foundation where

import Yesod.Core
import Network.HTTP.Types (mkStatus)
import Network.Wai (Request(..))
import Control.Monad (when)

data App = App


mkYesodData "App" $(parseRoutesFile "config/routes")

instance Yesod App where

    errorHandler other = fmap toTypedContent $ defaultLayout $ do
        setTitle "Error Page"
        addStylesheetRemote "https://maxcdn.bootstrapcdn.com/bootstrap/3.3.7/css/bootstrap.min.css"
        addScriptRemote "https://ajax.googleapis.com/ajax/libs/jquery/3.1.1/jquery.min.js"
        addScriptRemote "https://maxcdn.bootstrapcdn.com/bootstrap/3.3.7/js/bootstrap.min.js"
        toWidget [hamlet|
        $doctype 5
        <html>
         <body>
          <div class="container">
            <div class="row" style="margin-top: 100px">
                <div class="col-md-12 text-center">
                    <h1>Oops,
                    <h2>Sorry, an error has occured, #{show other}
                    <a href="http://localhost:3000" class="btn btn-large btn-info"><i class="icon-home icon-white"></i> Take Me Home</a>
                    |]

