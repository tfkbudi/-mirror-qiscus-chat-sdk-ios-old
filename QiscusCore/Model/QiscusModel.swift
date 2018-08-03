//
//  QiscusModel.swift
//  QiscusCore
//
//  Created by Qiscus on 02/08/18.
//  Credits :
//  Thanks to Sergio Schechtman Sette for https://medium.com/grand-parade/parsing-fields-in-codable-structs-that-can-be-of-any-json-type-e0283d5edb

import Foundation

public enum JSONValue: Codable {
    case string(String)
    case int(Int)
    case double(Double)
    case bool(Bool)
    case object([String: JSONValue])
    case array([JSONValue])
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        self = try ((try? container.decode(String.self)).map(JSONValue.string))
            .or((try? container.decode(Int.self)).map(JSONValue.int))
            .or((try? container.decode(Double.self)).map(JSONValue.double))
            .or((try? container.decode(Bool.self)).map(JSONValue.bool))
            .or((try? container.decode([String: JSONValue].self)).map(JSONValue.object))
            .or((try? container.decode([JSONValue].self)).map(JSONValue.array))
            .resolve(with: DecodingError.typeMismatch(JSONValue.self, DecodingError.Context(codingPath: container.codingPath, debugDescription: "Not a JSON")))
    }
    
    public func encode(to encoder: Encoder) throws {
        // MARK: TODO try to encode
    }
}

extension Optional {
    func or(_ other: Optional) -> Optional {
        switch self {
        case .none: return other
        case .some: return self
        }
    }
    
    func resolve(with error: @autoclosure () -> Error) throws -> Wrapped {
        switch self {
        case .none: throw error()
        case .some(let wrapped): return wrapped
        }
    }
}
