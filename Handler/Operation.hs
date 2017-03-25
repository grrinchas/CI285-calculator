{-# LANGUAGE OverloadedStrings #-}

module Handler.Operation where

import Yesod.Core
import Data.Aeson
import Foundation

data Answer = Answer { result :: Integer} deriving Show

instance ToJSON Answer where
    toJSON (Answer result) = object ["result" .= result]

getMultiplicationsR :: Integer -> Integer -> Handler Value
getMultiplicationsR x y = operationJson $ x * y

getDivisionsR :: Integer -> Integer -> Handler Value
getDivisionsR x y = operationJson $ div x y

getAdditionsR :: Integer -> Integer -> Handler Value
getAdditionsR x y = operationJson $ x + y

getSubtractionsR :: Integer -> Integer -> Handler Value
getSubtractionsR x y = operationJson $ x - y


operationJson :: Integer -> Handler Value
operationJson a = returnJson $ Answer a