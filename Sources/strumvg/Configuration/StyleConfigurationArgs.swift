//
//  StyleConfigurationArgs.swift
//  strumvg
//
//  Created by Edon Valdman on 2/25/25.
//

import Foundation
import ArgumentParser

extension StyleConfiguration {
    struct Args: ParsableArguments {
        @OptionGroup(title: "Colors")
        var colors: Colors
        
        struct Colors: ParsableArguments {
            @Option(
                name: .customLong("arrow-color"),
                help: "The color of the arrows."
            )
            var arrows: String?
            
            @Option(
                name: .customLong("rhythm-color"),
                help: "The color of the rhythm text and stems below the arrows."
            )
            var rhythms: String?
            
            @Option(
                name: .customLong("header-color"),
                help: "The color of the articulations and header text above the arrows."
            )
            var headers: String?
        }
        
        @OptionGroup(title: "Text Sizes")
        var textSizes: TextSizes
        
        struct TextSizes: ParsableArguments {
            @Option(
                help: "The height of the space reserved for rhythm text below the arrows."
            )
            var beatTextHeight: CGFloat?
            
            @Option(
                help: "The actual font-size of the rhythm text below the arrows, relative to its height."
            )
            var beatFontSize: CGFloat?
            
            @Option(
                help: "The height of the space reserved for articulations and header text above the arrows."
            )
            var headerTextHeight: CGFloat?
            
            @Option(
                help: "The actual font-size of the articulations and header text above the arrows, relative to its height."
            )
            var headerFontSize: CGFloat?
            
            @Option(
                name: .customLong("triplet-font-size"),
                help: "The actual font-size of the triplet label, if applicable."
            )
            var tripletFontSize: CGFloat?
        }
        
        @OptionGroup(title: "Strum Sizes")
        var strumSizes: StrumSizes
        
        struct StrumSizes: ParsableArguments {
            @Option(
                name: .customLong("strum-width"),
                help: .init(
                    "The width of each strum arrow.",
                    discussion: "This is also the width of the space reserved for each \"rhythmic column\" composed of arrow, header text, and beat text."
                )
            )
            var width: CGFloat?
            
            @Option(
                name: .customLong("strum-height"),
                help: "The height of each strum arrow."
            )
            var height: CGFloat?
            
            @Option(
                name: .customLong("strum-gap"),
                help: "The horizontal space between each strum "
            )
            var gap: CGFloat?
        }
        
        @OptionGroup(title: "Beam Sizes")
        var beamSizes: BeamSizes
        
        struct BeamSizes: ParsableArguments {
            @Option(
                name: .customLong("beam-stroke-width"),
                help: "The stroke width of the rhythm stems/beams below the arrows."
            )
            var strokeWidth: CGFloat?
            
            @Option(
                name: .customLong("beam-steam-height"),
                help: "The vertical length of the beam stems."
            )
            var stemHeight: CGFloat?
        }
        
        func merging(withFileAt path: String?) throws -> StyleConfiguration {
            // if there's a file path, load the file
            if let path {
                let configFileURL = URL(filePath: path)
                let configFileStr = try String(contentsOf: configFileURL, encoding: .utf8)
                    // Remove commented-out lines
                    .replacing(
                        /\s*\/\/.*$/.anchorsMatchLineEndings(),
                        with: ""
                    )
                
                if let configFileData = configFileStr.data(using: .utf8) {
                    let decoder = JSONDecoder()
                    
                    let configFromFile = try decoder.decode(StyleConfiguration.self, from: configFileData)
                        // and it should only be included if it's specified in the file
                        // but not the command line options (CLI options take priority)
                        .overlaying(with: self)
                    
                    return configFromFile
                }
            }
            
            return .init(args: self)
        }
    }
}
