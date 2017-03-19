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

import Yesod
import Network.HTTP.Types (mkStatus, status201, status409)
import Network.Wai (Request(..))
import Control.Monad (when)
import Control.Monad.IO.Class (liftIO)
import Control.Applicative
import Foundation
import Data.Aeson
import Data.Text

import Database.Persist
import Database.Persist.TH
import Database.Persist.Sqlite
import Control.Monad.IO.Class (liftIO)
import Data.Maybe


instance FromJSON User where
 parseJSON (Object v) =
    User   <$> v .: "username"
           <*> v .: "password"

instance ToJSON User where
   toJSON (User username password) = object ["username" .= username, "password" .= password]

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
            sendResponseStatus status201 (toJSON user)

