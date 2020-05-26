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
    var loc: TileLoc
    
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
        //does this work? passes not by reference..
    }
    
    func makeUIView(context: Context) -> UIView {
        //subclass of UITextField that handles when the user presses delete on an empty TextField
        let textField = XWordTextField()
        if vm.scheme.grid[loc.row][loc.col] == nil {
            textField.isUserInteractionEnabled = false
            textField.backgroundColor = UIColor.black
        } else {
            textField.delegate = context.coordinator
            textField.addTarget(context.coordinator, action: #selector(Coordinator.onTap(_:)), for: .touchDown)
            
            if let tileNum = vm.scheme.gridnums[loc.row][loc.col] {
                //TO-DO: Make UILabel size responsive
                let label = UILabel(frame: CGRect(x: 2, y: 1, width: 10, height: 10))
                label.minimumScaleFactor = 0.1
                label.adjustsFontSizeToFitWidth = true
                label.lineBreakMode = .byClipping
                label.numberOfLines = 0
                label.textAlignment = .left
                label.text = String(tileNum)
                textField.addSubview(label)
                
            }
            textField.textAlignment = .center
            textField.tintColor = UIColor.clear
            textField.contentVerticalAlignment = .bottom
            
            //textField.adjustsFontSizeToFitWidth = true
            textField.minimumFontSize = 2
        }
        return textField
    }
    
    //TO-DO: disable for black tiles
    func updateUIView(_ uiView: UIView, context: Context) {
        guard let answer = vm.state.inputGrid[loc.row][loc.col] else {
            return
        }
        let tile = uiView as! UITextField
        tile.text = answer
        if let focusedTile = vm.state.focusedTile, focusedTile == loc {
            tile.backgroundColor = Constants.Colors.focusedTile
            tile.becomeFirstResponder()
        } else if let focusedWord = vm.state.currentWord, focusedWord.contains(loc) {
            tile.backgroundColor = Constants.Colors.focusedWord
        } else {
            tile.backgroundColor = Constants.Colors.unfocusedTile
        }
    }
    
    func deleteBackward() {
        vm.prevTile()
    }
    
    class XWordTextField: UITextField {
        override func deleteBackward() {
            let coordinator = delegate as! Coordinator
            coordinator.onEmptyDelete()
            super.deleteBackward()
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
                parent.vm.state.inputGrid[focused.row][focused.col] = ""
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
                    parent.vm.state.inputGrid[focused.row][focused.col] = string.uppercased()
                    parent.vm.nextTile(wasEmpty: wasEmpty)
                }
            }
            return false
        }
    }
}

