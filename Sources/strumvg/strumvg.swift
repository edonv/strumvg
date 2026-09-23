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
        abstract: "A tool relating to SVG representations of strumming patterns.",
        version: "3.0.1",
        subcommands: [
            Generate.self,
            ConfigSchemaGen.self,
        ],
        defaultSubcommand: Generate.self
    )
}
