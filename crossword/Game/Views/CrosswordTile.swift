//
//  CrosswordTile.swift
//  crossword
//
//  Created by Mason Zhang on 5/15/20.
//  Copyright © 2020 mason. All rights reserved.
//

import SwiftUI


struct CrosswordTile: UIViewRepresentable {
    
    var vm: CrosswordVM
    @ObservedObject var tile: TileState

    let loc: TileLoc
    
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    func makeUIView(context: Context) -> UIView {
        //subclass of UITextField that handles when the user presses delete on an empty TextField
        let textField = XWordTextField()
        textField.delegate = context.coordinator
        textField.addTarget(context.coordinator, action: #selector(Coordinator.onTap(_:)), for: .touchDown)
        textField.textAlignment = .center
        textField.tintColor = UIColor.clear
        textField.contentVerticalAlignment = .bottom
        textField.keyboardType = .alphabet
        textField.autocorrectionType = .no
        textField.inputAccessoryView = FocusedClue()
        //textField.adjustsFontSizeToFitWidth = true
        textField.minimumFontSize = 2
        
        let label = UILabel()
        label.font = label.font.withSize(8)
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.1
        label.lineBreakMode = .byClipping
        label.numberOfLines = 0
        label.textAlignment = .left
        
        if let tileNum = vm.scheme.gridnums[loc.row][loc.col] {
            label.text = String(tileNum)
        } else {
            label.text = ""
        }
        
        let stackedInfoView = UIStackView(arrangedSubviews: [label, textField])
        stackedInfoView.axis = .vertical
        stackedInfoView.distribution = .fillProportionally
        return stackedInfoView
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {
        let container = uiView as! UIStackView
        let label = container.arrangedSubviews[0] as! UILabel
        let textfield = container.arrangedSubviews[1] as! UITextField
        
        textfield.text = tile.text
        
        if textfield.isFirstResponder, vm.state.focusedTile == nil {
            textfield.resignFirstResponder()
        }
        if tile.isFocused {
            textfield.backgroundColor = Constants.Colors.currentTile
            label.backgroundColor = Constants.Colors.currentTile
            textfield.becomeFirstResponder()
        } else if tile.isCurrentTile {
            textfield.backgroundColor = Constants.Colors.currentTile
            label.backgroundColor = Constants.Colors.currentTile
        } else if tile.isCurrentWord {
            textfield.backgroundColor = Constants.Colors.currentWord
            label.backgroundColor = Constants.Colors.currentWord
        } else {
            textfield.backgroundColor = Constants.Colors.defaultTile
            label.backgroundColor = Constants.Colors.defaultTile
        }
    }
    
    class XWordTextField: UITextField {
        override func deleteBackward() {
            let coordinator = delegate as! Coordinator
            coordinator.onEmptyBackspace()
            super.deleteBackward()
        }
        
        override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
            return false
        }
        
        override public var selectedTextRange: UITextRange? {
            get {
                return nil
            }
            set { }
        }
    }
    
    class Coordinator: NSObject, UITextFieldDelegate {
        var parent: CrosswordTile
        
        init(_ parent: CrosswordTile) {
            self.parent = parent
        }
        
        @objc func onTap(_ gesture: UIGestureRecognizer) {
            if parent.tile.isFocused {
                parent.vm.flipDirection()
            } else {
                parent.vm.focus(tile: parent.loc)
            }
        }
        
        func textFieldShouldReturn(_ textField: UITextField) -> Bool {
            parent.vm.toggleBoard()
            return true
        }
        
        func onEmptyBackspace() {
            parent.vm.prevTile()
        }
    
        
        
        func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
            //delete button pressed on nonempty tile
            if string.count == 0 {
                //parent.tile.text = ""
                let curTile = parent.vm.state.currentTile
                parent.vm.state.input[curTile.row][curTile.col] = ""
            }
                //character entered
            else if string.count == 1 {
                let wasEmpty: Bool = textField.text!.count == 0
                if parent.vm.state.rebusMode {
                    //TO-DO: Implement rebus
                } else {
                    //parent.tile.text = string.uppercased()
                    let curTile = parent.vm.state.currentTile
                    parent.vm.state.input[curTile.row][curTile.col] = string.uppercased()
                    parent.vm.nextTile(wasEmpty: wasEmpty)
                }
            }
            return false
        }
    }
}


