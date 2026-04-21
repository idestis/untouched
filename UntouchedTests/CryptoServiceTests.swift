import XCTest
@testable import Untouched

final class CryptoServiceTests: XCTestCase {

    func testSealOpenRoundTrip() throws {
        let plaintext = "I slipped. Had a drink at a party."
        let sealed = try CryptoService.seal(plaintext)
        let opened = try CryptoService.open(sealed)
        XCTAssertEqual(opened, plaintext)
    }

    func testSealProducesDifferentCiphertextEachTime() throws {
        let plaintext = "same input"
        let a = try CryptoService.seal(plaintext)
        let b = try CryptoService.seal(plaintext)
        XCTAssertNotEqual(a, b, "ChaChaPoly should produce distinct ciphertexts due to nonce")
    }

    func testOpenFailsOnTamperedBytes() throws {
        var sealed = try CryptoService.seal("original")
        // Flip one byte in the middle of the ciphertext.
        let mid = sealed.count / 2
        sealed[mid] ^= 0x01
        XCTAssertThrowsError(try CryptoService.open(sealed))
    }

    func testOpenFailsOnGarbage() {
        let garbage = Data([0x00, 0x01, 0x02, 0x03])
        XCTAssertThrowsError(try CryptoService.open(garbage))
    }

    func testEmptyStringRoundTrip() throws {
        let sealed = try CryptoService.seal("")
        let opened = try CryptoService.open(sealed)
        XCTAssertEqual(opened, "")
    }

    func testLongTextRoundTrip() throws {
        let plaintext = String(repeating: "confession text ", count: 1000)
        let sealed = try CryptoService.seal(plaintext)
        let opened = try CryptoService.open(sealed)
        XCTAssertEqual(opened, plaintext)
    }
}
