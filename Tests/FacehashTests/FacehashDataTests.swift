import Testing
@testable import Facehash

@Suite("FacehashData")
struct FacehashDataTests {
    @Test("John produces correct facehash data")
    func johnFacehash() {
        let data = computeFacehash(name: "John")
        #expect(data.faceType == .curved)
        #expect(data.colorIndex == 4)
        #expect(data.rotation.x == -1)
        #expect(data.rotation.y == 1)
        #expect(data.initial == "J")
    }

    @Test("Alice produces correct facehash data")
    func aliceFacehash() {
        let data = computeFacehash(name: "Alice")
        #expect(data.faceType == .round)
        #expect(data.colorIndex == 3)
        #expect(data.rotation.x == -1)
        #expect(data.rotation.y == -1)
        #expect(data.initial == "A")
    }

    @Test("hello produces correct facehash data")
    func helloFacehash() {
        let data = computeFacehash(name: "hello")
        #expect(data.faceType == .line)
        #expect(data.colorIndex == 2)
        #expect(data.rotation.x == -1)
        #expect(data.rotation.y == -1)
        #expect(data.initial == "H")
    }

    @Test("test produces correct facehash data")
    func testFacehash() {
        let data = computeFacehash(name: "test")
        #expect(data.faceType == .line)
        #expect(data.colorIndex == 3)
        #expect(data.rotation.x == -1)
        #expect(data.rotation.y == 0)
        #expect(data.initial == "T")
    }

    @Test("Empty string produces correct facehash data")
    func emptyStringFacehash() {
        let data = computeFacehash(name: "")
        #expect(data.faceType == .round)
        #expect(data.colorIndex == 0)
        #expect(data.rotation.x == -1)
        #expect(data.rotation.y == 1)
        #expect(data.initial == "")
    }

    @Test("computeFacehash is deterministic")
    func deterministic() {
        let data1 = computeFacehash(name: "deterministic")
        let data2 = computeFacehash(name: "deterministic")
        #expect(data1.faceType == data2.faceType)
        #expect(data1.colorIndex == data2.colorIndex)
        #expect(data1.rotation.x == data2.rotation.x)
        #expect(data1.rotation.y == data2.rotation.y)
        #expect(data1.initial == data2.initial)
    }

    @Test("Custom colorsLength changes colorIndex")
    func customColorsLength() {
        let data3 = computeFacehash(name: "John", colorsLength: 3)
        #expect(data3.colorIndex == 2314539 % 3)
    }
}
