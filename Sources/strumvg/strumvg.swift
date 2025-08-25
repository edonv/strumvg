// The Swift Programming Language
// https://docs.swift.org/swift-book
// 
// Swift Argument Parser
// https://swiftpackageindex.com/apple/swift-argument-parser/documentation

import Foundation
import ArgumentParser
import StrumModels

import Plot
import PlotSVG

@main
struct strumvg: ParsableCommand {
    static let configuration = CommandConfiguration(
        abstract: "A command for generating an SVG of a strumming pattern.",
        discussion: "Any SVG-compatible value can be used for any configuration option.",
        version: "1.1.0"
    )
    
    @OptionGroup(title: "Input/Output Options")
    var inOut: InOutConfiguration
    
    /// Style configuration specified by inline command arguments.
    @OptionGroup(title: "Styling Options")
    private var styleArgs: StyleConfiguration.Args
    
    /// Style configuration created by mapping `styleArgs` to ``StyleConfiguration``, merging with values from a file specified at ``InOutConfiguration/configFilePath`` and falling back on ``StyleConfiguration/default`` values.
    var style: StyleConfiguration!
    
    mutating func validate() throws {
        if inOut.inputSource == .argument
            && inOut.patternString == nil {
            throw ValidationError("`inputSource` flag set to `--arg` and `patternString` argument is missing.")
        }
        
        if inOut.inputSource == .stdin
            && inOut.patternString != nil {
            throw ValidationError("`inputSource` flag set to `--stdin` and `patternString` argument is present.")
        }
        
        self.style = try self.styleArgs
            .merging(withFileAt: inOut.configFilePath)
    }
    
    mutating func run() throws {
        let str: String
        
        switch inOut.inputSource {
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
            
        case .argument:
            guard let patternString = inOut.patternString else {
                throw ValidationError("`inputSource` flag set to `--arg` and the `patternString` argument is missing.")
            }
            
            str = patternString
        }
        
//        let string = "{xD} D u uD u-16t"
        let pattern = Pattern(rawValue: str)
//        print(pattern?.rawValue)
        
        guard let pattern else { return }
        
        let svg = generate(pattern: pattern)
        let svgStr = svg.render(indentedBy: .spaces(2))
        
        switch inOut.outputDestination {
        case .stdout:
            guard let svgStrData = svgStr.data(using: .utf8) else {
                print("Failed to convert SVG string content to UTF-8 data.")
                throw ExitCode(EXIT_FAILURE)
            }
            
            let stdout = FileHandle.standardOutput
            try stdout.write(contentsOf: svgStrData)
            
        case .log:
            print(svgStr)
        }
    }
}
