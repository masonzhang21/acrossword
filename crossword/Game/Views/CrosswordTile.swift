//
//  CrosswordTile.swift
//  crossword
//
//  Created by Mason Zhang on 5/15/20.
//  Copyright © 2020 mason. All rights reserved.
//

import SwiftUI


struct CrosswordTile: UIViewRepresentable {
    
    @ObservedObject var vm: CrosswordVM
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
        guard let answer = vm.state.input[loc.row][loc.col] else {
            return
        }
        let tile = uiView as! UIStackView
        let label = tile.arrangedSubviews[0] as! UILabel
        let textfield = tile.arrangedSubviews[1] as! UITextField
        textfield.text = answer
        
        if vm.state.focusedTile == nil, textfield.isFirstResponder {
            textfield.resignFirstResponder()
        }
        if let focusedTile = vm.state.focusedTile, focusedTile == loc, vm.state.active{
            textfield.backgroundColor = Constants.Colors.focusedTile
            label.backgroundColor = Constants.Colors.focusedTile
            textfield.becomeFirstResponder()
        } else if let focusedWord = vm.state.currentWord, focusedWord.contains(loc) {
            textfield.backgroundColor = Constants.Colors.focusedWord
            label.backgroundColor = Constants.Colors.focusedWord
            
        } else {
            textfield.backgroundColor = Constants.Colors.unfocusedTile
            label.backgroundColor = Constants.Colors.unfocusedTile
            
        }
    }
    
    class XWordTextField: UITextField {
        override func deleteBackward() {
            let coordinator = delegate as! Coordinator
            coordinator.onEmptyDelete()
            super.deleteBackward()
        }
        
        override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
            return false
        }
    }
    
    class Coordinator: NSObject, UITextFieldDelegate {
        var parent: CrosswordTile
        
        init(_ parent: CrosswordTile) {
            self.parent = parent
        }
        
        @objc func onTap(_ gesture: UIGestureRecognizer) {
            if parent.loc == parent.vm.state.focusedTile {
                parent.vm.flipDirection()
            } else {
                parent.vm.focus(tile: parent.loc)
            }
        }
        
        func textFieldShouldReturn(_ textField: UITextField) -> Bool {
            parent.vm.clearFocus()
            return true
        }
        
        func onEmptyDelete() {
            parent.vm.prevTile()
        }
    
        
        
        func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
            //delete button pressed on nonempty tile
            if string.count == 0 {
                let focused = parent.vm.state.focusedTile!
                parent.vm.state.input[focused.row][focused.col] = ""
            }
                //character entered
            else if string.count == 1 {
                let wasEmpty: Bool = textField.text!.count == 0
                let rebus: Bool = parent.vm.state.rebus
                if rebus {
                    //TO-DO: Implement rebus
                } else {
                    let focused = parent.vm.state.focusedTile!
                    //textField.text = string
                    parent.vm.state.input[focused.row][focused.col] = string.uppercased()
                    parent.vm.nextTile(wasEmpty: wasEmpty)
                }
            }
            return false
        }
    }
}


