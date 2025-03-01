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
        
    }
}
