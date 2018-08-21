import Foundation

final class Word: Searchable {
    var word: String
    var keywords: [String] { return [word] }
    
    init(word: String) {
        self.word = word
    }
}

extension Word : Hashable {
    var hashValue: Int { return word.hashValue }
    
    static func == (lhs: Word, rhs: Word) -> Bool {
        return lhs.word == rhs.word
    }
}

public protocol Searchable: Hashable {
    var keywords: [String] { get }
}

open class AutoComplete<T: Searchable> {
    lazy var nodes = [Character: AutoComplete<T>]()
    lazy var items = [T]()
    
    public init() { }
    
    // MARK: - Insert / index
    
    public func insert(_ object: T) {
        for string in object.keywords {
            var tokens = tokenize(string)
            var currentIndex = 0
            var maxIndex = tokens.count
            insert(tokens: &tokens, at: &currentIndex, max: &maxIndex, object: object)
        }
    }
    
    private func insert(tokens: inout [Character],
                        at currentIndex: inout Int,
                        max maxIndex: inout Int,
                        object: T) {
        if currentIndex < maxIndex {
            let current = tokens[currentIndex]
            currentIndex += 1
            
            if nodes[current] == nil {
                nodes[current] = AutoComplete<T>()
            }
            
            nodes[current]?.insert(tokens: &tokens, at: &currentIndex, max: &maxIndex, object: object)
        } else {
            items.append(object)
        }
    }
    
    public func insert(_ set: [T]) {
        for object in set {
            insert(object)
        }
    }
    
    // MARK: - Search
    
    public func search(_ string: String) -> [T] {
        var merged: Set<T>?
        
        for word in string.components(separatedBy: " ") {
            var wordResults = Set<T>()
            var tokens = tokenize(word)
            var maxIndex = tokens.count
            var currentIndex = 0
            find(tokens: &tokens, at: &currentIndex, max: &maxIndex, into: &wordResults)
            if let results = merged {
                merged = results.intersection(wordResults)
            } else {
                merged = wordResults
            }
        }
        
        if let results = merged {
            return Array(results)
        }
        return []
    }
    
    private func find(tokens: inout [Character],
                      at currentIndex: inout Int,
                      max maxIndex: inout Int,
                      into results: inout Set<T>) {
        if currentIndex < maxIndex {
            let current = tokens[currentIndex]
            currentIndex += 1
            nodes[current]?.find(tokens: &tokens, at: &currentIndex, max: &maxIndex, into: &results)
        } else {
            insertAll(into: &results)
        }
    }
    
    func insertAll(into results: inout Set<T>) {
        for t in items {
            results.insert(t)
        }
        
        for (_, child) in nodes {
            child.insertAll(into: &results)
        }
    }
    
    private func tokenize(_ string: String) -> [Character] {
        return Array(string.lowercased())
    }
}
