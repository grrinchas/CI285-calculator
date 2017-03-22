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

module Handler.Users where

import Prelude hiding (drop, concat)
import Yesod
import Network.HTTP.Types
import Network.Wai (Request(..))
import Control.Monad (when)
import Control.Monad.IO.Class (liftIO)
import Control.Applicative
import Foundation
import Data.Aeson hiding (decode)
import Data.Text hiding (split, drop)

import Database.Persist
import Database.Persist.TH
import Database.Persist.Sqlite
import Control.Monad.IO.Class (liftIO)
import Data.Maybe
import Network.HTTP.Types.Header
import Yesod.Core.Handler
import Data.ByteString.Base64
import Data.Either.Unwrap
import Data.Text.Encoding
import qualified Data.ByteString as BS (split, drop, putStrLn)


instance FromJSON User where
 parseJSON (Object v) =
    User   <$> v .: "username"
           <*> v .: "password"

postUsersR:: Handler ()
postUsersR = do
    user  <- requireJsonBody :: Handler User
    let uName = userUsername user
    maybeUnique <- runDB $ checkUnique user
    case maybeUnique of
        Just _ -> sendResponseStatus status409 ()
        Nothing -> do
            iUser <- runDB $ insert user
            addHeader "Location" $ append "http://localhost:3000/users/" uName
            sendResponseStatus status201 ()


getUsersHomeR :: Text -> Handler ()
getUsersHomeR x = do
    maybeUser <- runDB $ getBy $ UniqueUsername x
    case maybeUser of
        Nothing -> sendResponseStatus status404 ()
        Just (Entity id (User name pass)) -> do
            request <- waiRequest
            case lookup "Authorization" (requestHeaders request) of
                Just b -> do
                    case decode $ BS.drop 6 b of
                        Left s -> sendResponseStatus status400 ()
                        Right s ->
                            case concat [name,":", pass] == decodeUtf8 s of
                                False -> do
                                    addHeader "WWW-Authenticate" "Basic realm=\"users\""
                                    sendResponseStatus status401 ()
                                True -> do
                                    html <- defaultLayout $ do
                                        setTitle "Sign Up"
                                        addStylesheetRemote "https://maxcdn.bootstrapcdn.com/bootstrap/3.3.7/css/bootstrap.min.css"
                                        addScriptRemote "https://ajax.googleapis.com/ajax/libs/jquery/3.1.1/jquery.min.js"
                                        addScriptRemote "https://maxcdn.bootstrapcdn.com/bootstrap/3.3.7/js/bootstrap.min.js"
                                        addScriptRemote "https://cdnjs.cloudflare.com/ajax/libs/jquery-form-validator/2.3.26/jquery.form-validator.min.js"
                                        addScript $ StaticR main_js
                                        toWidget $(whamletFile "templates/usersHome.hamlet")
                                    sendResponseStatus status201 html
                _ -> do
                     addHeader "WWW-Authenticate" "Basic realm=\"users\""
                     sendResponseStatus status401 ()
