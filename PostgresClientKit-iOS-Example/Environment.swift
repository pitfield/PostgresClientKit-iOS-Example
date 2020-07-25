//
//  Environment.swift
//  PostgresClientKit-iOS-Example
//
//  Copyright 2019 David Pitfield and the PostgresClientKit contributors
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

import Foundation
import PostgresClientKit

// Describes a Postgres server endpoint.
struct Environment: Codable {
    
    let host: String
    let port: Int
    let ssl: Bool
    let database: String
    
    /// The Postgres server endpoint specified in Environment.json.
    static var current: Environment = {
        
        guard let url = Bundle.main.url(forResource: "Environment", withExtension: "json") else {
            fatalError("Environment.json not found")
        }
        
        let environment: Environment
        
        do {
            let data = try Data(contentsOf: url)
            environment = try JSONDecoder().decode(Environment.self, from: data)
        } catch {
            fatalError("Error reading Environment.json: \(error)")
        }
        
        Postgres.logger.info("Environment: \(environment)")
        
        return environment
    }()
}

// EOF
