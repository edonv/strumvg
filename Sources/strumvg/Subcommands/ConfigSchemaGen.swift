//
//  ConfigSchemaGen.swift
//  strumvg
//
//  Created by Edon Valdman on 9/18/26.
//

import Foundation
import System
import ArgumentParser

import StrumVGConfig

struct ConfigSchemaGen: ParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "config-schema",
        abstract: "Outputs the JSON schema for a strumvg config file."
    )
    
    @Option(
        name: [.customShort("o"), .customLong("output")],
        help: .init(
            "Path to a directory to output the schema file.",
            discussion: "If the directory does not exist, it will be created."
        ),
        completion: .directory
    )
    var outputDirectory: String
    var outputDirectoryPath: FilePath {
        .init(outputDirectory)
    }
    
    func run() throws {
        
    }
}
