//
//  Model.swift
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

class Model {
    
    //
    // MARK: Model and connection lifecycle
    //
    
    init(environment: Environment, user: String, password: String) {
        
        // Configure a connection pool with, at most, a single connection.  Using a connection pool
        // allows the connection to be lazily created, automatically re-creates the connection if
        // there is an unrecoverable error, and performs database operations on a background thread.
        var connectionPoolConfiguration = ConnectionPoolConfiguration()
        connectionPoolConfiguration.maximumConnections = 1
        
        // Configure how connections are created in that connection pool.
        var connectionConfiguration = ConnectionConfiguration()
        connectionConfiguration.host = environment.host
        connectionConfiguration.port = environment.port
        connectionConfiguration.ssl = environment.ssl
        connectionConfiguration.database = environment.database
        connectionConfiguration.user = user
        connectionConfiguration.credential = .scramSHA256(password: password)
        
        connectionPool = ConnectionPool(connectionPoolConfiguration: connectionPoolConfiguration,
                                        connectionConfiguration: connectionConfiguration)
    }
    
    /// A pool of (at most) a single connection.
    var connectionPool: ConnectionPool
    
    /// Closes any existing connection to the Postgres server.
    func disconnect() {
        
        // Close the current connection pool
        connectionPool.close()
        
        // And create a new one.  Its connection will be lazily created.
        connectionPool = ConnectionPool(
            connectionPoolConfiguration: connectionPool.connectionPoolConfiguration,
            connectionConfiguration: connectionPool.connectionConfiguration)
    }
    
    
    //
    // MARK: Entities and operations
    //
    
    /// A record of the weather at a particular city on a particular date.
    struct Weather {
        let city: String
        let date: PostgresDate
        let lowTemperature: Int
        let highTemperature: Int
        let precipitation: Double?
    }
    
    /// Gets the weather records for the specified city.
    ///
    /// - Parameters:
    ///   - city: the city
    ///   - completion: a completion handler, invoked with either the weather records or an error.
    func weatherHistoryForCity(_ city: String,
                               completion: @escaping (Result<[Weather], Error>) -> Void) {
        
        connectionPool.withConnection { connectionResult in
            
            let result = Result<[Weather], Error> {
                
                let connection = try connectionResult.get()
                
                let text = "SELECT city, temp_lo, temp_hi, prcp, date FROM weather WHERE city = $1;"
                let statement = try connection.prepareStatement(text: text)
                defer { statement.close() }
                
                let cursor = try statement.execute(parameterValues: [ city ])
                defer { cursor.close() }
                
                var weatherHistory = [Weather]()
                
                for row in cursor {
                    let columns = try row.get().columns
                    let city = try columns[0].string()
                    let tempLo = try columns[1].int()
                    let tempHi = try columns[2].int()
                    let prcp = try columns[3].optionalDouble()
                    let date = try columns[4].date()
                    
                    let weather = Weather(city: city,
                                          date: date,
                                          lowTemperature: tempLo,
                                          highTemperature: tempHi,
                                          precipitation: prcp)
                    
                    weatherHistory.append(weather)
                }
                
                return weatherHistory
            }
            
            DispatchQueue.main.async { // call the completion handler in the main thread
                completion(result)
            }
        }
    }
}

// EOF
