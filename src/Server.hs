{-# LANGUAGE OverloadedStrings     #-}
{-# LANGUAGE QuasiQuotes           #-}
{-# LANGUAGE TemplateHaskell       #-}
{-# LANGUAGE TypeFamilies          #-}
{-# LANGUAGE ViewPatterns          #-}

module Server where

import Yesod
import Data.Aeson

data Answer = Answer { result :: String} deriving Show

instance ToJSON Answer where
    toJSON (Answer result) = object ["result" .= result]


data App = App

instance Yesod App

mkYesod "App" [parseRoutes|
/multiplications/#Integer/#Integer MultiplicationsR GET
/divisions/#Integer/#Integer DivisionsR GET
/additions/#Integer/#Integer AdditionsR GET
/subtractions/#Integer/#Integer SubtractionsR GET
|]

getMultiplicationsR :: Integer -> Integer -> Handler Value
getMultiplicationsR x y = returnJson $ Answer (show $ x * y)

getDivisionsR :: Integer -> Integer -> Handler Value
getDivisionsR x y = returnJson $ Answer (show $ (fromIntegral x) / (fromIntegral y))

getAdditionsR :: Integer -> Integer -> Handler Value
getAdditionsR x y = returnJson $ Answer (show $ x + y)

getSubtractionsR :: Integer -> Integer -> Handler Value
getSubtractionsR x y = returnJson $ Answer (show $ x - y)

main :: IO ()
main = warp 3000 App
