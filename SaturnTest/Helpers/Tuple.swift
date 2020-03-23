//
//  Tuple.swift
//  SaturnTest
//
//  Created by Bryan Gula on 3/22/20.
//  Copyright © 2020 Bryan Gula. All rights reserved.
//

import Foundation

struct Tuple {
    static func makeArray<Tuple, Value>(from tuple: Tuple) -> [Value] {
        let tupleMirror = Mirror(reflecting: tuple)
        assert(tupleMirror.displayStyle == .tuple, "Given argument is no tuple")
        assert(tupleMirror.superclassMirror == nil, "Given tuple argument must not have a superclass (is: \(tupleMirror.superclassMirror!)")
        assert(!tupleMirror.children.isEmpty, "Given tuple argument has no value elements")
        func convert(child: Mirror.Child) -> Value? {
            let valueMirror = Mirror(reflecting: child.value)
            assert(valueMirror.subjectType == Value.self, "Given tuple argument's child type (\(valueMirror.subjectType)) does not reflect expected return value type (\(Value.self))")
            return child.value as? Value
        }
        return tupleMirror.children.compactMap(convert)
    }
}
