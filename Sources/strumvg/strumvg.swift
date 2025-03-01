// The Swift Programming Language
// https://docs.swift.org/swift-book
// 
// Swift Argument Parser
// https://swiftpackageindex.com/apple/swift-argument-parser/documentation

import ArgumentParser
import StrumModels

import Plot
import PlotSVG

@main
struct strumvg: ParsableCommand {
    @Argument(help: "The string representation of a pattern.")
    var patternString: String
    
    let options: Options = .default
    
    mutating func run() throws {
        let pattern = Pattern(rawValue: patternString)
//        print(pattern?.rawValue)
        
        guard let pattern else { return }
        
        let svg = generate(pattern: pattern)
        print(svg.render(indentedBy: .spaces(2)))
    }
}
