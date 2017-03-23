{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE TemplateHaskell   #-}
{-# LANGUAGE TypeFamilies      #-}
{-# LANGUAGE ViewPatterns      #-}
{-# LANGUAGE QuasiQuotes           #-}
{-# LANGUAGE EmptyDataDecls             #-}
{-# LANGUAGE FlexibleContexts           #-}
{-# LANGUAGE GADTs                      #-}
{-# LANGUAGE GeneralizedNewtypeDeriving #-}
{-# LANGUAGE MultiParamTypeClasses      #-}

module Foundation where

import Yesod
import Yesod.Static
import Network.HTTP.Types (mkStatus)
import Network.Wai (Request(..))
import Control.Monad (when)

import Database.Persist
import Database.Persist.TH
import Database.Persist.Sqlite
import Control.Monad.IO.Class (liftIO)
import Database.Persist.Quasi
import Data.Text

staticFiles "static"

share [mkPersist sqlSettings, mkMigrate "migrateAll"]
    $(persistFileWith lowerCaseSettings "config/models")


instance YesodPersist App where
    type YesodPersistBackend App = SqlBackend

    runDB action = do
        App pool _ <- getYesod
        runSqlPool action pool

data App = App
    { getConnectionPool :: ConnectionPool,
      getStatic :: Static
    }


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
                    <img style="width: 100px;height=100px" src=@{StaticR sad_face_png}/>
                    <h1>Oops,
                    <h2>Sorry, an error has occured, #{show other}
                    <a href="http://localhost:3000" class="btn btn-large btn-info"><i class="icon-home icon-white"></i> Take Me Home</a>
                    |]

