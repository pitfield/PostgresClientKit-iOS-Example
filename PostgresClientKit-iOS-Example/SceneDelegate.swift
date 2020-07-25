//
//  SceneDelegate.swift
//  PostgresClientKit-iOS-Example
//
//  Copyright 2020 David Pitfield and the PostgresClientKit contributors
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

import PostgresClientKit
import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(_ scene: UIScene,
               willConnectTo session: UISceneSession,
               options connectionOptions: UIScene.ConnectionOptions) {
        
        // Set the log level to .fine.  That's too verbose for production, but nice for this example.
        Postgres.logger.level = .fine
        
        // Inject the model into the view controller.
        if let viewController = window?.rootViewController as? ViewController,
            let appDelegate = UIApplication.shared.delegate as? AppDelegate {
            viewController.model = appDelegate.model
        }
    }
    
    func sceneDidEnterBackground(_ scene: UIScene) {
        
        // Close any existing connection to the Postgres server.
        if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
            appDelegate.model.disconnect()
        }
    }
}

// EOF
