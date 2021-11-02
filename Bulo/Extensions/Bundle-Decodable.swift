//
//  Bundle-Decodable.swift
//  Bulo
//
//  Created by Jake King on 20/10/2021.
//

import Foundation

extension Bundle {
    /// Locates, loads, and decodes a given JSON file from the app bundle.
    /// - Parameter type: The type of data to decode the JSON into.
    /// - Parameter file: The name of the file in the bundle to decode.
    /// - Parameter dateDecodingStrategy: The date decoding strategy used by the JSON decoder.
    /// Default value is .deferredToDate.
    /// - Parameter keyDecodingStrategy: The key decoding strategy used by the JSON decoder.
    /// Default value is .useDefaultKeys
    /// - Returns: The decoded JSON data contained in the file.
    func decode<T: Decodable>(
        _ type: T.Type,
        from file: String,
        dateDecodingStrategy: JSONDecoder.DateDecodingStrategy = .deferredToDate,
        keyDecodingStrategy: JSONDecoder.KeyDecodingStrategy = .useDefaultKeys
    ) -> T {
        guard let url = self.url(forResource: file, withExtension: nil) else {
            fatalError("Failed to locate \(file) in bundle.")
        }

        guard let data = try? Data(contentsOf: url) else {
            fatalError("Failed to load \(file) from bundle.")
        }

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = dateDecodingStrategy
        decoder.keyDecodingStrategy = keyDecodingStrategy

        do {
            return try decoder.decode(T.self, from: data)
        } catch DecodingError.keyNotFound(let key, let context) {
            fatalError(
                "Failed to decode \(file): missing key '\(key.stringValue)' not found - \(context.debugDescription)"
            )
        } catch DecodingError.typeMismatch(_, let context) {
            fatalError(
                "Failed to decode \(file): type mismatch - \(context.debugDescription)"
            )
        } catch DecodingError.valueNotFound(let type, let context) {
            fatalError(
                "Failed to decode \(file): missing \(type) value - \(context.debugDescription)"
            )
        } catch DecodingError.dataCorrupted(_) {
            fatalError(
                "Failed to decode \(file): invalid JSON."
            )
        } catch {
            fatalError(
                "Failed to decode \(file): \(error.localizedDescription)"
            )
        }
    }
}
