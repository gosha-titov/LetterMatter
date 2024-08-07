#if canImport(UIKit)

import UIKit

internal extension NSAttributedString {
    
    /// Returns an attributed string with applied an underline attribute with the given style and color in the specified range.
    /// - Parameter style: The underline style of the text.
    /// - Parameter color: The color of the underline.
    /// - Parameter range: The range of characters to which these attributes apply.
    /// If `nil` is specified,  these attributes are applied to the full string.
    @inlinable @inline(__always)
    func applying(underline style: NSUnderlineStyle, withColor color: UIColor, inRange range: NSRange? = nil) -> NSAttributedString {
        return applying([.underlineColor: color, .underlineStyle: style.rawValue], inRange: range)
    }
    
    /// Returns an attributed string with applied a strikethrough attribute with the given value and color in the specified range.
    /// - Parameter value: The strikethrough style of the text, that is, this is the integer that corresponds the line thickness.
    /// - Parameter color: The color of the strikethrough.
    /// - Parameter range: The range of characters to which these attributes apply.
    /// If `nil` is specified,  these attributes are applied to the full string.
    @inlinable @inline(__always)
    func applying(strikethrough value: Int, withColor color: UIColor, inRange range: NSRange? = nil) -> NSAttributedString {
        return applying([.strikethroughStyle: value, .strikethroughColor: color], inRange: range)
    }
    
    /// Returns an attributed string with applied the given font attribute in the specified range.
    /// - Parameter font: The font of the text.
    /// - Parameter range: The range of characters to which this attribute applies.
    /// If `nil` is specified, this attribute is applied to the full string.
    @inlinable @inline(__always)
    func applying(font: UIFont, inRange range: NSRange? = nil) -> NSAttributedString {
        return applying([.font: font], inRange: range)
    }
    
    /// Returns an attributed string with applied a background attribute with the given color in the specified range.
    /// - Parameter color: The color of the background behind the text.
    /// - Parameter range: The range of characters to which this attribute applies.
    /// If `nil` is specified, this attribute is applied to the full string.
    @inlinable @inline(__always)
    func applying(backgroundColor: UIColor, inRange range: NSRange? = nil) -> NSAttributedString {
        return applying([.backgroundColor: backgroundColor], inRange: range)
    }
    
    /// Returns an attributed string with applied a foreground attribute with the given color in the specified range.
    /// - Parameter color: The color of the text.
    /// - Parameter range: The range of characters to which this attribute applies.
    /// If `nil` is specified, this attribute is applied to the full string.
    @inlinable @inline(__always)
    func applying(foregroundColor: UIColor, inRange range: NSRange? = nil) -> NSAttributedString {
        return applying([.foregroundColor: foregroundColor], inRange: range)
    }
    
    /// Returns an attributed string with applied the given shadow attribute in the specified range.
    /// - Parameter color: The shadow of the text.
    /// - Parameter range: The range of characters to which this attribute applies.
    /// If `nil` is specified, this attribute is applied to the full string.
    @inlinable @inline(__always)
    func applying(shadow: NSShadow, inRange range: NSRange? = nil) -> NSAttributedString {
        return applying([.shadow: shadow], inRange: range)
    }
    
}


#endif


internal extension NSAttributedString {
    
    /// A NSMutableAttributedString value converted from this NSAttributedString value.
    ///
    ///     let mutableString = attributedString.toNSMutableAttributedString
    ///
    @inlinable @inline(__always)
    var toNSMutableAttributedString: NSMutableAttributedString {
        return NSMutableAttributedString(attributedString: self)
    }
    
    /// Returns an attributed string with applied the given collection of attributes to the characters in the specified range.
    /// - Parameter attributes: A dictionary containing the attributes to add.
    /// Attribute keys can be supplied by another framework or can be custom ones you define.
    /// For information about the system-supplied attribute keys, see the Constants section in `NSAttributedString`.
    /// - Parameter range: The range of characters to which the specified attributes apply.
    /// If `nil` is specified, the given attributes are applied to the full string.
    @inlinable @inline(__always)
    func applying(_ attributes: [Key: Any], inRange: NSRange? = nil) -> NSAttributedString {
        guard !string.isEmpty else { return self }
        let range: NSRange
        if let inRange { range = inRange }
        else { range = .init(0..<length) }
        let mutableCopy = self.toNSMutableAttributedString
        mutableCopy.addAttributes(attributes, range: range)
        return mutableCopy
    }

}
