//
//  SplitTriRow.swift
//  [CP] SplitTriRow
//
//  Created by Bret Pudenz on 11/30/18.
//  Copyright © 2018 MANDELKIND. All rights reserved.
//

import Eureka

open class _SplitTriRow<L: RowType, C: RowType, R: RowType>: Row<SplitTriRowCell<L,C,R>> where L: BaseRow, C: BaseRow, R: BaseRow{
    
    open override var section: Section?{
        get{ return super.section }
        set{
            rowLeft?.section = newValue
            rowCenter?.section = newValue
            rowRight?.section = newValue
            
            super.section = newValue
        }
    }
    
    open override func updateCell(){
        super.updateCell()
        
        self.rowLeft?.updateCell()
        self.rowLeft?.cell?.selectionStyle = .none
        
        self.rowCenter?.updateCell()
        self.rowCenter?.cell?.selectionStyle = .none
        
        self.rowRight?.updateCell()
        self.rowRight?.cell?.selectionStyle = .none
    }
    
    private(set) public var valueChanged = Set<SplitTriRowTag>()
    
    open override var value: SplitTriRowValue<L.Cell.Value, C.Cell.Value, R.Cell.Value>?{
        get{ return super.value }
        set{
            valueChanged = []
            if super.value?.left != newValue?.left {
                valueChanged.insert(.left)
            }
            if super.value?.center != newValue?.center {
                valueChanged.insert(.center)
            }
            if super.value?.right != newValue?.right {
                valueChanged.insert(.right)
            }
            
            if self.rowLeft?.value != newValue?.left{
                self.rowLeft?.value = newValue?.left
                valueChanged.insert(.left)
            }
            
            if self.rowCenter?.value != newValue?.center{
                self.rowCenter?.value = newValue?.center
                valueChanged.insert(.center)
            }
            
            if self.rowRight?.value != newValue?.right{
                self.rowRight?.value = newValue?.right
                valueChanged.insert(.right)
            }
            
            if false == valueChanged.isEmpty{
                super.value = newValue
            }
        }
    }
    
    @discardableResult
    open override func validate() -> [ValidationError] {
        let leftRowErrors = self.rowLeft!.validate()
        let centerRowErrors = self.rowCenter!.validate()
        let rightRowErrors = self.rowRight!.validate()
        return leftRowErrors + centerRowErrors + rightRowErrors
    }
    
    public enum SplitTriRowTag: String{
        case left,center,right
    }
    
    public var rowLeft: L?{
        willSet{
            newValue?.tag = SplitTriRowTag.left.rawValue
            guard let row = newValue else{ return }
            
            var rowValue = self.value ?? SplitTriRowValue<L.Cell.Value,C.Cell.Value,R.Cell.Value>()
            rowValue.left = row.value
            self.value = rowValue
            
            subscribe(onChange: row)
            subscribe(onCellHighlightChanged: row)
        }
    }
    public var rowLeftPercentage: CGFloat = 0.3
    
    public var rowCenter: C?{
        willSet{
            newValue?.tag = SplitTriRowTag.center.rawValue
            guard let row = newValue else{ return }
            
            var rowValue = self.value ?? SplitTriRowValue<L.Cell.Value,C.Cell.Value,R.Cell.Value>()
            rowValue.center = row.value
            self.value = rowValue
            
            subscribe(onChange: row)
            subscribe(onCellHighlightChanged: row)
        }
    }
    public var rowCenterPercentage: CGFloat = 0.3
    
    public var rowRight: R?{
        willSet{
            newValue?.tag = SplitTriRowTag.right.rawValue
            guard let row = newValue else{ return }
            
            var rowValue = self.value ?? SplitTriRowValue<L.Cell.Value,C.Cell.Value,R.Cell.Value>()
            rowValue.right = row.value
            self.value = rowValue
            
            subscribe(onChange: row)
            subscribe(onCellHighlightChanged: row)
        }
    }
    
    public var rowRightPercentage: CGFloat{
        return 1.0 - self.rowCenterPercentage - self.rowLeftPercentage
    }
    
    required public init(tag: String?) {
        super.init(tag: tag)
        cellProvider = CellProvider<SplitTriRowCell<L,C,R>>()
    }
    
    open func subscribe<T: RowType>(onChange row: T) where T: BaseRow{
        row.onChange{ [weak self] row in
            guard let strongSelf = self, let rowTagString = row.tag, let rowTag = SplitTriRowTag(rawValue: rowTagString) else{ return }
            strongSelf.cell?.update()  //TODO: This should only be done on cells which need an update. e.g. PushRow etc.
            
            var value = SplitTriRowValue<L.Cell.Value,C.Cell.Value,R.Cell.Value>()
            if rowTag == .left {
                value.left = row.value as? L.Cell.Value
                value.center = strongSelf.value?.center
                value.right = strongSelf.value?.right
            } else if rowTag == .center {
                value.left = strongSelf.value?.left
                value.center = row.value as? C.Cell.Value
                value.right = strongSelf.value?.right
            } else if rowTag == .right {
                value.left = strongSelf.value?.left
                value.center = strongSelf.value?.center
                value.right = row.value as? R.Cell.Value
            }
            
            strongSelf.value = value
        }
    }
    
    open func subscribe<T: RowType>(onCellHighlightChanged row: T) where T: BaseRow{
        row.onCellHighlightChanged{ [weak self] cell, row in
            guard let strongSelf = self,
                let splitRowCell = strongSelf.cell,
                let formViewController = strongSelf.cell.formViewController()
                else { return }
            
            if cell.isHighlighted || row.isHighlighted {
                formViewController.beginEditing(of: splitRowCell)
            } else {
                formViewController.endEditing(of: splitRowCell)
            }
        }
    }
    
}

public final class SplitTriRow<L: RowType, C: RowType, R: RowType>: _SplitTriRow<L,C,R>, RowType where L: BaseRow, C: BaseRow, R: BaseRow{}
