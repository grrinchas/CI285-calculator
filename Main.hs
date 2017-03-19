{-# LANGUAGE OverloadedStrings          #-}

module Main where

import Application
import Foundation
import Yesod
import Yesod.Static

import Control.Monad.Trans.Resource (runResourceT)
import Control.Monad.Logger (runStderrLoggingT)
import Database.Persist.Sqlite

main :: IO ()
main = runStderrLoggingT $ withSqlitePool "db/calc.db" 10 $ \pool -> liftIO $ do
    runResourceT $ flip runSqlPool pool $ do runMigration migrateAll
    static@(Static settings) <- static "static"
    warp 3000 $ App pool static