//
//  Generate.swift
//  strumvg
//
//  Created by Edon Valdman on 2/25/25.
//

import Foundation
import StrumModels
import Plot

import PlotSVG
import PlotExtensions

private let numberFormat = FloatingPointFormatStyle<CGFloat>()
    .precision(.fractionLength(...4))
private let FIX_FACTOR: CGFloat = 0.8

extension strumvg {
    private var defsNode: Node<SVG.DocumentContext> {
        .element(
            named: "defs",
            nodes: [
                quarterRestNode(),
                eighthRestNode(),
                sixteenthRestNode(),
            ]
        )
    }
    
    func generate(pattern: Pattern, size: CGSize? = nil) -> SVG {
        let allStrums = pattern.groups
            .flatMap(\.strums)
        
        let strs = createRhythmText(quantity: allStrums.count, noteLength: pattern.timing)
        
        let calcWidth = (config.strumSizes.width + config.strumSizes.gap) * CGFloat(pattern.totalStrums) - config.strumSizes.gap
        let calcHeight = config.strumSizes.height + config.textSizes.headerTextHeight + 2 * config.textSizes.beatTextHeight
        
        // MARK: StrumHeader - P1
        let headers = allStrums
            .enumerated()
            .compactMap { i, strum in
                createStrumHeader(
                    content: strum.headingChar.map(String.init),
                    index: i,
                    rhythmText: false
                )
            }
        
        // MARK: StrumArrow
        let arrows = allStrums
            .enumerated()
            .map { i, strum -> Node<SVG.DocumentContext> in
                let arrow = createStrumArrow(strum: strum, duration: pattern.timing.duration)
                let index = CGFloat(i)
                
                return .element(
                    named: "g",
                    nodes: [
                        .attribute(named: "key", value: "strum\(i)"),
                        .attribute(
                            named: "style",
                            value: "transform-box: fill-box; transform-origin: center;"
                        ),
                        .attribute(
                            named: "transform",
                            value: "translate(\((config.strumSizes.width + config.strumSizes.gap) * index),\(config.textSizes.headerTextHeight))\(strum.direction == .down ? " rotate(180 0 0)" : "")"
                        ),
                        arrow,
                    ].compactMap { $0 }
                )
            }
        
        // MARK: Char StrumHeader
        let charHeaders = strs
            .enumerated()
            .map { i, str in
                return createStrumHeader(
                    content: str,
                    index: i,
                    rhythmText: true
                )
            }
        
        let noteGroupsGroup = createNoteGroups(
            strums: allStrums,
            noteLength: pattern.timing
        )
        
        let svgDeclAttrs: [Attribute<SVG.DeclarationContext>] = [
            size
                .map(\.width)
                .map { .width(.number($0)) },
            size
                .map(\.height)
                .map { .height(.number($0)) },
            .viewBox(
                width: calcWidth,
                height: calcHeight
            ),
            .attribute(named: "overflow", value: "visible")
        ].compactMap { $0 }
        
        let svg = SVG(
            svgAttrs: svgDeclAttrs,
            [
                [defsNode],
                headers,
                arrows,
                charHeaders
                    .compactMap { $0 },
                [noteGroupsGroup],
            ].flatMap { $0 }
        )
        
        return svg
    }
    
    private func createRhythmText(
        quantity: Int,
        noteLength: Timing
    ) -> [String] {
        let triplet = noteLength.triplet
        
        return (0..<quantity).map { int in
            let i = Double(int)
            
            switch noteLength.duration {
            case .quarter:
                if triplet {
                    if int % 3 == 0 {
                        return "\(Int(Double(i / 3 + 1)))"
                    } else {
                        return ""
                    }
                } else {
                    return "\(int + 1)"
                }
                
            case .eighth:
                if triplet {
                    if int % 3 == 0 {
                        return "\(Int(Double(i / 3 + 1)))"
                    } else {
                        return ""
                    }
                } else {
                    if int % 2 == 0 {
                        return "\(Int((Double(i) / 2).rounded() + 1))"
                    } else {
                        return "+"
                    }
                }
                
            case .sixteenth:
                if triplet {
                    if int % 3 == 0 {
                        let v = Int(i / 3 + 1)
                        if v.isMultiple(of: 2) {
                            return "&"
                        } else {
                            return "\(v)"
                        }
                    } else {
                        return ""
                    }
                } else {
                    let odd = int % 2 != 0
                    let halfOdd = Int(i / 2) % 2 != 0
                    if odd {
                        return ""
                    } else if halfOdd {
                        return "+"
                    } else {
                        return "\(Int((Double(i) / 4).rounded() + 1))"
                    }
                }
            }
        }
    }
    
    private func createStrumHeader(
        content: String?,
        index: Int,
        rhythmText: Bool
    ) -> Node<SVG.DocumentContext>? {
        guard let content else { return nil }
        
        let height = rhythmText ? config.textSizes.beatTextHeight : config.textSizes.headerTextHeight
        let width = config.strumSizes.width
        let fill = rhythmText ? config.colors.rhythms : config.colors.headers
        let fontSize = rhythmText ? config.textSizes.beatFontSize : config.textSizes.headerFontSize
        let x = (config.strumSizes.width + config.strumSizes.gap) * CGFloat(index) + config.strumSizes.width / 2
        let yBase = rhythmText ? config.textSizes.headerTextHeight + config.strumSizes.height * FIX_FACTOR : 0
        
        return Node<SVG.DocumentContext>.element(
            named: "text",
            nodes: [
                .text("\(content)"),
                .attribute(named: "key", value: "\(rhythmText ? "count" : "head")\(index)"),
                .attribute(named: "fill", value: fill),
                .attribute(named: "x", value: x, format: numberFormat),
                .attribute(named: "y", value: yBase + height * fontSize, format: numberFormat),
                .attribute(named: "font-size", value: height * fontSize, format: numberFormat),
                .attribute(named: "textLength", value: width, format: numberFormat),
                .attribute(named: "text-anchor", value: "middle"),
                .attribute(named: "font-family", value: "sans-serif"),
                .attribute(named: "font-weight", value: "bold"),
            ]
        )
    }
    
    private func createStrumArrow(
        strum: Strum,
        duration: NoteDuration
    ) -> Node<SVG.DocumentContext>? {
        let variant = strum.variant
        let width = config.strumSizes.width /*?? 50*/
        let height = config.strumSizes.height /*?? 100*/
        let fill = config.colors.arrows
        
        let strokeRatio: CGFloat = 0.2
        let strokeWidth = width * strokeRatio
        let headRatio: CGFloat = 0.2
        let headHeight: CGFloat = height * headRatio
        
        let triangle = { () -> Node<SVG.DocumentContext> in
            .element(
                named: "polygon",
                nodes: [
                    .attribute(
                        named: "points",
                        value: [
                            "0,\(headHeight)",
                            "\(width / 2),0",
                            "\(width),\(headHeight)",
                        ].joined(separator: " ")
                    ),
                    .attribute(named: "stroke-width", value: "0"),
                    .attribute(named: "fill", value: fill),
                ]
            )
        }
        
        switch variant {
        case .normal:
            let line = Node<SVG.DocumentContext>.element(
                named: "line",
                nodes: [
                    .attribute(named: "x1", value: width / 2, format: numberFormat),
                    .attribute(named: "y1", value: headHeight, format: numberFormat),
                    .attribute(named: "x2", value: width / 2, format: numberFormat),
                    .attribute(named: "y2", value: height * (0.5 + headRatio), format: numberFormat),
                    .attribute(named: "stroke-width", value: strokeWidth, format: numberFormat),
                    .attribute(named: "stroke", value: fill),
                ]
            )
            
            return .element(
                named: "g",
                nodes: [line, triangle()]
            )
            
        case .arpeggio:
            let offsetY = headHeight * 0.9
            let numWaves = 6
            let amplitude = 6
            // let offsetX = amplitude * 2;
            let wavelength = height / CGFloat(numWaves) / CGFloat(2)
            
            // Squiggle
            let squigglePath = Node<SVG.DocumentContext>.element(
                named: "path",
                attributes: [
                    .attribute(
                        named: "d",
                        value: "M\(width / 2) , \(offsetY / 2)l0 \(offsetY / 2)" +
                        (0..<numWaves)
                            .map { i in
                                "q\(i % 2 == 0 ? -amplitude : amplitude) \(wavelength / 2) , \(0) \(wavelength)"
                            }
                            .joined(separator: ", ")
                    ),
                    .attribute(
                        named: "stroke-width",
                        value: strokeWidth,
                        format: numberFormat
                    ),
                    .attribute(named: "fill", value: "none"),
                    .attribute(named: "stroke", value: fill /*?? ""*/)
                ]
            )

            return .element(named: "g", nodes: [triangle(), squigglePath])

        case .muted:
            return Node<SVG.DocumentContext>.element(
                named: "path",
                attributes: [
                    .attribute(
                        named: "d",
                        // M 20 0 L 0 20 M 20 20 L 0 0 M 10 56 V 10
                        value: [
                            // move to top right of X
                            "M \(width) 0",
                            // draw to lower left of X
                            "L 0 \(width)",
                            // move to lower right of X
                            "M \(width) \(width)",
                            // draw to top left of X
                            "L 0 0",
                            // move to bottom of line
                            "M \(width / 2) \(height * (headRatio + 0.5))",
                            // draw to top of line
                            "V \(width / 2)",
                        ].joined()
                    ),
                    .attribute(named: "fill", value: "none"),
                    .attribute(named: "stroke", value: config.colors.arrows),
                    .attribute(
                        named: "stroke-width",
                        value: strokeWidth,
                        format: numberFormat
                    ),
                ]
            )
            
        case .space:
            return nil
            
        case .rest:
            let scaleFactor: CGFloat = 2 / 3
            let partialHeight = height * (headRatio + 0.5)
            
            let w = width * scaleFactor
            let h = partialHeight * scaleFactor
            let cx = (width - w) / 2
            let cy = (partialHeight - h) / 2
            
            return Node<SVG.DocumentContext>.element(
                named: "g",
                nodes: [
                    .element(named: "use", nodes: [
                        .attribute(named: "href", value: "#\(duration.restPathReuseID)"),
                        .attribute(named: "width", value: w, format: numberFormat),
                        .attribute(named: "height", value: h, format: numberFormat),
                        .attribute(named: "transform", value: "translate(\(cx) \(cy))"),
                        .attribute(named: "transform-origin", value: "center"),
                        .attribute(named: "fill", value: fill),
                    ]),
                ]
            )
            
        case .other(let char):
            return .element(
                named: "text",
                nodes: [
                    .attribute(
                        named: "x",
                        value: width / 2,
                        format: numberFormat
                    ),
                    .attribute(
                        named: "y",
                        value: height / 2,
                        format: numberFormat
                    ),
                    .attribute(
                        named: "font-size",
                        value: height / 2,
                        format: numberFormat
                    ),
                    .attribute(
                        named: "text-anchor",
                        value: "middle"
                    ),
                    .attribute(
                        named: "font-family",
                        value: "sans-serif"
                    ),
                    .attribute(
                        named: "font-weight",
                        value: "bold"
                    ),
                    .attribute(
                        named: "textLength",
                        value: width,
                        format: numberFormat
                    ),
                    .attribute(
                        named: "lengthAdjust",
                        value: "spacingAndGlyphs"
                    ),
                    .text(String(char)),
                ]
            )
        }
    }
    
    private func createNoteGroups(
        strums: [Strum],
        noteLength: Timing
    ) -> Node<SVG.DocumentContext> {
        let y = config.textSizes.headerTextHeight + config.strumSizes.height * FIX_FACTOR + config.textSizes.beatTextHeight
        
        let triplet = noteLength.triplet
        let horizontalStrokes = noteLength.duration.horizontalStrokeCount
        
        let subdivision = triplet ? 3 : 2
        let quantity = Int(floor(Double(strums.count) / Double(subdivision)))
        
        return .element(
            named: "g",
            nodes: (0..<quantity).map { i in
                return createNoteGroup(
                    quantity: subdivision,
                    triplet: triplet,
                    horizontalStrokes: horizontalStrokes,
                    x: CGFloat(subdivision) * (config.strumSizes.width + config.strumSizes.gap) * CGFloat(i) + config.strumSizes.width / 2,
                    y: y,
                    width: CGFloat(subdivision) * (config.strumSizes.width + config.strumSizes.gap)
                )
            }
        )
    }
    
    private func createNoteGroup(
        quantity: Int,
        triplet: Bool,
        horizontalStrokes: Int,
        x: CGFloat,
        y: CGFloat,
        width: CGFloat
    ) -> Node<SVG.DocumentContext> {
        let quantityFloat = CGFloat(quantity)
        let color = config.colors.rhythms
        
        let textEl: Node<SVG.DocumentContext>? = triplet ? .element(
            named: "text",
            nodes: [
                .text("3"), // triplet label
                .attribute(
                    named: "x",
                    value: (width * (quantityFloat - 1)) / quantityFloat / 2,
                    format: numberFormat
                ),
                .attribute(
                    named: "y",
                    value: config.beamSizes.stemHeight + 16,
                    format: numberFormat
                ),
                .attribute(named: "font-size", value: config.textSizes.tripletFontSize, format: numberFormat),
                .attribute(named: "text-anchor", value: "middle"),
                .attribute(named: "font-family", value: "sans-serif"),
                .attribute(named: "fill", value: color),
            ]
        ) : nil
        
        // For each stem, create a pair of commands that moves the path to the start
        // and draws a relative line vertically
        let stemLinePathCommands = (0..<quantity).map { i in
            "M\((width * CGFloat(i)) / quantityFloat),0v\(config.beamSizes.stemHeight)"
        }.joined()
        
        // Space out horizontal strokes by 1.5*strokeWidth, or 1 (whichever is larger)
        let horizontalStrokeGap = max(1.5 * config.beamSizes.strokeWidth, 1)
        // This seems weird but it seems to work
        let beamLength = (width * (quantityFloat - 1)) / quantityFloat
        
        let stemBeamPathCommands = (0..<horizontalStrokes).map { i in
            let strokeY = config.beamSizes.stemHeight - CGFloat(i) * horizontalStrokeGap
            return "M0,\(strokeY)h\(beamLength)"
        }.joined()
        
        let noteBeamsPath = Node<SVG.DocumentContext>.element(
            named: "path",
            attributes: [
                .attribute(
                    named: "d",
                    value: stemLinePathCommands + stemBeamPathCommands
                )
            ]
        )
        
        let beamsGroup = Node<SVG.DocumentContext>.element(
            named: "g",
            nodes: [
                .attribute(named: "fill", value: "none"),
                .attribute(named: "stroke", value: color),
                .attribute(
                    named: "stroke-width",
                    value: config.beamSizes.strokeWidth,
                    format: numberFormat
                ),
                .attribute(named: "stroke-linecap", value: "square"),
                noteBeamsPath,
            ]
        )
        
        return Node<SVG.DocumentContext>.element(
            named: "g",
            nodes: [
                [.attribute(
                    named: "transform",
                    value: "translate(\(x.formatted(numberFormat)),\(y.formatted(numberFormat)))"
                )],
                [beamsGroup, textEl]
                    .compactMap { $0 },
            ].flatMap { $0 }
        )
    }
}
