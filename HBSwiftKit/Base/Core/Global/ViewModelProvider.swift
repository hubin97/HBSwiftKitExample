//
//  ViewModel.swift
//  Momcozy
//
//  Created by hubin.h on 2024/7/4.
//  Copyright © 2020 路特创新. All rights reserved.

import Foundation

open class ViewModel: NSObject {

    required public override init() {}
    deinit {
        print("\(type(of: self)): Deinited")
        //logResourcesCount()
    }
}

/// `ViewModel: Input, Output`
///
/// 提供输入输出转换方法
public protocol ViewModelTransformable {
    associatedtype Input
    associatedtype Output

    func transform(input: Input) -> Output
}

/// `ViewModelProvider: T -> VM`
///
/// `规避后续使用泛型冲突, T改为ViewModelType`
/// 提供ViewModel的声明和转换
public protocol ViewModelProvider: AnyObject {
    associatedtype ViewModelType: ViewModel
    
    var viewModel: ViewModel? { get set }
    var vm: ViewModelType { get }
}

extension ViewModelProvider {
    public var vm: ViewModelType {
        return viewModel as? ViewModelType ?? ViewModelType()
    }
}
