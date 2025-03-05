//
//  Attribute+Formatted.swift
//  strumvg
//
//  Created by Edon Valdman on 2/27/25.
//

import Foundation
import Plot

extension Component {
    /// Add an attribute to the HTML element used to render this component.
    /// - parameter name: The name of the attribute to add.
    /// - parameter value: The value that the attribute should have.
    /// - parameter format: The format that should be used to display `value` as a `String`.
    /// - parameter replaceExisting: Whether any existing attribute with the
    ///   same name should be replaced by the new attribute. Defaults to `true`,
    ///   and if set to `false`, this attribute's value will instead be appended
    ///   to any existing one, separated by a space.
    /// - parameter ignoreValueIfEmpty: Whether the attribute should be ignored if
    ///   its value is `nil` or empty. Defaults to `true`, and if set to `false`,
    ///   only the attribute's name will be rendered if its value is empty.
    package func attribute<F>(
        named name: String,
        value: F.FormatInput?,
        format: F,
        replaceExisting: Bool = true,
        ignoreValueIfEmpty: Bool = true
    ) -> Component where F: FormatStyle, F.FormatInput: Equatable, F.FormatOutput == String {
        attribute(Attribute<Any>(
            name: name,
            value: value.map { format.format($0) },
            replaceExisting: replaceExisting,
            ignoreIfValueIsEmpty: ignoreValueIfEmpty
        ))
    }
}

extension Node {
    /// Create a custom attribute with a given name and value.
    /// - parameter name: The name of the attribute to create.
    /// - parameter value: The attribute's value.
    /// - parameter format: The format that should be used to display `value` as a `String`.
    /// - parameter ignoreIfValueIsEmpty: Whether the attribute should be ignored if
    ///   its value is empty (default: true).
    package static func attribute<F>(
        named name: String,
        value: F.FormatInput?,
        format: F,
        ignoreIfValueIsEmpty: Bool = true
    ) -> Node where F: FormatStyle, F.FormatInput: Equatable, F.FormatOutput == String {
        .attribute(Attribute(
            name: name,
            value: value.map { format.format($0) },
            ignoreIfValueIsEmpty: ignoreIfValueIsEmpty
        ))
    }
}

extension Attribute {
    /// Create an attribute with a given name and value. This is the recommended
    /// way of creating completely custom attributes, or ones that Plot does not
    /// yet support, when within an attribute context.
    package static func attribute<F>(
        named name: String,
        value: F.FormatInput?,
        format: F
    ) -> Self where F: FormatStyle, F.FormatInput: Equatable, F.FormatOutput == String {
        Attribute(
            name: name,
            value: value.map { format.format($0) }
        )
    }
}
