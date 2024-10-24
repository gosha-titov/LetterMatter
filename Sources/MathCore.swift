import Foundation

//
// Implementation notes
// ====================
//
//  (source texts) –> [math basis] –> (formed text) -> (edited text) -> (displayed text)
//                     ––––––––––
//
// The complexity of the calculation depends on the count of identical chars.
// This means that the more identical chars there are – the more operations are performed.
//
//
// First Examle
// ––––––––––––
//
//  Let's take the accurate and compared texts that equal to "aaa":
//  To figure out the correct orders of chars, we need to make the following table for the length = `3`,
//  where each element of the sequences is an index associated with the char in the accurate text:
//
//      Examples of tables with non-decreasing sequences of the specific length:
//
//      ┌─────┐ ┌───────┐ ┌─────────┐ ┌───────────┐ ┌─────────────┐
//      │ 0 0 │ │ 0 0 0 │ │ 0 0 0 0 │ │ 0 0 0 0 0 │ │ 0 0 0 0 0 0 │
//      │ 0 1 │ │ 0 0 1 │ │ 0 0 0 1 │ │ 0 0 0 0 1 │ │ 0 0 0 0 0 1 │
//      │ 1 1 │ │ 0 0 2 │ │         │ │           │ │             │
//      └─────┘ │ 0 1 1 │ │   ...   │ │    ...    │ │     ...     │
//         3    │ 0 1 2 │ │         │ │           │ │             │
//              │ 0 2 2 │ │ 2 3 3 3 │ │ 3 4 4 4 4 │ │ 4 5 5 5 5 5 │
//              │ 1 1 1 │ │ 3 3 3 3 │ │ 4 4 4 4 4 │ │ 5 5 5 5 5 5 │
//              │ 1 1 2 │ └─────────┘ └───────────┘ └─────────────┘
//              │ 1 2 2 │      35          126            462
//              │ 2 2 2 │
//              └───────┘
//                  10
//
//      The dependency table of the count of operations for the specific length:
//      ┌────────┬───┬───┬────┬────┬─────┬─────┬──────┬──────┬───────┬───────┐
//      │ length │ 1 │ 2 │ 3  │ 4  │  5  │  6  │  7   │  8   │   9   │  10   │
//      ├────────┼───┼───┼────┼────┼─────┼─────┼──────┼──────┼───────┼───────┤
//      │ count  │ 1 │ 3 │ 10 │ 35 │ 126 │ 462 │ 1716 │ 6435 │ 24310 │ 92378 │
//      └────────┴───┴───┴────┴────┴─────┴─────┴──────┴──────┴───────┴───────┘
//
//      These numbers show how much the complexity of calculations increases
//      with an increase the number of identical chars.
//
//  That is, for the "aaa" text there are performed 10 operations.
//  (There are several optimizations that in most cases reduce the number of operations to a minimum)
//
//
// Second example
// ––––––––––––––
//
//  Let's take the accurate text = "abab" and the compared text = "baba":
//
//  Firstly, we create the correct sequence for the accurate text, it's [0, 1, 2, 3]
//  Then we make a following table based on this sequence and the accurate text:
//
//   Sequences  Subsequences
//  ┌─────────┐ ┌─────────┐
//  │ 1 0 1 0 │ │   0 1   │
//  │[1 0 1 2]│ │[  0 1 2]│ <- Best pair
//  │ 1 0 3 0 │ │   0 3   │
//  │ 1 0 3 2 │ │   0   2 │
//  │ 1 2 1 2 │ │ 1 2     │
//  │ 1 2 3 2 │ │ 1 2 3   │
//  │ 3 0 3 0 │ │   0 3   │
//  │ 3 0 3 2 │ │   0   2 │
//  │ 3 2 3 2 │ │   2 3   │
//  └─────────┘ └─────────┘
//
//  Now we have to choose the best pair among these: it's [1, 0, 1, 2] and [0, 1, 2].
//  This means that by comparing the sequence and its subsequence with each other
//  we are able to understand which characters are wrong or missing:
//
//  ┌──────────────────┬────────────┐
//  │ Source sequence  │    0 1 2 3 │
//  ├──────────────────┼────────────┤
//  │ Sequence         │  1 0 1 2   │
//  ├──────────────────┼────────────┤
//  │ Subsequence      │    0 1 2   │
//  ├──────────────────┼────────────┤
//  │ Missing Elements │          3 │
//  └──────────────────┴────────────┘
//
//  Based on this math model (basis), we can make the following conclusion:
//  The first char is extra, then the next three are correct and the last one is missing.
//
//  Note, that final count of operations equals to multiplying the count for each length of identical characters.
//  That is, 3*3=9 operations are performed for this example.
//  For "aaaaabbb" and "bbbaaaaa", 126*10=1260 operations are performed.
//  But this is without optimizations, because when using them, the final count is only ONE.
//
//  But at the same time for a text consisting of 300 chars where there are only 3 identical chars (100 kinds of char),
//  100*10=1000 operations are performed.
//
//
// General Optimization
// ––––––––––––––––––––
//
// accurateText: "123a456bc789"
// comparedText: "123bc456a789"
//
// First of all, we can find common prefix and suffix between these two texts:
//
// accurateText: "123" [ "a456bc" ] "789"
// comparedText: "123" [ "bc456c" ] "789"
//
// We get partial texts in which we can try to find the common part longer than a half:
//
// accurateText: "123" [ "a"  ] "456" [ "bc" ] "789"
// comparedText: "123" [ "bc" ] "456" [ "c"  ] "789"
//                       ^^^^           ^^^^
//
// After all the actions, we only have to compare small parts of these texts.
// And then we just put it all together.
//
//
// Other notes
// –––––––––––
//
// In theory, this algorithm works for a text of any length,
// but in practice we have to divide a text into sentences and sentences into words.
// Otherwise, the execution time tends to infinity, since the count of operations inevitably increases.
// Actually, if it is assumed that the user enters a meaningful text similar to the correct one,
// then there is no need to divide a sentence into words since optimizations works well.
//

/// A math core that consists of static methods for working with numbers, sequences, subsequences and so on.
internal final class LMMathCore {
    
    // MARK: - Calculate Basis
    
    /// Calculates the math basis from the two given texts.
    ///
    ///     let accurateText = "Hello"
    ///     let comparedText = "hola"
    ///
    ///     let basis = LMMathCore.calculateBasis(
    ///         for: comparedText,
    ///         relyingOn: accurateText
    ///     )
    ///
    ///     basis.sourceSequence  // [0, 1, 2, 3, 4]
    ///     basis.sequence        // [0, 4, 2, nil ]
    ///     basis.subsequence     // [0,    2      ]
    ///     basis.missingElements // [   1,    3, 4]
    ///
    /// - Note: Letter case does not affect anything, becase these texts are changed to thier lowercase versions.
    /// - Parameter comparedText: A text to be compared with `accurateText` in order to find the best set of matching chars.
    /// - Parameter accurateText: A text based on which the calculation of the `basis` for `comparedText` performs.
    /// - Returns: The math basis that has properties consisting of elements that are indexes of associated chars in `accurateText`.
    @inlinable
    internal static func calculateBasis(for comparedText: String, relyingOn accurateText: String) -> Basis {
        
        let comparedText = comparedText.lowercased(), accurateText = accurateText.lowercased()
        let accurateSequence: Sequence = Array(0..<accurateText.count)
        
        // Find a common beginning(prefix) and ending(suffix) of the texts:
        let prefixCount = comparedText.commonPrefix(with: accurateText).count
        var partialAccurateText = accurateText.dropFirst(prefixCount).toString
        var partialComparedText = comparedText.dropFirst(prefixCount).toString
        
        let suffixCount = partialComparedText.commonSuffix(with: partialAccurateText).count
        partialAccurateText = partialAccurateText.dropLast(suffixCount).toString
        partialComparedText = partialComparedText.dropLast(suffixCount).toString
        
        // Perform the work of the algorithm:
        let rawSequences = generateRawSequences(for: partialComparedText, relyingOn: partialAccurateText)
        let rawPairs = makeRawPairs(from: rawSequences)
        let (partialSequence, partialSubsequence) = pickBestPair(among: rawPairs).toTuple
        
        // Restore the missing common parts:
        let accurateSequencePrefix = accurateSequence.first(prefixCount)
        let accurateSequenceSuffix = accurateSequence.last(suffixCount)
        
        // Put everything together:
        let shiftedPartialSequence    = partialSequence   .map { $0.hasValue ? $0! + prefixCount : nil }
        let shiftedPartialSubsequence = partialSubsequence.map {               $0  + prefixCount       }
        let sequence    = accurateSequencePrefix + shiftedPartialSequence    + accurateSequenceSuffix
        let subsequence = accurateSequencePrefix + shiftedPartialSubsequence + accurateSequenceSuffix
        
        return Basis(accurateSequence, sequence, subsequence)
    }
    
    
    // MARK: - Pick Best Pair
    
    /// Picks the best pair among the given pairs.
    ///
    /// The picking is made by the smallest sum of the subsequence.
    ///
    ///     let rawPairs = [
    ///         ([nil, 1, 2, 4, 1], [1, 2, 4]),
    ///         ([nil, 1, 2, 4, 3], [1, 2, 3])
    ///     ]
    ///     let bestPair = pickBestPair(among: rawPairs)
    ///     // ([nil, 1, 2, 4, 3], [1, 2, 3])
    ///
    /// - Important: The subsequences should be only of the same length; otherwise, this method does not work correctly.
    /// - Returns: The pair with the smallest sum of the subsequense.
    @inlinable @inline(__always)
    internal static func pickBestPair(among rawPairs: [Pair]) -> Pair {
        
        guard rawPairs.isEmpty == false else { return Pair() }
        guard rawPairs.count > 1 else { return rawPairs[0] }
        
        var bestPair = rawPairs[0]
        
        for rawPair in rawPairs[1...] {
            let rawLis = rawPair.subsequence, bestLis = bestPair.subsequence
            if rawLis.sum < bestLis.sum {
                bestPair = rawPair
            }
        }
        
        return bestPair
    }

    
    // MARK: - Make Raw Pairs
        
    /// Makes raw pairs by finding lises of the given sequences.
    ///
    ///     let rawSequences = [
    ///         [nil, 1, 2, 4, 1], // lis: [1, 2, 4]
    ///         [nil, 1, 2, 4, 3], // lis: [1, 2, 3]
    ///         [nil, 3, 2, 4, 3]  // lis: [2, 3]
    ///     ]
    ///
    ///     let rawPairs = makeRawPairs(from: rawSequences)
    ///     /* [([nil, 1, 2, 4, 1], [1, 2, 4]),
    ///         ([nil, 1, 2, 4, 3], [1, 2, 3])] */
    ///
    /// - Note: The result will contain pairs with the max lis length.
    /// - Returns: Pairs of sequence and its subsequence.
    @inlinable @inline(__always)
    internal static func makeRawPairs(from rawSequences: [OptionalSequence]) -> [Pair] {
        
        var pairs = [Pair]()
        var maxCount = Int()
        
        for rawSequence in rawSequences {
            let sequence = rawSequence.compactMap { $0 }
            let subsequence = findLIS(of: sequence)
            if subsequence.count >= maxCount {
                let pair = Pair(rawSequence, subsequence)
                pairs.append(pair)
                maxCount = subsequence.count
            }
        }
        
        return pairs.filter { $0.subsequence.count == maxCount }
    }
    
    
    // MARK: - Generate Raw Sequences

    /// Generates all possible char placements for `comparedText` relying on `accurateText`.
    ///
    /// This method searches for the placements of the same char of `accurateText` for each char in `comparedText`.
    ///
    ///     let accurateText = "robot"
    ///     let comparedText = "gotob"
    ///
    ///     let rawSequences = generateRawSequences(
    ///         for: comparedText,
    ///         relyingOn: accurateText
    ///     )
    ///     /* [[nil, 1, 4, 1, 2],
    ///         [nil, 1, 4, 3, 2],
    ///         [nil, 3, 4, 3, 2]] */
    ///
    /// - Note: The raw sequences are arranged in increasing order. The indexes of the same chars are arranged in a non-decreasing order.
    /// - Returns: The sequences where elemens are indexes of chars in `accurateText`.
    @inlinable @inline(__always)
    internal static func generateRawSequences(for comparedText: String, relyingOn accurateText: String) -> [OptionalSequence] {
        
        // First Example
        // –––––––––––––
        //
        // comparedText is "caba", accurateText is "acab"
        //
        // dict is ["a": [0, 2], "c": [1], b: [3]]
        //
        // (c)   (a)   (b)   (a)
        //  1 ──> 0 ──> 3 ──> 0
        //   │           │
        //   │           └──> 2
        //   │
        //   └──> 2 ──> 3 ──> 2
        //
        // rawSequences are [ [1, 0, 3, 0], [1, 0, 3, 2], [1, 2, 3, 2] ]
        //
        //
        // Second Example
        // ––––––––––––––
        //
        // comparedText is "caaaba", accurateText is "baaaac"
        //
        // dict is ["b": [0], "a": [1, 2, 3, 4], "c": [5]]
        //
        // (c)   (a)   (a)   (a)   (b)   (a)
        //  5 ──> 1 ──> 2 ──> 3 ──> 0 ──> 3
        //                           │
        //                           └──> 4
        //
        // rawSequences are [ [5, 1, 2, 3, 0, 3], [5, 1, 2, 3, 0, 4] ]
        //
        
        var rawSequences = [OptionalSequence]()
        
        let dict = charPositions(of: accurateText)
        let comparedText = comparedText.lowercased()
        
        /// The buffer that stores all positions of chars added into the current sequence
        var buffer = [Character: [Int]]()
        
        func recursion(_ sequence: OptionalSequence) -> Void {
            let currentIndex = sequence.count
            // Complete this recursion by adding this sequence to raw sequences
            guard currentIndex < comparedText.count else {
                rawSequences.append(sequence)
                return
            }
            let currentChar = comparedText[currentIndex]
            // Take all possible positions for the current char
            if let sourcePositions = dict[currentChar] {
                for currentPosition in sourcePositions {
                    // If the current char already exists in this sequence
                    if let positionsOfCurrentChar = buffer[currentChar], let lastPosition = positionsOfCurrentChar.last {
                        guard currentPosition >= lastPosition else { continue }
                        let previousChar = comparedText[currentIndex - 1]
                        // If same chars are in a row then their positions should be in ascending order
                        if previousChar == currentChar {
                            let biggestPosition = sourcePositions.last!
                            guard (currentPosition == lastPosition + 1) || (lastPosition == biggestPosition) else {
                                continue
                            }
                        }
                        buffer[currentChar]!.append(currentPosition)
                    } else {
                        buffer[currentChar] = [currentPosition]
                    }
                    // Continue to create this sequence
                    recursion(sequence + [currentPosition])
                    buffer[currentChar]!.removeLast()
                    // If same chars are in a row then the first suitable position in sourceSequence is always correct
                    // So we don't need to go through the other ones
                    if let nextChar = comparedText[safe: currentIndex + 1] {
                        guard currentChar != nextChar else { break }
                    }
                }
            } else {
                recursion(sequence + [nil])
            }
        }
        
        recursion([])
        return rawSequences
    }
    
    
    // MARK: - Count Common Chars
    
    /// Counts common chars between the given texts.
    ///
    ///     let text1 = "Abcde"
    ///     let text2 = "aDftb"
    ///     let count = countCommonChars(between: text1, and: text2) // 3
    ///
    /// - Note: Letter case does not affect the result.
    /// - Returns: An integer value that indicates how many common chars between given texts.
    @inlinable
    internal static func countCommonChars(between text1: String, and text2: String) -> Int {
        let dict1 = charPositions(of: text1)
        let dict2 = charPositions(of: text2)
        var count = 0
        for (char1, positions1) in dict1 {
            if let positions2 = dict2[char1] {
                count += min(positions1.count, positions2.count)
            }
        }
        return count
    }
    
    
    // MARK: - Char Positions
        
    /// Finds for each char all its indexes where it's placed in the given text.
    ///
    ///     let text = "Robot"
    ///     let dict = charPositions(of: text)
    ///     // ["r": [0], "o": [1, 3], "b": [2], "t": [4]]
    ///
    /// - Note: Letter case does not affect anything, because the text is changed to a lowercase version.
    /// - Complexity: O(*n*), where *n* is the length of the text.
    /// - Returns: A dictionary where each char contains its own indexes.
    @inlinable 
    internal static func charPositions(of text: String) -> [Character: [Int]] {
        var dict = [Character: [Int]]()
        for (index, char) in text.lowercased().enumerated() {
            if dict.hasKey(char) {
                dict[char]!.append(index)
            } else {
                dict[char] = [index]
            }
        }
        return dict
    }
    
    
    // MARK: - Find Common Part
    
    /// Finds a continuous sequence of characters that is longer than a half of the smallest text.
    ///
    ///     let text1 = "ab123"
    ///     let text2 = "a123"
    ///     let commonPart = findCommonPart(between: text1, and: text2)!
    ///     // (index1: 2, index2: 1, length: 3)
    ///
    /// - Note: It's a part of the general optimization.
    /// This works perfectly if we believe that the user enters a meaningful text similar to the accurate one, but with some mistakes.
    /// - Returns: Indexes of start of a common part, and its length; otherwise, `nil`.
    @inlinable
    internal static func findCommonPart(between text1: String, and text2: String) -> (index1: Int, index2: Int, length: Int)? {
        func roundedHalf(of text: String) -> Int { return Int(round(Double(text.count)) / 2) }
        func rawHalf(of text: String) -> Int { return text.count / 2 }
        let half = min(roundedHalf(of: text1), roundedHalf(of: text2))
        let rawHalf = min(rawHalf(of: text1), rawHalf(of: text2))
        for index1 in 0..<(text1.count - rawHalf) {
            for index2 in 0..<(text2.count - rawHalf) {
                let char1 = text1[index1]
                let char2 = text2[index2]
                if char1 == char2 {
                    let maxOffset1 = text1.count - index1
                    let maxOffset2 = text2.count - index2
                    var count = 1
                    for offset in 1..<min(maxOffset1, maxOffset2) {
                        let char1 = text1[index1 + offset]
                        let char2 = text2[index2 + offset]
                        guard char1 == char2 else { break }
                        count += 1
                    }
                    if count >= half {
                        return (index1, index2, count)
                    }
                }
            }
        }
        return nil
    }
    
    
    
    // MARK: - Find LIS
    
    /// Finds the longest-increasing-subsequence of the given sequence.
    ///
    /// It's the main method on which all other operations are based.
    ///
    ///     let sequence = [2, 6, 0, 8, 1, 3, 1]
    ///     let subsequence = findLIS(of: sequence) // [0, 1, 3]
    ///
    /// The example sequence has two *lises*: `[2, 6, 8]` and `[0, 1, 3]`.
    /// This method returns always the smallest one, that is `[0, 1, 3]`.
    /// - Complexity: In the worst case, O(*n* log *n*), where *n* is the length of the sequence.
    /// - Returns: The longest increasing subsequence of the sequence.
    @inlinable @inline(__always)
    internal static func findLIS(of sequence: Sequence) -> Subsequence {
        
        guard sequence.count > 1 else { return sequence }
        
        // The array contains the found lises of each length for the current step.
        // Lises are ordered by the last element. The length of next lis is one longer.
        // Therefore, the longest lis is the last one.
        //
        // Example: sequence = [0, 8, 4, 12, 2, 10, 6, 14, 1, 9, 5, 13, 3, 11, 7]
        // At the last step, lises will be [[0], [0, 1], [0, 1, 3], [0, 1, 3, 7], [0, 2, 6, 9, 11]]
        var lises: [Subsequence] = [[sequence.first!]]
        
        for element in sequence[1...] {
            
            var lowerBound = 0, upperBound = lises.count - 1
            var index: Int { lowerBound }
            
            // Lises are ordered by the last element.
            // Shift the boundaries to the first element that is bigger than the current one.
            // Use binary search which is the fastest.
            while lowerBound < upperBound {
                let middle = lowerBound + (upperBound - lowerBound) / 2
                let middleElement = lises[middle].last!
                if middleElement == element { lowerBound = middle; break }
                if middleElement > element  { upperBound = middle }
                else { lowerBound = middle + 1 }
            }
            
            // If all elements are smaller, then we add a new lis.
            // If all elements are bigger, then we change the first lis.
            // In any other case, we change the selected lis.
            if index == lises.count - 1, element > lises[index].last! {
                lises.append(lises[index] + [element])
            } else if index == 0 {
                lises[0] = [element]
            } else {
                lises[index] = lises[index - 1] + [element]
            }
        }
        
        return lises.last!
    }
    
    
    // MARK: - Init
    
    /// Creates a math frame instance.
    private init() {}
    
}



// MARK: - Math Types

extension LMMathCore {
    
    /// A sequence that consists of char indexes.
    internal typealias Sequence = [Int]
    
    /// An optional sequence that consists of char indexes or `nil` values.
    internal typealias OptionalSequence = [Int?]
    
    /// A subsequence that consists of char indexes.
    internal typealias Subsequence = [Int]
    
    
    // MARK: Basis
    
    /// A math basis created from two texts.
    ///
    /// This is the final result of the work of `THMathCore`.
    ///
    ///     let accurateText = "Hello"
    ///     let comparedText = "hola"
    ///
    ///     let basis = THMathCore.calculateBasis(
    ///         for: comparedText,
    ///         relyingOn: accurateText
    ///     )
    ///
    ///     basis.sourceSequence  // [0, 1, 2, 3, 4]
    ///     basis.sequence        // [0, 4, 2, nil ]
    ///     basis.subsequence     // [0,    2      ]
    ///     basis.missingElements // [   1,    3, 4]
    ///
    /// - Note: The value of each element of the sequence is the index of the associated char in the source text.
    internal struct Basis: Equatable {
        
        /// The sequence generated from `accurateText`.
        internal let sourceSequence: Sequence
        
        /// The sequence generated from `comparedText` relying on `accurateText`.
        internal let sequence: OptionalSequence
        
        /// The longest increasing subsequence found in `sequence`.
        internal let subsequence: Subsequence
        
        /// Elements that are present in the `sourceSequence` but missing in the `subsequence`.
        internal let missingElements: Sequence
        
        /// Creates a math basis instance.
        internal init(_ sourceSequence: Sequence, _ sequence: OptionalSequence, _ subsequence: Subsequence) {
            self.sourceSequence = sourceSequence
            self.sequence = sequence
            self.subsequence = subsequence
            missingElements = sourceSequence.filter { !subsequence.contains($0) }
        }
        
    }
    
    
    // MARK: Pair
    
    /// A math pair of sequence and its subsequence.
    internal struct Pair: Equatable {
        
        /// The sequence consisting of associated indexes.
        internal let sequence: OptionalSequence
        
        /// The longest increasing subsequence found in `sequence`.
        internal let subsequence: Subsequence
        
        /// Creates a math pair instance.
        internal init(_ sequence: OptionalSequence, _ subsequence: Subsequence) {
            self.sequence = sequence
            self.subsequence = subsequence
        }
        
    }
    
}



internal extension LMMathCore.Basis {
    
    /// Creates a math basis instance with visible arguments.
    /// - Note: It's mainly used for testing.
    @inlinable @inline(__always)
    init(sourceSequence: LMMathCore.Sequence, sequence: LMMathCore.OptionalSequence, subsequence: LMMathCore.Subsequence) {
        self.init(sourceSequence, sequence, subsequence)
    }
    
    /// Creates an empty math basis instance.
    /// - Note: It's mainly used for testing.
    @inlinable @inline(__always)
    init() {
        self.init(LMMathCore.Sequence(), LMMathCore.OptionalSequence(), LMMathCore.Subsequence())
    }
    
    @inlinable @inline(__always)
    static func == (lhs: LMMathCore.Basis, rhs: LMMathCore.Basis) -> Bool {
        if lhs.sourceSequence == rhs.sourceSequence,
           lhs.subsequence == rhs.subsequence,
           lhs.sequence == rhs.sequence {
            return true
        }
        return false
    }
    
}



internal extension LMMathCore.Pair {
    
    /// A tuple value converted from this pair.
    @inlinable @inline(__always)
    var toTuple: (sequence: LMMathCore.OptionalSequence, subsequence: LMMathCore.Subsequence) {
        return (sequence, subsequence)
    }
    
    /// Creates a math pair instance with visible arguments.
    /// - Note: It's mainly used for testing.
    @inlinable @inline(__always)
    init(sequence: LMMathCore.OptionalSequence, subsequence: LMMathCore.Subsequence) {
        self.init(sequence, subsequence)
    }
    
    /// Creates an empty math pair instance.
    @inlinable @inline(__always)
    init() {
        self.init(LMMathCore.OptionalSequence(), LMMathCore.Subsequence())
    }
    
    @inlinable  @inline(__always)
    static func == (lhs: LMMathCore.Pair, rhs: LMMathCore.Pair) -> Bool {
        if lhs.subsequence == rhs.subsequence,
           lhs.sequence == rhs.sequence {
            return true
        }
        return false
    }

}
