import Foundation
import CryptoKit
import Security

/// Seals and opens confession text using ChaChaPoly and a persistent key in
/// the Keychain. The key is shared via an access group with the widget
/// extension so it can read historical coins (but confessions are not read
/// by widgets — see SPEC §16.9).
enum CryptoService {
    private static let keyTag = "app.getuntouched.confessionKey"
    private static let syncedCoinKeyTag = "app.getuntouched.coinBackupKey"
    private static let accessGroup: String? = nil // set via entitlements if needed

    enum CryptoError: Error {
        case keychainStoreFailed(OSStatus)
        case keyMissing
        case openFailed
    }

    static func seal(_ plaintext: String) throws -> Data {
        let key = try loadOrCreateKey()
        let box = try ChaChaPoly.seal(Data(plaintext.utf8), using: key)
        return box.combined
    }

    static func open(_ sealed: Data) throws -> String {
        let key = try loadKey()
        let box = try ChaChaPoly.SealedBox(combined: sealed)
        let plain = try ChaChaPoly.open(box, using: key)
        guard let s = String(data: plain, encoding: .utf8) else { throw CryptoError.openFailed }
        return s
    }

    // MARK: - iCloud-synced key (for coin backup)
    //
    // A separate symmetric key that syncs via iCloud Keychain so any device
    // signed in to the same Apple ID can decrypt the coin backup blobs.
    // Confessions do NOT use this key — they stay local-only.

    static func sealWithSyncedKey(_ data: Data) throws -> Data {
        let key = try loadOrCreateSyncedKey()
        return try ChaChaPoly.seal(data, using: key).combined
    }

    static func openWithSyncedKey(_ sealed: Data) throws -> Data {
        let key = try loadSyncedKey()
        let box = try ChaChaPoly.SealedBox(combined: sealed)
        return try ChaChaPoly.open(box, using: key)
    }

    // MARK: - Keychain

    private static func loadOrCreateKey() throws -> SymmetricKey {
        if let k = try? loadKey() { return k }
        let k = SymmetricKey(size: .bits256)
        try storeKey(k)
        return k
    }

    private static func loadKey() throws -> SymmetricKey {
        var query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: keyTag,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne,
        ]
        if let group = accessGroup { query[kSecAttrAccessGroup as String] = group }

        var item: CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &item)
        guard status == errSecSuccess, let data = item as? Data else {
            throw CryptoError.keyMissing
        }
        return SymmetricKey(data: data)
    }

    private static func storeKey(_ key: SymmetricKey) throws {
        let data = key.withUnsafeBytes { Data($0) }
        var attrs: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: keyTag,
            kSecValueData as String: data,
            kSecAttrAccessible as String: kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly,
        ]
        if let group = accessGroup { attrs[kSecAttrAccessGroup as String] = group }

        // Replace if already present.
        SecItemDelete(attrs as CFDictionary)
        let status = SecItemAdd(attrs as CFDictionary, nil)
        guard status == errSecSuccess else { throw CryptoError.keychainStoreFailed(status) }
    }

    // MARK: - Synced key helpers

    private static func loadOrCreateSyncedKey() throws -> SymmetricKey {
        if let k = try? loadSyncedKey() { return k }
        let k = SymmetricKey(size: .bits256)
        try storeSyncedKey(k)
        return k
    }

    private static func loadSyncedKey() throws -> SymmetricKey {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: syncedCoinKeyTag,
            kSecAttrSynchronizable as String: kCFBooleanTrue as Any,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne,
        ]
        var item: CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &item)
        guard status == errSecSuccess, let data = item as? Data else {
            throw CryptoError.keyMissing
        }
        return SymmetricKey(data: data)
    }

    private static func storeSyncedKey(_ key: SymmetricKey) throws {
        let data = key.withUnsafeBytes { Data($0) }
        let attrs: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: syncedCoinKeyTag,
            kSecValueData as String: data,
            kSecAttrAccessible as String: kSecAttrAccessibleAfterFirstUnlock,
            kSecAttrSynchronizable as String: kCFBooleanTrue as Any,
        ]
        let delQuery: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: syncedCoinKeyTag,
            kSecAttrSynchronizable as String: kCFBooleanTrue as Any,
        ]
        SecItemDelete(delQuery as CFDictionary)
        let status = SecItemAdd(attrs as CFDictionary, nil)
        guard status == errSecSuccess else { throw CryptoError.keychainStoreFailed(status) }
    }
}
