
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
import Data.Text hiding (split, drop, map)

import Database.Persist
import Database.Persist.TH
import Database.Persist.Sqlite
import Database.Persist.Sql
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


getHistoryR :: Handler ()
getHistoryR = do
    maybeName <- lookupSession "username"
    case maybeName of
        Just name -> do
            maybeUser <- runDB $ getBy $ UniqueUsername name
            case maybeUser of
                Just (Entity id _) -> do
                    calculations <- runDB $ selectList [CalculationUserId ==. id] []
                    layout <- historyLayout calculations name
                    sendResponseStatus status200 layout
        Nothing -> do
            addHeader "Location" "http://localhost:3000/"
            sendResponseStatus status301 ()


getCalculations :: Entity Calculation -> Calculation
getCalculations (Entity _ x) = x


historyLayout :: [Entity Calculation] -> Text-> Handler Html
historyLayout calculations name= defaultLayout $ do
    setTitle "History"
    addStylesheetRemote "https://maxcdn.bootstrapcdn.com/bootstrap/3.3.7/css/bootstrap.min.css"
    addScriptRemote "https://ajax.googleapis.com/ajax/libs/jquery/3.1.1/jquery.min.js"
    addScriptRemote "https://maxcdn.bootstrapcdn.com/bootstrap/3.3.7/js/bootstrap.min.js"
    addScriptRemote "https://cdnjs.cloudflare.com/ajax/libs/jquery-form-validator/2.3.26/jquery.form-validator.min.js"
    toWidget [whamlet|$doctype 5
<html>
 <body>
  <div class="container-fluid" style="background-color: #454545">
    <div class="row" style="display: flex; align-items: center">
        <div class="col-md-6">
            <h2 style="color: #fff">
                <a style="text-decoration: none;color: #fff;" href="/">
                    <strong>CI285 Calculator v1.0
        <div class="col-md-6 text-right">
            <span style="color: #fff">#{name}
            <button type="button" class="btn dropdown-toggle width: 20px; height: 20px" style="color: white;" data-toggle="dropdown">
                <span class="glyphicon glyphicon-user" style="color: #454545;font-size: 20px" aria-hidden="true">
            <ul class="dropdown-menu pull-right" role="menu">
                <li>
                   <a href="/history">History
                <li class="divider">
                <li>
                   <a id="logout" href="/logout">Logout

  <div class="container" style="=background-color: #ddd">
    <div class="row" style="padding-top: 100px; padding-bottom: 50px">
        <h2>Calculation history
        <table class="table table-bordered">
            <thead>
            <tr class="danger">
                <th>ID
                <th>Number 1
                <th>Number 2
                <th>Operation
                <th>Answer
            <tbody>
                $forall Entity (CalculationKey (SqlBackendKey id)) (Calculation _ op1 op2 op res) <- calculations
                  <tr>
                    <td>#{show id}
                    <td>#{show op1}
                    <td>#{show op2}
                    <td>#{show op}
                    <td>#{show res}
  <div class="container-fluid">
    <div class="row">
         <div class="col-md-12 text-center" style="background-color: #252525; color: #949494; padding: 20px 0">
             <small>© 2017 DAINIUS GRINCIUKAS. ALL RIGHTS RESERVED.|]
