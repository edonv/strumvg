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
    func generate(pattern: Pattern, size: CGSize? = nil) -> SVG {
        let allStrums = pattern.groups
            .flatMap(\.strums)
        
        let strs = createRhythmText(quantity: allStrums.count, noteLength: pattern.timing)
        
        let calcWidth = (options.strumSizes.strumWidth + options.strumSizes.strumGap) * CGFloat(pattern.totalStrums) - options.strumSizes.strumGap
        let calcHeight = options.strumSizes.strumHeight + options.textSizes.headerHeight + 2 * options.textSizes.beatTextHeight
        
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
                let arrow = createStrumArrow(strum: strum)
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
                            value: "translate(\((options.strumSizes.strumWidth + options.strumSizes.strumGap) * index),\(options.textSizes.headerHeight))\(strum.direction == .down ? " rotate(180 0 0)" : "")"
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
                        return "\(Double(i / 3 + 1))"
                    } else {
                        return ""
                    }
                } else {
                    return "\(int + 1)"
                }
                
            case .eighth:
                if triplet {
                    if int % 3 == 0 {
                        return "\(Double(i / 3 + 1))"
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
        
        let height = rhythmText ? options.textSizes.beatTextHeight : options.textSizes.headerHeight
        let width = options.strumSizes.strumWidth
        let fill = rhythmText ? options.colors.rhythmColor : options.colors.headerColor
        let fontSize = rhythmText ? options.textSizes.beatTextFontSize : options.textSizes.headerFontSize
        let x = (options.strumSizes.strumWidth + options.strumSizes.strumGap) * CGFloat(index) + options.strumSizes.strumWidth / 2
        let yBase = rhythmText ? options.textSizes.headerHeight + options.strumSizes.strumHeight * FIX_FACTOR : 0
        
        return Node<SVG.DocumentContext>.element(
            named: "text",
            nodes: [
                .text("\(content)"),
                .attribute(named: "key", value: "head\(index)"),
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
        strum: Strum
    ) -> Node<SVG.DocumentContext>? {
        let variant = strum.variant
        let height = options.strumSizes.strumHeight /*?? 100*/
        let width = options.strumSizes.strumWidth /*?? 50*/
        let fill = options.colors.arrowColor
        let strokeWidth: CGFloat = 0.2
        let headHeight: CGFloat = 0.2
        
        let pathEl: Node<SVG.DocumentContext>
        let rectEl1: Node<SVG.DocumentContext>
        let rectEl2: Node<SVG.DocumentContext>
        
        switch variant {
        case .normal:
            return .element(
                named: "path",
                attributes: [
                    .attribute(
                        named: "d",
                        value: "m0,\(height * headHeight)l\(width / 2),\(-height * headHeight)l\(width / 2),\(height * headHeight)l\((-width * (1 - strokeWidth)) / 2),0l0,\(height / 2)l\(-width * strokeWidth),0l0,\(-height / 2)l\(-width / 4),0z"
                    ),
                    .attribute(
                        named: "stroke-width",
                        value: "0"
                    )
                ]
            )
            
        case .arpeggio:
            let offsetY = height * headHeight * 0.9
            let numWaves = 6
            let amplitude = 6
            // let offsetX = amplitude * 2;
            let wavelength = height / CGFloat(numWaves) / CGFloat(2)
            
            // Triangle
            let pathEl1 = Node<SVG.DocumentContext>.element(
                named: "path",
                attributes: [
                    .attribute(
                        named: "d",
                        value: "M\(0),\(height * headHeight)l\(width / 2),\(-height * headHeight)l\(width / 2),\(height * headHeight)"
                    ),
                    .attribute(named: "stroke-width", value: "0")
                ]
            )
            
            // Squiggle
            let pathEl2 = Node<SVG.DocumentContext>.element(
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
                        value: width * strokeWidth,
                        format: numberFormat
                    ),
                    .attribute(named: "fill", value: "transparent"),
                    .attribute(named: "stroke", value: fill /*?? ""*/)
                ]
            )

            return .element(named: "g", nodes: [pathEl1, pathEl2])

//        case .accent:
//            let newStrokeWidth = min(1, strokeWidth * 2)
//            
//            return Node<XML.DocumentContext>.element(
//                named: "path",
//                attributes: [
//                    .attribute(
//                        named: "d",
//                        value: "m0,\(height * headHeight)l\(width / 2),\(-height * headHeight)l\(width / 2),\(height * headHeight)l\((-width * (1 - newStrokeWidth)) / 2),0l0,\(height / 2)l\(-width * newStrokeWidth),0l0,\(-height / 2)l\(-width / 4),0z"
//                    ),
//                    .attribute(named: "stroke-width", value: "0")
//                ]
//            )
            
        case .muted:
            pathEl = Node<SVG.DocumentContext>.element(
                named: "path",
                attributes: [
                    .attribute(
                        named: "d",
                        value: "m0,\(height * headHeight)l\(width),0l\((-width * (1 - strokeWidth)) / 2),0l0,\(height / 2)l\(-width * strokeWidth),0l0,\(-height / 2)l\(-width / 4),0z"
                    ),
                    .attribute(named: "stroke-width", value: "0")
                ]
            )

            let rectElAttrs: [Attribute<SVG.DocumentContext>] = [
                .attribute(
                    named: "width",
                    value: width * strokeWidth,
                    format: numberFormat
                ),
                .attribute(
                    named: "height",
                    value: height * headHeight * 2,
                    format: numberFormat
                ),
                .attribute(
                    named: "x",
                    value: width / 2 - (width * strokeWidth) / 2,
                    format: numberFormat
                ),
                .attribute(
                    named: "style",
                    value: "transform-box: fill-box; transform-origin: center;"
                ),
            ]
            
            rectEl1 = Node<SVG.DocumentContext>.element(
                named: "rect",
                attributes: [
                    rectElAttrs,
                    [.attribute(named: "transform", value: "rotate(45 0 0)")]
                ].flatMap { $0 }
            )
            
            rectEl2 = Node<SVG.DocumentContext>.element(
                named: "rect",
                attributes: [
                    rectElAttrs,
                    [.attribute(named: "transform", value: "rotate(-45 0 0)")]
                ].flatMap { $0 }
            )
            
            return .element(
                named: "g",
                nodes: [
                    pathEl,
                    rectEl1,
                    rectEl2,
                ]
            )
            
        case .space:
            return nil
            
        case .rest:
            let h_factor: CGFloat = 3
            
            let rectElAttrs: [Attribute<SVG.DocumentContext>] = [
                .attribute(
                    named: "y",
                    value: (height / 4) * (1 - 1 / h_factor),
                    format: numberFormat
                ),
                .attribute(
                    named: "width",
                    value: width / 4,
                    format: numberFormat
                ),
                .attribute(
                    named: "height",
                    value: height / h_factor,
                    format: numberFormat
                ),
            ]
            
            rectEl1 = Node<SVG.DocumentContext>.element(
                named: "rect",
                attributes: [
                    rectElAttrs,
                    [.attribute(
                        named: "x",
                        value: 0 + width / 8,
                        format: numberFormat
                    )]
                ].flatMap { $0 }
            )
            
            rectEl2 = Node<SVG.DocumentContext>.element(
                named: "rect",
                attributes: [
                    rectElAttrs,
                    [.attribute(
                        named: "x",
                        value: width / 2 + width / 8,
                        format: numberFormat
                    )]
                ].flatMap { $0 }
            )
            
            return Node<SVG.DocumentContext>.element(
                named: "g",
                nodes: [
                    rectEl1,
                    rectEl2,
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
        let y = options.textSizes.headerHeight + options.strumSizes.strumHeight * FIX_FACTOR + options.textSizes.beatTextHeight
        
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
                    x: CGFloat(subdivision) * (options.strumSizes.strumWidth + options.strumSizes.strumGap) * CGFloat(i) + options.strumSizes.strumWidth / 2,
                    y: y,
                    width: CGFloat(subdivision) * (options.strumSizes.strumWidth + options.strumSizes.strumGap)
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
        let fill = options.colors.rhythmColor
        
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
                    value: options.beamSizes.beamStemHeight + 16,
                    format: numberFormat
                ),
//                .attribute(named: "font-size", value: options.tripletTextFontSize, format: numberFormat),
                .attribute(named: "font-size", value: "14"),
                .attribute(named: "text-anchor", value: "middle"),
                .attribute(named: "font-family", value: "sans-serif"),
                .attribute(named: "fill", value: fill),
            ]
        ) : nil
        
        let stemLines = (0..<quantity).map { i in
            Node<SVG.DocumentContext>.element(
                named: "rect",
                attributes: [
                    .attribute(
                        named: "width",
                        value: options.beamSizes.beamStrokeWidth,
                        format: numberFormat
                    ),
                    .attribute(named: "height", value: options.beamSizes.beamStemHeight, format: numberFormat),
                    .attribute(named: "fill", value: fill),
                    .attribute(
                        named: "x",
                        value: (width * CGFloat(i)) / quantityFloat - options.beamSizes.beamStrokeWidth / 2,
                        format: numberFormat
                    ),
                ]
            )
        }
        
        let stemBeams = (0..<horizontalStrokes).map { i in
            Node<SVG.DocumentContext>.element(
                named: "rect",
                attributes: [
                    .attribute(
                        named: "width",
                        value: (width * (quantityFloat - 1)) / quantityFloat + options.beamSizes.beamStrokeWidth,
                        format: numberFormat
                    ),
                    .attribute(
                        named: "height",
                        value: options.beamSizes.beamStrokeWidth / CGFloat(horizontalStrokes),
                        format: numberFormat
                    ),
                    .attribute(named: "fill", value: fill),
                    .attribute(
                        named: "x",
                        value: -options.beamSizes.beamStrokeWidth / 2,
                        format: numberFormat
                    ),
                    .attribute(
                        named: "y",
                        value: options.beamSizes.beamStemHeight - CGFloat(i) * options.beamSizes.beamStrokeWidth,
                        format: numberFormat
                    ),
                ] as [Attribute<XML.DocumentContext>]
            )
        }

        
        return Node<SVG.DocumentContext>.element(
            named: "g",
            nodes: [
                [.attribute(
                    named: "transform",
                    value: "translate(\(x.formatted(numberFormat)),\(y.formatted(numberFormat)))"
                )],
                stemLines,
                stemBeams,
                [textEl]
                    .compactMap { $0 },
            ].flatMap { $0 }
        )
    }
}
