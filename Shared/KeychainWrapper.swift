//
//  KeychainWrapper.swift
//
//  Created by Oliver Epper on 27.05.20.
//  Copyright © 2020 Oliver Epper. All rights reserved.
//

import Foundation

// This is a stripped down version of SwiftKeychainWraper
// https://github.com/jrendel/SwiftKeychainWrapper
class KeychainWrapper {
    static let standard = KeychainWrapper()

    private init() {}

    func string(forKey key: String) -> String? {
        guard let keychainData = data(forKey: key) else { return nil }

        return String(data: keychainData, encoding: .utf8)
    }

    func set(_ value: String, forKey key: String) {
        if let data = value.data(using: .utf8) {
            set(data, forKey: key)
        }
    }

    func bool(forKey key: String) -> Bool? {
        guard let keychainData = data(forKey: key) else { return nil }

        return try? NSKeyedUnarchiver.unarchivedObject(ofClass: NSNumber.self, from: keychainData)?.boolValue
    }

    func set(_ value: Bool, forKey key: String) {
        set(NSNumber(value: value), forKey: key)
    }

    func removeObject(forKey key: String) {
        let keychainQueryDictionary = setupKeychainQueryDictionary(forKey: key)
        SecItemDelete(keychainQueryDictionary as CFDictionary)
    }

    private func data(forKey key: String) -> Data? {
        var keychainQueryDictionary = setupKeychainQueryDictionary(forKey: key)
        keychainQueryDictionary[kSecMatchLimit as String] = kSecMatchLimitOne
        keychainQueryDictionary[kSecReturnData as String] = kCFBooleanTrue

        var result: AnyObject?
        let status = SecItemCopyMatching(keychainQueryDictionary as CFDictionary, &result)

        return status == noErr ? result as? Data : nil
    }

    private func set(_ data: Data, forKey key: String) {
        var keychainQueryDictionary = setupKeychainQueryDictionary(forKey: key)
        keychainQueryDictionary[kSecValueData as String] = data
        keychainQueryDictionary[kSecAttrAccessible as String] = kSecAttrAccessibleAfterFirstUnlock

        let status = SecItemAdd(keychainQueryDictionary as CFDictionary, nil)

        if status == errSecDuplicateItem {
            update(data, forKey: key)
        }
    }

    private func set(_ value: NSCoding, forKey key: String) {
        if let data = try? NSKeyedArchiver.archivedData(withRootObject: value, requiringSecureCoding: false) {
            set(data, forKey: key)
        }
        // as long as we're only called with bool values this WILL work
    }

    private func update(_ data: Data, forKey key: String) {
        let keychainQueryDictionary = setupKeychainQueryDictionary(forKey: key)
        let updateDictionary = [kSecValueData: data]

        SecItemUpdate(keychainQueryDictionary as CFDictionary, updateDictionary as CFDictionary)
    }

    private func setupKeychainQueryDictionary(forKey key: String) -> [String: Any] {
        var keychainQueryDictionary: [String: Any] = [kSecClass as String: kSecClassGenericPassword]
        keychainQueryDictionary[kSecAttrService as String] = Bundle.main.bundleIdentifier!

        keychainQueryDictionary[kSecAttrAccount as String] = key

        return keychainQueryDictionary
    }
}
