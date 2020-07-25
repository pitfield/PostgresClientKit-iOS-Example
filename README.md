# PostgresClientKit-iOS-Example

Demonstrates use of [PostgresClientKit](https://github.com/codewinsdotcom/PostgresClientKit) in an iOS app.

This simple iOS app displays historical weather information for a user-specified city.  It uses the `weather` table in the [Postgres tutorial](https://www.postgresql.org/docs/12/tutorial-table.html).

The app is structured as an Xcode project the consumes packages (including PostgresClientKit) from Swift Package Manager.

## Using

First, use `psql` to create the `weather` table and insert a few rows.

```
CREATE TABLE weather (
    city            varchar(80),
    temp_lo         int,           -- low temperature
    temp_hi         int,           -- high temperature
    prcp            real,          -- precipitation
    date            date
);

INSERT INTO weather
    VALUES ('San Francisco', 46, 50, 0.25, '1994-11-27');

INSERT INTO weather (city, temp_lo, temp_hi, prcp, date)
    VALUES ('San Francisco', 43, 57, 0.0, '1994-11-29');
    
INSERT INTO weather (date, city, temp_hi, temp_lo)
    VALUES ('1994-11-29', 'Hayward', 54, 37);
```

Then, open the provided Xcode project.

```bash
open PostgresClientKit-iOS-Example.xcodeproj

```

In Xcode, open the `Environment.json` file and set its properties to values appropriate for your Postgres server:

- `host`
- `port`
- `ssl`
- `database`

In this simple example, the Postgres username and password are hardcoded in `AppDelegate.swift`.  Set these values for your environment.

```swift
let model = Model(environment: Environment.current, user: "bob", password: "welcome1")
```

Choose a simulator and run the app.  You should see historical weather information for San Francisco (assuming the `weather` table contains the sample data from the Postgres tutorial).  Logging appears in the Xcode console.  Try changing the city to `Hayward` and tapping `Show`.

To run on a physical device, select the `PostgresClientKit-iOS-Example` project in the project navigator, then select the `PostgresClientKit-iOS-Example` target in the editor, and set the development team to use for code signing.

## Implementation notes

`Model.swift` encapsulates the interaction with the Postgres server.

A connection pool is created containing, at most, one connection.  Although this application doesn't need more than one connection, using a connection pool provides several benefits:

- It creates the connection lazily.
- It automatically re-creates the connection if an unrecoverable connection error occurs.
- It performs database operations on a background thread

If the app moves to the background, the connection pool is closed and re-created (see `sceneDidEnterBackground(_:)` in `SceneDelegate`).  If the app later re-enters the foreground, the new connection pool will lazily create a new connection.