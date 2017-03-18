{-# LANGUAGE OverloadedStrings    #-}
{-# LANGUAGE TemplateHaskell      #-}
{-# LANGUAGE ViewPatterns         #-}

module Application where

import Yesod.Core
import Foundation

import Handler.Operation
import Handler.Home
import Handler.Signup

mkYesodDispatch "App" resourcesApp
