internal extension Substring {
    
    /// A String value converted from this substring.
    ///
    ///     let sub = "12345".dropLast(2) // "45" is substring
    ///     let str = sub.toString // "45" is string
    ///
    @inlinable @inline(__always)
    var toString: String { String(self) }
    
}
