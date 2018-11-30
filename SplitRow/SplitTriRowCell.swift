//
//  SplitTriRowCell.swift
//  [CP] SplitTriRow
//
//  Created by Bret Pudenz on 11/30/18.
//  Copyright © 2018 MANDELKIND. All rights reserved.
//

import Eureka

open class SplitTriRowCell<L: RowType, C: RowType, R: RowType>: Cell<SplitTriRowValue<L.Cell.Value,C.Cell.Value,R.Cell.Value>>, CellType where L: BaseRow, C: BaseRow, R: BaseRow{
    var tableViewLeft: SplitTriRowCellTableView<L>!
    var tableViewCenter: SplitTriRowCellTableView<C>!
    var tableViewRight: SplitTriRowCellTableView<R>!
    
    open override var isHighlighted: Bool {
        get { return super.isHighlighted || (tableViewLeft.row?.cell?.isHighlighted ?? false) || (tableViewCenter.row?.cell?.isHighlighted ?? false) || (tableViewRight.row?.cell?.isHighlighted ?? false) }
        set { super.isHighlighted = newValue }
    }
    
    public required init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.tableViewLeft = SplitTriRowCellTableView()
        tableViewLeft.separatorStyle = .none
        tableViewLeft.leftSeparatorStyle = .none
        tableViewLeft.translatesAutoresizingMaskIntoConstraints = false
        
        self.tableViewCenter = SplitTriRowCellTableView()
        tableViewCenter.separatorStyle = .none
        tableViewCenter.leftSeparatorStyle = .none
        tableViewCenter.translatesAutoresizingMaskIntoConstraints = false
        
        self.tableViewRight = SplitTriRowCellTableView()
        tableViewRight.separatorStyle = .none
        tableViewRight.leftSeparatorStyle = .none
        tableViewRight.translatesAutoresizingMaskIntoConstraints = false
        
        contentView.addSubview(tableViewLeft)
        contentView.addConstraint(NSLayoutConstraint(item: tableViewLeft, attribute: .left, relatedBy: .equal, toItem: contentView, attribute: .left, multiplier: 1.0, constant: 0.0))
        
        contentView.addSubview(tableViewCenter)
        
        contentView.addSubview(tableViewRight)
        contentView.addConstraint(NSLayoutConstraint(item: tableViewRight, attribute: .right, relatedBy: .equal, toItem: contentView, attribute: .right, multiplier: 1.0, constant: 0.0))
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    open override func setup(){
        selectionStyle = .none
        
        //ignore Xcode Cast warning here, it works!
        guard let row = self.row as? _SplitTriRow<L,C, R> else{ return }
        
        //TODO: If we use UITableViewAutomaticDimension instead of 44.0 we encounter constraint errors :(
        let maxRowHeight = max(row.rowLeft?.cell?.height?() ?? 44.0, row.rowRight?.cell?.height?() ?? 44.0)
        if maxRowHeight != UITableViewAutomaticDimension{
            self.height = { maxRowHeight }
            row.rowLeft?.cell?.height = self.height
            row.rowRight?.cell?.height = self.height
        }
        
        tableViewLeft.row = row.rowLeft
        tableViewLeft.isScrollEnabled = false
        tableViewLeft.setup()
        
        tableViewCenter.row = row.rowCenter
        tableViewCenter.isScrollEnabled = false
        tableViewCenter.setup()
        
        tableViewRight.row = row.rowRight
        tableViewRight.isScrollEnabled = false
        tableViewRight.setup()
        
        setupConstraints()
    }
    
    
    open override func update(){
        tableViewLeft.update()
        tableViewCenter.update()
        tableViewRight.update()
    }
    
    private func setupConstraints(){
        guard let row = self.row as? _SplitTriRow<L,C,R> else{ return }
        
        if let height = self.height?(){
            self.contentView.addConstraint(NSLayoutConstraint(item: tableViewLeft, attribute: .height, relatedBy: .greaterThanOrEqual, toItem: nil, attribute: .height, multiplier: 1.0, constant: height))
            self.contentView.addConstraint(NSLayoutConstraint(item: tableViewCenter, attribute: .height, relatedBy: .greaterThanOrEqual, toItem: nil, attribute: .height, multiplier: 1.0, constant: height))
            self.contentView.addConstraint(NSLayoutConstraint(item: tableViewRight, attribute: .height, relatedBy: .greaterThanOrEqual, toItem: nil, attribute: .height, multiplier: 1.0, constant: height))
        }
        
        self.contentView.addConstraint(NSLayoutConstraint(item: tableViewLeft, attribute: .width, relatedBy: .equal, toItem: contentView, attribute: .width, multiplier: row.rowLeftPercentage, constant: -5.0))
        self.contentView.addConstraint(NSLayoutConstraint(item: tableViewCenter, attribute: .width, relatedBy: .equal, toItem: contentView, attribute: .width, multiplier: row.rowCenterPercentage, constant: -5.0))
        self.contentView.addConstraint(NSLayoutConstraint(item: tableViewCenter, attribute: .centerX, relatedBy: .equal, toItem: contentView, attribute: .centerX, multiplier: 1.0, constant: 0.0))
        self.contentView.addConstraint(NSLayoutConstraint(item: tableViewRight, attribute: .width, relatedBy: .equal, toItem: contentView, attribute: .width, multiplier: row.rowRightPercentage, constant: -5.0))
    }
    
    private func rowCanBecomeFirstResponder(_ row: BaseRow?) -> Bool{
        guard let row = row else{ return false }
        return false == row.isDisabled && row.baseCell?.cellCanBecomeFirstResponder() ?? false
    }
    
    open override var isFirstResponder: Bool{
        guard let row = self.row as? _SplitTriRow<L,C,R> else{ return false }
        
        let rowLeftFirstResponder = row.rowLeft?.cell.findFirstResponder()
        let rowCenterFirstResponder = row.rowCenter?.cell?.findFirstResponder()
        let rowRightFirstResponder = row.rowRight?.cell?.findFirstResponder()
        
        return rowLeftFirstResponder != nil || rowCenterFirstResponder != nil || rowRightFirstResponder != nil
    }
    
    open override func cellCanBecomeFirstResponder() -> Bool{
        guard let row = self.row as? _SplitTriRow<L,C,R> else{ return false }
        guard false == row.isDisabled else{ return false }
        
        let rowLeftFirstResponder = row.rowLeft?.cell.findFirstResponder()
        let rowCenterFirstResponder = row.rowCenter?.cell?.findFirstResponder()
        let rowRightFirstResponder = row.rowRight?.cell?.findFirstResponder()
        
        if rowLeftFirstResponder == nil && rowCenterFirstResponder == nil && rowRightFirstResponder == nil{
            return rowCanBecomeFirstResponder(row.rowLeft) || rowCanBecomeFirstResponder(row.rowCenter) || rowCanBecomeFirstResponder(row.rowRight)
            
        } else if rowLeftFirstResponder == nil{
            return rowCanBecomeFirstResponder(row.rowLeft)
            
        } else if rowCenterFirstResponder == nil{
            return rowCanBecomeFirstResponder(row.rowCenter)
            
        } else if rowRightFirstResponder == nil{
            return rowCanBecomeFirstResponder(row.rowRight)
        }
        
        return false
    }
    
    open override func cellBecomeFirstResponder(withDirection: Direction) -> Bool {
        guard let row = self.row as? _SplitTriRow<L,C,R> else{ return false }
        
        let rowLeftFirstResponder = row.rowLeft?.cell.findFirstResponder()
        let rowLeftCanBecomeFirstResponder = rowCanBecomeFirstResponder(row.rowLeft)
        var isFirstResponder = false
        
        let rowCenterFirstResponder = row.rowCenter?.cell.findFirstResponder()
        let rowCenterCanBecomeFirstResponder = rowCanBecomeFirstResponder(row.rowCenter)
        
        let rowRightFirstResponder = row.rowRight?.cell?.findFirstResponder()
        let rowRightCanBecomeFirstResponder = rowCanBecomeFirstResponder(row.rowRight)
        
        if withDirection == .down{
            if rowLeftFirstResponder == nil, rowLeftCanBecomeFirstResponder{
                isFirstResponder = row.rowLeft?.cell?.cellBecomeFirstResponder(withDirection: withDirection) ?? false
                
            } else if rowCenterFirstResponder == nil, rowCenterCanBecomeFirstResponder{
                isFirstResponder = row.rowCenter?.cell?.cellBecomeFirstResponder(withDirection: withDirection) ?? false
                
            } else if rowRightFirstResponder == nil, rowRightCanBecomeFirstResponder{
                isFirstResponder = row.rowRight?.cell?.cellBecomeFirstResponder(withDirection: withDirection) ?? false
            }
            
        } else if withDirection == .up{
            if rowRightFirstResponder == nil, rowRightCanBecomeFirstResponder{
                isFirstResponder = row.rowRight?.cell?.cellBecomeFirstResponder(withDirection: withDirection) ?? false
                
            } else if rowLeftFirstResponder == nil, rowLeftCanBecomeFirstResponder{
                isFirstResponder = row.rowLeft?.cell?.cellBecomeFirstResponder(withDirection: withDirection) ?? false
            }
        }
        
        if isFirstResponder {
            formViewController()?.beginEditing(of: self)
        }
        
        return isFirstResponder
    }
    
    open override func cellResignFirstResponder() -> Bool{
        guard let row = self.row as? _SplitTriRow<L,C,R> else{ return false }
        
        let rowLeftResignFirstResponder = row.rowLeft?.cell?.cellResignFirstResponder() ?? false
        let rowCenterResignFirstResponder = row.rowCenter?.cell?.cellResignFirstResponder() ?? false
        let rowRightResignFirstResponder = row.rowRight?.cell?.cellResignFirstResponder() ?? false
        let resignedFirstResponder = rowLeftResignFirstResponder && rowCenterResignFirstResponder && rowRightResignFirstResponder
        
        if resignedFirstResponder {
            formViewController()?.endEditing(of: self)
        }
        
        return resignedFirstResponder
    }
}
