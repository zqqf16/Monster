//
//  DecodeableDefault.swift
//  Monster
//
//  Created by zqqf16 on 2022/9/9.
//  Copyright © 2022 zqqf16. All rights reserved.
//

/// https://onevcat.com/2020/11/codable-default/
import Foundation

protocol DefaultValue {
    associatedtype Value: Decodable
    static var defaultValue: Value { get }
}

@propertyWrapper
struct Default<T: DefaultValue> {
    var wrappedValue: T.Value
}

extension Default: Decodable {
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        wrappedValue = (try? container.decode(T.Value.self)) ?? T.defaultValue
    }
}

extension KeyedDecodingContainer {
    func decode<T>(
        _ type: Default<T>.Type,
        forKey key: Key
    ) throws -> Default<T> where T: DefaultValue {
        try decodeIfPresent(type, forKey: key) ?? Default(wrappedValue: T.defaultValue)
    }
}

extension Bool {
    enum False: DefaultValue {
        static let defaultValue = false
    }
    enum True: DefaultValue {
        static let defaultValue = true
    }
}

extension String {
    enum Empty: DefaultValue {
        static let defaultValue: Optional<String> = nil
    }
}

extension Array where Element: Decodable {
    enum Empty: DefaultValue {
        static var defaultValue: [Element] { [] }
    }
}

extension Dictionary where Key: Decodable, Value: Decodable {
    enum Empty: DefaultValue {
        static var defaultValue: [Key: Value] { [:] }
    }
}

extension StorageSize {
    enum Disk: DefaultValue {
        static let defaultValue = 30.GB
    }
    enum Memory: DefaultValue {
        static let defaultValue = 4.GB
    }
}

extension Default {
    typealias True = Default<Bool.True>
    typealias False = Default<Bool.False>
    typealias EmptyString = Default<String.Empty>
    typealias EmptyList<T: Decodable> = Default<Array<T>.Empty>
    typealias EmptyDictionary<Key: Hashable & Decodable, Value: Decodable> = Default<Dictionary<Key, Value>.Empty>
    typealias Disk = Default<StorageSize.Disk>
    typealias Memory = Default<StorageSize.Memory>
}
