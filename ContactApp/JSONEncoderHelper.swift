//
//  JSONEncoderHelper.swift
//  ContactApp
//
//  Created by Hamzhya Salsatinnov on 18/05/23.
//

import Foundation

class JSONEncoderHelper {
    static func encode<T: Encodable>(_ value: T) -> Data? {
        let encoder = JSONEncoder()
        do {
            let jsonData = try encoder.encode(value)
            return jsonData
        } catch {
            print("Error encoding data: \(error)")
            return nil
        }
    }
}
