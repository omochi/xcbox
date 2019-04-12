import Foundation

public class Regex {
    public struct MatchResult {
        public init(sourceString: String,
                    nsResult: NSTextCheckingResult)
        {
            var ranges: [Range<String.Index>?] = []
            
            for i in 0..<nsResult.numberOfRanges {
                let nsRange = nsResult.range(at: i)
                if nsRange.location == NSNotFound {
                    ranges.append(nil)
                } else {
                    ranges.append(Range(nsRange, in: sourceString))
                }
            }
            
            self.ranges = ranges
        }
        
        public var ranges: [Range<String.Index>?]
        
        public var count: Int {
            return ranges.count
        }

        public subscript() -> Range<String.Index> {
            return self[0]!
        }
        
        public subscript(index: Int) -> Range<String.Index>? {
            guard 0 <= index && index < count else { return nil }
            
            return ranges[index]
        }
    }
    
    public init(pattern: String, options: NSRegularExpression.Options) throws {
        self.nsRegex = try NSRegularExpression(pattern: pattern, options: options)
    }
    
    public func match(string: String,
                      options: NSRegularExpression.MatchingOptions = [],
                      range: Range<String.Index>? = nil) -> MatchResult?
    {
        let range = range ?? (string.startIndex..<string.endIndex)
        guard let nsResult = nsRegex.firstMatch(in: string,
                                                options: options,
                                                range: NSRange.init(range, in: string)) else
        {
            return nil
        }
        
        return MatchResult(sourceString: string,
                           nsResult: nsResult)
    }
    
    public func matches(string: String,
                        options: NSRegularExpression.MatchingOptions = [],
                        range: Range<String.Index>? = nil) -> [MatchResult]
    {
        let range = range ?? (string.startIndex..<string.endIndex)
        let nsResults = nsRegex.matches(in: string,
                                        options: options,
                                        range: NSRange.init(range, in: string))
        return nsResults
            .map { MatchResult(sourceString: string,
                               nsResult: $0) }
    }
    
    private let nsRegex: NSRegularExpression
}
