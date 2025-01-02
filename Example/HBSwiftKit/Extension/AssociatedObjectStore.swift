//
//  AssociatedObjectStore.swift
//  HBSwiftKit_Example
//
//  Created by hubin.h on 2025/1/2.

import Foundation

public protocol AssociatedObjectStore { }

extension AssociatedObjectStore {
    func associatedObject<T>(forKey key: UnsafeRawPointer) -> T? {
        return objc_getAssociatedObject(self, key) as AnyObject as? T
    }

    func associatedObject<T>(forKey key: UnsafeRawPointer, default: @autoclosure () -> T, ploicy: objc_AssociationPolicy = .OBJC_ASSOCIATION_RETAIN_NONATOMIC) -> T {
        if let object: T = self.associatedObject(forKey: key) {
            return object
        }
        let object = `default`()
        self.setAssociatedObject(object, forKey: key, ploicy: ploicy)
        return object
    }

    func setAssociatedObject<T>(_ object: T?, forKey key: UnsafeRawPointer, ploicy: objc_AssociationPolicy = .OBJC_ASSOCIATION_RETAIN_NONATOMIC) {
        objc_setAssociatedObject(self, key, object, ploicy)
    }
}
