import Testing
@testable import Facehash

@Suite("StringHash")
struct StringHashTests {
    @Test("Empty string hashes to 0")
    func emptyString() {
        #expect(stringHash("") == 0)
    }

    @Test("Single character 'a' hashes to 97")
    func singleCharA() {
        #expect(stringHash("a") == 97)
    }

    @Test("Hash is deterministic")
    func deterministic() {
        let result1 = stringHash("deterministic-test")
        let result2 = stringHash("deterministic-test")
        #expect(result1 == result2)
    }

    @Test("Hash is always non-negative")
    func nonNegative() {
        let testCases = ["", "a", "hello", "negative-test", "🎉", "日本語"]
        for str in testCases {
            #expect(stringHash(str) >= 0)
        }
    }
}
