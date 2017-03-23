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

module Handler.User where

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
  maybeName <- lookupSession "username"
  case maybeName of
   Just name -> do
     setSession "username" name
     html <- homeUserLayout name
     sendResponseStatus status201 html
   Nothing -> do
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
                                    setSession "username" name
                                    html <- homeUserLayout name
                                    sendResponseStatus status201 html
                _ -> do
                     addHeader "WWW-Authenticate" "Basic realm=\"users\""
                     sendResponseStatus status401 ()



homeUserLayout :: Text -> Handler Html
homeUserLayout name = defaultLayout $ do

                  setTitle "Sign Up"
                  addStylesheetRemote "https://maxcdn.bootstrapcdn.com/bootstrap/3.3.7/css/bootstrap.min.css"
                  addScriptRemote "https://ajax.googleapis.com/ajax/libs/jquery/3.1.1/jquery.min.js"
                  addScriptRemote "https://maxcdn.bootstrapcdn.com/bootstrap/3.3.7/js/bootstrap.min.js"
                  addScriptRemote "https://cdnjs.cloudflare.com/ajax/libs/jquery-form-validator/2.3.26/jquery.form-validator.min.js"
                  addScript $ StaticR main_js
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
                                                         <a href="#">History
                                                      <li class="divider">
                                                      <li>
                                                         <a href="/">Logout

                                        <div class="container-fluid">
                                          <div class="row" style="padding-top: 100px; padding-bottom: 50px; background-color: #dddddd">
                                              <div class="col-md-12">
                                                  <form class="form-horizontal" id="calculator-user">
                                                      <fieldset>
                                                          <div class="form-group" style="min-height: 80px;margin-bottom: 0">
                                                              <h4 class=" col-md-4 text-right">
                                                                  <label class="control-label" for="operations">Integer 1
                                                              <div class="col-md-4">
                                                                  <input id="first-operand"
                                                                         name="first-operand"
                                                                         type="text"
                                                                         placeholder="Enter first integer"
                                                                         class="form-control input-lg"
                                                                         maxlength="50"
                                                                         data-validation="custom"
                                                                         data-validation-regexp="^-?[0-9]+$"
                                                                         data-validation-error-msg="You must enter integer"
                                                                         required="">

                                                          <div class="form-group" style="min-height: 80px;margin-bottom: 0">
                                                              <h4 class=" col-md-4 text-right">
                                                                  <label class="control-label" for="operations">Integer 2
                                                              <div class="col-md-4">
                                                                  <input id="second-operand"
                                                                         name="second-operand"
                                                                         type="text"
                                                                         placeholder="Enter second integer"
                                                                         class="form-control input-lg"
                                                                         maxlength="50"
                                                                         data-validation="custom"
                                                                         data-validation-regexp="^-?[0-9]+$"
                                                                         data-validation-error-msg="You must enter integer"
                                                                         required="">

                                                          <div class="form-group" style="min-height: 80px;margin-bottom: 0">
                                                              <h4 class=" col-md-4 text-right">
                                                                  <label class="control-label" for="operations">Operation

                                                              <div class="col-md-4">
                                                                  <select id="operations" name="operations" class="form-control input-lg">
                                                                      <option value="add">Add
                                                                      <option value="subtract">Subtract
                                                                      <option value="multiply">Multiply
                                                                      <option value="divide">Divide
                                                          <div class="form-group">
                                                              <label class="col-md-4 control-label" for="calculate">

                                                              <div class="btn-group col-md-4">
                                                                  <button id="save" style="border: 0;min-width: 100px" name="save" value="/#{name}"
                                                                           class="btn-lg btn-primary">Calculate & Save

                                                          <div class="form-group">
                                                              <div class="col-md-4" id="save-success">

                                          <div class="row" style="padding-top: 100px; padding-bottom: 250px; background-color: #454545">
                                              <div class="col-md-12 text-center" style="color: #fff">
                                                  <h1 style="font-size: 70px">
                                                      <strong id="answer">&nbsp;

                                        <div class="container-fluid">
                                          <div class="row">
                                              <div class="col-md-12 text-center" style="background-color: #252525; color: #949494; padding: 20px 0">
                                                  <small>© 2017 DAINIUS GRINCIUKAS. ALL RIGHTS RESERVED.|]
