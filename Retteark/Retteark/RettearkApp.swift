//
//  RettearkApp.swift
//  Retteark
//
//  Created by Stein Angel Braseth on 08/07/2022.
//

import SwiftUI
import SQLiteData
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
                    "låstKarakter" INTEGER,
                    "karakter" TEXT,
                    "framovermelding" TEXT 
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
                    "deltakerId" TEXT NOT NULL REFERENCES "Deltakere" ("id") ON DELETE CASCADE ON UPDATE NO ACTION,
                    "poeng" TEXT
                ) STRICT
              """
            )
            .execute(db)
            try #sql(
              """
                CREATE TABLE Kategorier (
                    id TEXT PRIMARY KEY,
                    navn TEXT,
                    proveId TEXT NOT NULL REFERENCES Prover (id) ON DELETE CASCADE ON UPDATE NO ACTION
                ) STRICT
              """
            ).execute(db)
            try #sql(
              """
                CREATE TABLE OppgaverKategorier (
                    id TEXT PRIMARY KEY,
                    KategoriId TEXT NOT NULL REFERENCES Kategorier (id) ON DELETE CASCADE ON UPDATE NO ACTION,
                    OppgaveId TEXT NOT NULL REFERENCES Oppgaver (id) ON DELETE CASCADE ON UPDATE NO ACTION
                ) STRICT
              """
            ).execute(db)
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
                    ('oppgave1', '1', 'prove1', 10.0, NULL),
                    ('oppgave2', '2', 'prove1', 5.0, NULL),
                    ('oppgave3', '1a', 'prove2', 15.0, NULL),
                    ('oppgave4', '1b', 'prove2', 20.0, NULL),
                    ('oppgave5', '1', 'prove3', 25.0, NULL),
                    ('oppgave6', '2', 'prove3', 30.0, NULL)
                """
            ).execute(db)
            try #sql (
                """
                    INSERT INTO Poenger (id, oppgaveId, deltakerId, poeng) VALUES
                    ('poeng1', 'oppgave1', 'deltaker1', '8'),
                    ('poeng2', 'oppgave2', 'deltaker1', '4'),
                    ('poeng3', 'oppgave1', 'deltaker2', '9'),
                    ('poeng4', 'oppgave2', 'deltaker2', '5'),
                    ('poeng5', 'oppgave3', 'deltaker3', '12'),
                    ('poeng6', 'oppgave4', 'deltaker3', '18'),
                    ('poeng7', 'oppgave3', 'deltaker4', '14'),
                    ('poeng8', 'oppgave4', 'deltaker4', '20'),
                    ('poeng9', 'oppgave5', 'deltaker5', '20'),
                    ('poeng10', 'oppgave6', 'deltaker5', '25')
                """
            ).execute(db)
            try #sql (
                """
                    INSERT INTO Deltakere (id, navn, proveId, låstKarakter, karakter, framovermelding) VALUES
                    ('deltaker1', 'Ola Nordmann', 'prove1', 0, '', ''),
                    ('deltaker2', 'Kari Nordmann', 'prove1', 0, '', ''),
                    ('deltaker3', 'Ola Nordmann', 'prove2', 0, '', ''),
                    ('deltaker4', 'Kari Nordmann', 'prove2', 0, '', ''),
                    ('deltaker5', 'Per Hansen', 'prove3', 0, '', '')
                """
            ).execute(db)
            try #sql (
                """
                    INSERT INTO Kategorier (id, navn, proveId) VALUES
                    ('kategori1', 'linære funksjoner', 'prove1'),
                    ('kategori2', 'ekponensialfunksjoner', 'prove1'),
                    ('kategori3', 'andregradsfunksjoner', 'prove1')
                """
            ).execute(db)
            try #sql (
                """
                    INSERT INTO OppgaverKategorier (id, KategoriId, OppgaveId) VALUES
                    ('1', 'kategori1', 'oppgave1'),
                    ('2', 'kategori2', 'oppgave1'),
                    ('3', 'kategori3', 'oppgave1'),
                    ('4', 'kategori1', 'oppgave2'),
                    ('5', 'kategori2', 'oppgave2'),
                    ('6', 'kategori3', 'oppgave2')
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
struct Klasser: Codable, Identifiable {
    var id: String
    var navn: String
    var skoleår: String
}

@Table("Elever")
struct Elever: Codable, Identifiable {
    var id: String
    var navn: String
    var klasseId: String?
}

@Table("Prover")
struct Prover: Codable, Identifiable {
    var id: String
    var navn: String
    var visEleverKarakter: Bool
    var klasseId: String
}

@Table("Oppgaver")
struct Oppgaver: Codable, Identifiable, Equatable {
    var id: String
    var navn: String
    var proveId: String
    var maksPoeng: Double?
    var gammelMaksPoeng: Double?
}

@Table("Deltakere")
struct Deltakere: Codable, Identifiable, Equatable {
    var id: String
    var navn: String
    var proveId: String
    var låstKarakter: Bool
    var karakter: String
    var framovermelding: String
}

@Table("Poenger")
struct Poenger: Codable, Identifiable {
    var oppgaveId: String
    var deltakerId: String
    var poeng: String
    var id: String
}
@Table("Kategorier")
struct Kategorier: Codable, Identifiable, Equatable {
    var id: String
    var navn: String
    var proveId: String
}

@Table("OppgaverKategorier")
struct OppgaverKategorier: Codable, Identifiable {
    var id: String
    var KategoriId: String
    var OppgaveId: String
}


