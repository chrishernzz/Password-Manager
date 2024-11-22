//
//  PasswordCryptoManger.swift
//  PasswordManager
//
//  Created by Christian Hernandez on 11/22/24.
//

import Foundation
import CryptoKit
import Security

struct PasswordCryptoManager {
    private static var key: SymmetricKey = {
        if let savedKey = KeychainHelper.retrieveKey() {
            return savedKey
        } else {
            let newKey = SymmetricKey(size: .bits256)
            KeychainHelper.saveKey(newKey)
            return newKey
        }
    }()

    static func encryptPassword(_ password: String) -> Data? {
        guard let passwordData = password.data(using: .utf8) else { return nil }
        do {
            let sealedBox = try AES.GCM.seal(passwordData, using: key)
            return sealedBox.combined
        } catch {
            print("Encryption failed: \(error.localizedDescription)")
            return nil
        }
    }

    static func decryptPassword(_ encryptedData: Data) -> String? {
        do {
            let sealedBox = try AES.GCM.SealedBox(combined: encryptedData)
            let decryptedData = try AES.GCM.open(sealedBox, using: key)
            return String(data: decryptedData, encoding: .utf8)
        } catch {
            print("Decryption failed: \(error.localizedDescription)")
            return nil
        }
    }
}

// Keychain Helper for storing/retrieving the key
struct KeychainHelper {
    private static let keychainKey = "com.example.PasswordManager.Key"

    static func saveKey(_ key: SymmetricKey) {
        let keyData = key.withUnsafeBytes { Data($0) }
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: keychainKey,
            kSecValueData as String: keyData
        ]
        SecItemAdd(query as CFDictionary, nil)
    }

    static func retrieveKey() -> SymmetricKey? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: keychainKey,
            kSecReturnData as String: true
        ]
        var item: CFTypeRef?
        if SecItemCopyMatching(query as CFDictionary, &item) == errSecSuccess {
            if let keyData = item as? Data {
                return SymmetricKey(data: keyData)
            }
        }
        return nil
    }
}


