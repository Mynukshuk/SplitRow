//
//  SplitTriRowValue.swift
//  [CP] SplitRow
//
//  Created by Bret Pudenz on 11/30/18.
//  Copyright © 2018 MANDELKIND. All rights reserved.
//

import Eureka

public struct SplitTriRowValue<L: Equatable, C: Equatable, R: Equatable>{
    public var left: L?
    public var center: C?
    public var right: R?
    
    public init(left: L?, center: C?, right: R?){
        self.left = left
        self.center = center
        self.right = right
    }
    
    public init(){}
}

extension SplitTriRowValue: Equatable{
    public static func == (lhs: SplitTriRowValue,rhs: SplitTriRowValue) -> Bool{
        return lhs.left == rhs.left && lhs.right == rhs.right
    }
}
