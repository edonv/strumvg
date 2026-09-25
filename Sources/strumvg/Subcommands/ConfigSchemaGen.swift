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
    private var outputDirectoryPath: FilePath {
        .init(outputDirectory)
    }
    private var outputFilePath: FilePath {
        outputDirectoryPath
            .appending("strumvg.schema.json")
    }
    
    func run() throws {
        if !FileManager.default.fileExists(atPath: outputDirectoryPath.string) {
            try FileManager.default.createDirectory(
                atPath: outputDirectoryPath.string,
                withIntermediateDirectories: true
            )
        }
        
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .withoutEscapingSlashes]
        
        let schema = StyleConfiguration.schema
            .schema("https://json-schema.org/draft/2020-12/schema")
            .definition()
        
        let schemaJSONString = try schema.jsonValue.serialized(options: .init(prettyPrinted: true, indent: "  "))
            .replacing(/(?:``)(?:StyleConfiguration\/)?(?<symbol>[^`]+)(?:``)/) { match in
                let normalizedSymbolPath = match.output.symbol
                    .replacingOccurrences(of: "/", with: ".")
                return "`\(normalizedSymbolPath)`"
            }
            .replacingOccurrences(of: "`StrumSizes.", with: "`strumSizes.")
            .replacing(/"(?<key>[^"]+)" :(?= )/) { "\"\($0.output.key)\":" }
            // Remove all "required"
            .replacing(
                /,?\n^ +"required": \[[\s"\w,]+\]/.anchorsMatchLineEndings(),
                with: ""
            )
        
        try schemaJSONString.write(
            toFile: outputDirectoryPath.string,
            atomically: true,
            encoding: .utf8
        )
    }
}
