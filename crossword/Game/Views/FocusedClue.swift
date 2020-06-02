//
//  FocusedClue.swift
//  crossword
//
//  Created by Mason Zhang on 5/26/20.
//  Copyright © 2020 mason. All rights reserved.
//

import Foundation
import UIKit

class FocusedClue: UIView {
  //we use lazy properties for each view
  lazy var addButton: UIButton = {
    let addButton = UIButton(type: .contactAdd)
    addButton.frame = CGRect(x: 265, y: 5, width: 30, height: 30)
    return addButton
  }()
  
  lazy var contentView: UIImageView = {
    let contentView = UIImageView(frame: CGRect(x: 0, y: 40, width: 300, height: 260))
    contentView.image = UIImage(named: "WoodTexture")
    return contentView
  }()
  
  lazy var headerTitle: UILabel = {
    let headerTitle = UILabel(frame: CGRect(x: 0, y: 0, width: 300, height: 40))
    headerTitle.font = UIFont.systemFont(ofSize: 22, weight: .medium)
    headerTitle.text = "Custom View"
    headerTitle.backgroundColor = .green
    headerTitle.textAlignment = .center
    return headerTitle
  }()
  
  lazy var headerView: UIView = {
    let headerView = UIView(frame: CGRect(x: 0, y: 0, width: 300, height: 40))
    headerView.backgroundColor = UIColor(red: 22/255, green: 160/255, blue: 133/255, alpha: 0.5)
    headerView.layer.shadowColor = UIColor.gray.cgColor
    headerView.layer.shadowOffset = CGSize(width: 0, height: 10)
    headerView.layer.shadowOpacity = 1
    headerView.layer.shadowRadius = 5
    headerView.addSubview(headerTitle)
    headerView.addSubview(addButton)
    return headerView
  }()
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    setupView()
  }
  
  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    setupView()
  }
  
  private func setupView() {
    let label = UILabel()
    label.text = "HELLO"
    label.backgroundColor = .green
    addSubview(label)
    //addSubview(headerView)
  }
    
    @objc func a() {
        
    }
}
