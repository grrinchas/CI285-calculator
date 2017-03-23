
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

module Handler.History where

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
import Handler.Operation



putUsersMultiplicationsR :: Integer -> Integer -> Text -> Handler ()
putUsersMultiplicationsR x y n = do
    maybeName <- lookupSession "username"
    case maybeName of
        Just name -> do
            maybeUser <- runDB $ getBy $ UniqueUsername name
            case maybeUser of
                Just user@(Entity id _) -> do
                    let answer = fromInteger (x * y)
                    calcId <- runDB $ insert (Calculation id (fromInteger x) (fromInteger y) "Multiplication" answer )
                    json <- returnJson $ Answer (x * y)
                    sendResponseStatus status201 json
                Nothing -> do
                    addHeader "Location" "http://localhost:3000/"
                    sendResponseStatus status301 ()
        Nothing -> do
            addHeader "Location" "http://localhost:3000/"
            sendResponseStatus status301 ()


putUsersDivisionsR :: Integer -> Integer -> Text-> Handler ()
putUsersDivisionsR x y n = do
    maybeName <- lookupSession "username"
    case maybeName of
        Just name -> do
            maybeUser <- runDB $ getBy $ UniqueUsername name
            case maybeUser of
                Just user@(Entity id _) -> do
                    let answer = fromInteger (x `div` y)
                    calcId <- runDB $ insert (Calculation id (fromInteger x) (fromInteger y) "Division" answer )
                    json <- returnJson $ Answer (x `div` y)
                    sendResponseStatus status201 json
                Nothing -> do
                    addHeader "Location" "http://localhost:3000/"
                    sendResponseStatus status301 ()
        Nothing -> do
            addHeader "Location" "http://localhost:3000/"
            sendResponseStatus status301 ()


putUsersAdditionsR :: Integer -> Integer -> Text -> Handler ()
putUsersAdditionsR x y n = do
    maybeName <- lookupSession "username"
    case maybeName of
        Just name -> do
            maybeUser <- runDB $ getBy $ UniqueUsername name
            case maybeUser of
                Just user@(Entity id _) -> do
                    let answer = fromInteger (x + y)
                    calcId <- runDB $ insert (Calculation id (fromInteger x) (fromInteger y) "Addition" answer )
                    json <- returnJson $ Answer (x + y)
                    sendResponseStatus status201 json
                Nothing -> do
                    addHeader "Location" "http://localhost:3000/"
                    sendResponseStatus status301 ()
        Nothing -> do
            addHeader "Location" "http://localhost:3000/"
            sendResponseStatus status301 ()

putUsersSubtractionsR :: Integer -> Integer -> Text->Handler ()
putUsersSubtractionsR x y n = do
    maybeName <- lookupSession "username"
    case maybeName of
        Just name -> do
            maybeUser <- runDB $ getBy $ UniqueUsername name
            case maybeUser of
                Just user@(Entity id _) -> do
                    let answer = fromInteger (x - y)
                    calcId <- runDB $ insert (Calculation id (fromInteger x) (fromInteger y) "Subtraction" answer )
                    json <- returnJson $ Answer (x - y)
                    sendResponseStatus status201 json
                Nothing -> do
                    addHeader "Location" "http://localhost:3000/"
                    sendResponseStatus status301 ()
        Nothing -> do
            addHeader "Location" "http://localhost:3000/"
            sendResponseStatus status301 ()

