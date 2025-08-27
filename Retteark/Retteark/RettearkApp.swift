//
//  RettearkApp.swift
//  Retteark
//
//  Created by Stein Angel Braseth on 08/07/2022.
//

import SwiftUI
import SharingGRDB
import OSLog
private let logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "RettearkApp", category: "Database")

@main
struct RettearkApp: App {
    init() {
        prepareDependencies {
            $0.defaultDatabase = appDatabase()
        }
    }
    var body: some Scene {
        WindowGroup {
            klasseVisning()
                .environment(Klasseoversikt())
        }
    }
    
    func appDatabase() -> any DatabaseWriter {
        var config = Configuration()
        config.foreignKeysEnabled = true
        
        #if DEBUG
            config.prepareDatabase { db in
                db.trace(options: .profile) {
                    logger.debug("\($0.expandedDescription)")
                }
            }
        #endif
        var database: any DatabaseWriter
        let path = URL.documentsDirectory.appending(component: "Retteark.sqlite").path()
        logger.info(("open database at \( path )"))
        do {
            database = try DatabasePool(path: path, configuration: config)
        }
        catch {
            logger.error("Failed to open database: \(error)")
            fatalError("Failed to open database: \(error)")
        }
        
        var migrator = DatabaseMigrator()
          #if DEBUG
            migrator.eraseDatabaseOnSchemaChange = true
          #endif
        migrator.registerMigration("Create tables") { db in
            try #sql(
              """
              CREATE TABLE "Klasser" (
                  "id" TEXT PRIMARY KEY,
                  "navn" TEXT,
                  "skoleår" TEXT
              ) STRICT
              """
            )
            .execute(db)
            try #sql(
              """
               CREATE TABLE "Elever" (
                   "id" TEXT PRIMARY KEY,
                   "navn" TEXT,
                   "klasseId" TEXT NOT NULL REFERENCES "Klasser" ("id") ON DELETE CASCADE ON UPDATE NO ACTION  
              ) STRICT
              """
            )
            .execute(db)
            try #sql(
              """
              CREATE TABLE "Prover" (
                  "id" TEXT PRIMARY KEY,
                  "navn" TEXT,
                  "visEleverKarakter" INTEGER,
                  "klasseId" TEXT NOT NULL REFERENCES "Klasser" ("id") ON DELETE CASCADE ON UPDATE NO ACTION
              ) STRICT
              """
            )
            .execute(db)
            try #sql(
              """
               CREATE TABLE "Deltakere" (
                   "id" TEXT PRIMARY KEY,
                   "navn" TEXT,
                   "proveId" TEXT NOT NULL REFERENCES "Prover" ("id") ON DELETE CASCADE ON UPDATE NO ACTION,
                   "låstKarakter" INTEGER
              ) STRICT
              """
            )
            .execute(db)
            try #sql(
              """
               CREATE TABLE "ElevProve" (
                   "elevId" TEXT NOT NULL REFERENCES "Elever" ("id") ON DELETE CASCADE ON UPDATE NO ACTION,
                   "proveId" TEXT NOT NULL REFERENCES "Prover" ("id") ON DELETE CASCADE ON UPDATE NO ACTION,
                   "karakter" TEXT,
                   "låstKarakter" INTEGER,
                    PRIMARY KEY ("elevId", "proveId")
               ) STRICT
              """
            )
            .execute(db)
            try #sql(
              """
               CREATE TABLE "Oppgaver" (
                   "id" TEXT PRIMARY KEY,
                   "navn" TEXT,
                   "proveId" TEXT NOT NULL REFERENCES "Prover" ("id") ON DELETE CASCADE ON UPDATE NO ACTION,
                   "maksPoeng" REAL,
                   "gammelMaksPoeng" REAL
               ) STRICT
              """
            )
            .execute(db)
            try #sql(
              """
                CREATE TABLE "Poenger" (
                    "id" TEXT PRIMARY KEY,
                    "oppgaveId" TEXT NOT NULL REFERENCES "Oppgaver" ("id") ON DELETE CASCADE ON UPDATE NO ACTION,
                    "deltakerId" TEXT NOT NULL REFERENCES "Deltaker" ("id") ON DELETE CASCADE ON UPDATE NO ACTION,
                    "poeng" TEXT
                ) STRICT
              """
            )
            .execute(db)
          }
        
        migrator.registerMigration("Populate with test data") { db in
            @Dependency(\.date.now) var now
            try #sql (
                """
                    INSERT INTO Elever (id, navn, klasseId) VALUES
                    ('elev1', 'Ola Nordmann', 'klasse1'),
                    ('elev2', 'Kari Nordmann', 'klasse1'),
                    ('elev3', 'Per Hansen', 'klasse2')
                """
            )
            .execute(db)
            try #sql (
                """
                    INSERT INTO Klasser (id, navn, skoleår) VALUES
                    ('klasse1', '1A', '2023/2024'),
                    ('klasse2', '2B', '2023/2024')
                """
            )
            .execute(db)
            try #sql (
                """
                    INSERT INTO Prover (id, navn, visEleverKarakter, klasseId) VALUES
                    ('prove1', 'Matematikkprøve', 1, 'klasse1'),
                    ('prove2', 'Norskprøve', 0, 'klasse1'),
                    ('prove3', 'Naturfagprøve', 1, 'klasse2')
                """
            ).execute(db)
            try #sql (
                """
                    INSERT INTO Oppgaver (id, navn, proveId, maksPoeng, gammelMaksPoeng) VALUES
                    ('oppgave1', 'Addisjon', 'prove1', 10.0, NULL),
                    ('oppgave2', 'Subtraksjon', 'prove1', 5.0, NULL),
                    ('oppgave3', 'Multiplikasjon', 'prove2', 15.0, NULL),
                    ('oppgave4', 'Divisjon', 'prove2', 20.0, NULL),
                    ('oppgave5', 'Kjemi', 'prove3', 25.0, NULL),
                    ('oppgave6', 'Biologi', 'prove3', 30.0, NULL)
                """
            ).execute(db)
        }
        do {
            try migrator.migrate(database)
        }
        catch {
            logger.error("Failed to migrate database: \(error)")
            fatalError("Failed to migrate database: \(error)")
        }
        return database
    }
}

@Table("Klasser")
struct Klasser:FetchableRecord, Codable, Identifiable {
    var id: String
    var navn: String
    var skoleår: String
}

@Table("Elever")
struct Elever: FetchableRecord, Codable, Identifiable {
    var id: String
    var navn: String
    var klasseId: String?
}

@Table("Prover")
struct Prover:FetchableRecord, Codable, Identifiable {
    var id: String
    var navn: String
    var visEleverKarakter: Bool
    var klasseId: String
}

@Table("Oppgaver")
struct Oppgaver:FetchableRecord, Codable, Identifiable {
    var id: String
    var navn: String
    var proveId: String
    var maksPoeng: Double?
    var gammelMaksPoeng: Double?
}

@Table("Deltakere")
struct Deltakere: FetchableRecord, Codable, Identifiable {
    var id: String
    var navn: String
    var proveId: String
    var låstKarakter: Bool?
}

@Table("Poenger")
struct Poenger: FetchableRecord, Codable, Identifiable, TableRecord {
    var oppgaveId: String
    var deltakerId: String
    var poeng: String
    var id: String {
        return "\(oppgaveId)-\(deltakerId)"
    }
}
