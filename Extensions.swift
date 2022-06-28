//
//  Extensions.swift
//  ActivSync
//
//  Created by Bruno Henrique on 10/17/19.
//

import Foundation

public extension Date {
    func string() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        formatter.locale =  Locale(identifier: "en_US_POSIX")
        return formatter.string(from: self)
    }
}

extension JSONDecoder {
    func decode<T: Codable>(_ type: T.Type, fromURL url: String, completion: @escaping (T?) -> Void) {
        guard let url = URL(string: url) else {
            fatalError("Invalid URL passed.")
        }

        DispatchQueue.global().async {
            do {
                let data = try Data(contentsOf: url)
                let object = try self.decode(type, from:
                    data)

                DispatchQueue.main.async {
                    completion(object)
                }
            } catch {
                print(error.localizedDescription)
            }
        }
    }

    func decodeFromDict<T: Codable>(dictionary: [String: Any], to: T.Type) -> T? {
        do {
            let object = try self.decode(T.self, from: JSONSerialization.data(withJSONObject: dictionary))
            return object
        } catch(let error) {
            print(error)
            return nil
        }
    }
}
