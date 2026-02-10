import Foundation

/// Generates a consistent numeric hash from a string.
/// Used to deterministically select faces and colors for avatars.
///
/// Operates on UTF-16 code units with 32-bit signed integer overflow semantics.
///
/// - Parameter str: The input string to hash
/// - Returns: A non-negative integer hash
public func stringHash(_ str: String) -> Int {
    var hash: Int32 = 0
    for codeUnit in str.utf16 {
        let char = Int32(codeUnit)
        hash = (hash &<< 5) &- hash &+ char
    }
    // Return as Int to avoid overflow on Int32.min
    // (matches JS Math.abs which returns 2147483648 for Int32.min)
    return Int(hash < 0 ? Int64(hash) * -1 : Int64(hash))
}
