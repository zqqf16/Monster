//
//  AppSettings.swift
//  Monster
//
//  Created by zqqf16 on 2022/9/4.
//  Copyright © 2022 zqqf16. All rights reserved.
//

import Foundation
import SwiftUI
import Combine

/// https://www.avanderlee.com/swift/appstorage-explained/

@propertyWrapper
struct UserDefault<Value> {
    let key: String
    let defaultValue: Value

    var wrappedValue: Value {
        get { fatalError("Wrapped value should not be used.") }
        set { fatalError("Wrapped value should not be used.") }
    }
    
    init(wrappedValue: Value, _ key: String) {
        self.defaultValue = wrappedValue
        self.key = key
    }
    
    public static subscript(
        _enclosingInstance instance: AppSettings,
        wrapped wrappedKeyPath: ReferenceWritableKeyPath<AppSettings, Value>,
        storage storageKeyPath: ReferenceWritableKeyPath<AppSettings, Self>
    ) -> Value {
        get {
            let container = instance.userDefaults
            let key = instance[keyPath: storageKeyPath].key
            let defaultValue = instance[keyPath: storageKeyPath].defaultValue
            return container.object(forKey: key) as? Value ?? defaultValue
        }
        set {
            let container = instance.userDefaults
            let key = instance[keyPath: storageKeyPath].key
            container.set(newValue, forKey: key)
            instance.settingsChangedSubject.send(wrappedKeyPath)
        }
    }
}

final class AppSettings {
    
    static let standard = AppSettings(userDefaults: .standard)
    fileprivate let userDefaults: UserDefaults
    
    /// Sends through the changed key path whenever a change occurs.
    var settingsChangedSubject = PassthroughSubject<AnyKeyPath, Never>()
    
    init(userDefaults: UserDefaults) {
        self.userDefaults = userDefaults
    }
    
    @UserDefault("vmDirectory")
    var vmDirectory = FileManager.appSupportDirectory

    @UserDefault("deleteVMFiles")
    var deleteVMFiles = true
    
    @UserDefault("showDockIcon")
    var showDockIcon = true
}

final class PublisherObservableObject: ObservableObject {
    var subscriber: AnyCancellable?
    init(publisher: AnyPublisher<Void, Never>) {
        subscriber = publisher.sink(receiveValue: { [weak self] _ in
            self?.objectWillChange.send()
        })
    }
}

@propertyWrapper
struct AppSetting<Value>: DynamicProperty {
    
    @ObservedObject private var settingsObserver: PublisherObservableObject
    private let keyPath: ReferenceWritableKeyPath<AppSettings, Value>
    private let settings: AppSettings
    
    init(_ keyPath: ReferenceWritableKeyPath<AppSettings, Value>, settings: AppSettings = .standard) {
        self.keyPath = keyPath
        self.settings = settings
        let publisher = settings
            .settingsChangedSubject
            .filter { changedKeyPath in
                changedKeyPath == keyPath
            }.map { _ in () }
            .eraseToAnyPublisher()
        self.settingsObserver = .init(publisher: publisher)
    }

    var wrappedValue: Value {
        get { settings[keyPath: keyPath] }
        nonmutating set { settings[keyPath: keyPath] = newValue }
    }

    var projectedValue: Binding<Value> {
        Binding(
            get: { wrappedValue },
            set: { wrappedValue = $0 }
        )
    }
}
