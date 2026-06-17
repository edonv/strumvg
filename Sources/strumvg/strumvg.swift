// The Swift Programming Language
// https://docs.swift.org/swift-book
// 
// Swift Argument Parser
// https://swiftpackageindex.com/apple/swift-argument-parser/documentation

import Foundation
import ArgumentParser
import Configuration

import StrumVGConfig
import StrumModels

import Plot
import PlotSVG

@main
struct strumvg: AsyncParsableCommand {
    static let configuration = CommandConfiguration(
        abstract: "A command for generating an SVG of a strumming pattern.",
        discussion: "Any SVG-compatible value can be used for any configuration option.",
        version: "1.3.0"
    )
    
    @OptionGroup(title: "Input/Output Options")
    var inOut: InOutConfiguration
    
    @Argument(
        parsing: .allUnrecognized,
        help: .init(visibility: .private)
    )
    var otherArgs: [String] = []
    
    /// Style configuration created by reading command-line arguments, followed by a specified config file, then falling back on default values.
    ///
    /// Command-line arguments for styling are read from ``otherArgs``.
    var style: StyleConfiguration!
    
    mutating func validate() throws {
        // add an extra arg to the start because `CommandLineArgumentsProvider`
        // drops the first arg automatically (it assumes its the program name)
        otherArgs.insert("", at: 0)
    }
    
    private mutating func initStyle() async throws -> StyleConfiguration {
        var jsonProvider: FileProvider<JSONSnapshot>? = nil
        var yamlProvider: FileProvider<YAMLSnapshot>? = nil
        if let configPath = inOut.configFilePath {
            if configPath.hasSuffix(".json") {
                jsonProvider = try await FileProvider<JSONSnapshot>(
                    filePath: .init(configPath),
                    allowMissing: true
                )
            }
            
            if configPath.hasSuffix(".yml")
                || configPath.hasSuffix(".yaml") {
                yamlProvider = try await FileProvider<YAMLSnapshot>(
                    filePath: .init(configPath),
                    allowMissing: true
                )
            }
        }
        
        let providers: [(any ConfigProvider)?] = [
            CommandLineArgumentsProvider(arguments: otherArgs),
            jsonProvider,
            yamlProvider,
        ]
        
        let config = ConfigReader(
            providers: providers
                .compactMap(\.self)
        )
        
        return .init(config: config)
    }
    
    mutating func run() async throws {
        self.style = try await self.initStyle()
        
        let str: String
        
        switch inOut.input.source! {
        case .stdin:
            let stdin = FileHandle.standardInput
            guard let data = try stdin.readToEnd() else {
                print("Failed to read all incoming data from stdin.")
                throw ExitCode(EXIT_FAILURE)
            }
            guard let dataStr = String(data: data, encoding: .utf8) else {
                print("Failed to convert stdin data to UTF-8 string.")
                throw ExitCode(EXIT_FAILURE)
            }
            str = dataStr
            
        case .argument(let pattern):
            str = pattern
        }
        
//        let string = "{xD} D u uD u-16t"
        let pattern = Pattern(rawValue: str)
//        print(pattern?.rawValue)
        
        guard let pattern else {
            throw ValidationError("Invalid pattern string, missing timing/note length component at the end.")
        }
        
        let svg = generate(pattern: pattern)
        let svgStr = svg.render(indentedBy: .spaces(2))
        
        switch inOut.output.destination! {
        case .stdout:
            guard let svgStrData = svgStr.data(using: .utf8) else {
                print("Failed to convert SVG string content to UTF-8 data.")
                throw ExitCode(EXIT_FAILURE)
            }
            
            let stdout = FileHandle.standardOutput
            try stdout.write(contentsOf: svgStrData)
            
        case .log:
            print(svgStr)
            
        case .file(let path):
            let outputURL = URL(filePath: path, directoryHint: .notDirectory)
            try svgStr.write(to: outputURL, atomically: true, encoding: .utf8)
        }
    }
}
