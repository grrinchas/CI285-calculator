{-# LANGUAGE OverloadedStrings    #-}
{-# LANGUAGE TemplateHaskell      #-}
{-# LANGUAGE ViewPatterns         #-}

module Application where

import Yesod.Core
import Foundation

import Handler.Operation
import Handler.Home

mkYesodDispatch "App" resourcesApp
