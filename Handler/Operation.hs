{-# LANGUAGE OverloadedStrings #-}

module Handler.Operation where

import Yesod.Core
import Data.Aeson
import Foundation

data Answer = Answer { result :: String} deriving Show

instance ToJSON Answer where
    toJSON (Answer result) = object ["result" .= result]

getMultiplicationsR :: Integer -> Integer -> Handler Value
getMultiplicationsR x y = returnJson $ Answer (show $ x * y)

getDivisionsR :: Integer -> Integer -> Handler Value
getDivisionsR x y = returnJson $ Answer (show $ (fromIntegral x) / (fromIntegral y))

getAdditionsR :: Integer -> Integer -> Handler Value
getAdditionsR x y = returnJson $ Answer (show $ x + y)

getSubtractionsR :: Integer -> Integer -> Handler Value
getSubtractionsR x y = returnJson $ Answer (show $ x - y)