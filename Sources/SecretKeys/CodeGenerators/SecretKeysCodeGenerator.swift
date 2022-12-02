// The MIT License (MIT)
//
// Copyright (c) 2022 Tomoya Hayakawa (github.com/simorgh3196).

import Foundation

enum SecretKeysCodeGenerator {
    static func generateCode(namespace: String,
                             secrets: [Secret],
                             salt: [UInt8],
                             encoder: SecretValueEncoder) -> String {
        """
        // DO NOT MODIFY
        // Automatically generated by SecretKeys (https://github.com/simorgh3196/SecretKeys)

        import Foundation
        import SecretValueDecoder

        public enum \(namespace) {
            private static let decoder = SecretValueDecoder()

            private static let salt: [UInt8] = [
                \(convertBytesTo16RadixString(from: salt))
            ]
            \(secrets.map { generateSecretCode($0, salt: salt, encoder: encoder) }.joined(separator: "\n"))
        }

        """
    }

    @inline(__always)
    private static func generateSecretCode(_ secret: Secret, salt: [UInt8], encoder: SecretValueEncoder) -> String {
        """

            @inline(__always)
            public static let \(secret.key): \(secret.value.type) = {
                let encodedBytes: [UInt8] = [
                    \(convertBytesTo16RadixString(from: encoder.encode(value: secret.value, with: salt)))
                ]
                return try! Self.decoder.decode(bytes: encodedBytes, with: Self.salt)
            }()
        """
    }

    @inline(__always)
    private static func convertBytesTo16RadixString(from bytes: [UInt8]) -> String {
        bytes.map { "0x" + String($0, radix: 16) }.joined(separator: ", ")
    }
}

