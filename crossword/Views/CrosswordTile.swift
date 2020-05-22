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
        let textField = UITextField()
        textField.delegate = context.coordinator
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(Coordinator.onTap(_:)))
        textField.addGestureRecognizer(tapGesture)
        return textField
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {
        let tile = uiView as! UITextField

        if let focusedTile = vm.state.focusedTile, focusedTile == loc {
            tile.backgroundColor = Constants.Colors.focusedTile
            tile.becomeFirstResponder()
        } else if let focusedWord = vm.state.currentWord, focusedWord.contains(loc) {
            tile.backgroundColor = Constants.Colors.focusedWord
        } else {
            tile.backgroundColor = Constants.Colors.unfocusedTile
        }
    }
    
    class Coordinator: NSObject, UITextFieldDelegate {
        var parent: CrosswordTile
        
        init(_ parent: CrosswordTile) {
            self.parent = parent
        }
        
        @objc func onTap(_ gesture: UIGestureRecognizer) {
            //this might have to be if (loc == vm.state.currentTile) {flip} else {change currentTile}
            parent.vm.flipDirection()
        }
        
        func textFieldShouldReturn(_ textField: UITextField) -> Bool {
            parent.vm.clearFocus()
            return true
        }
        
        func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
            //delete button pressed
            if string.count == 0 {
                if textField.text! == "" {
                    parent.vm.focusPrev()
                }
                return true
            }
            //character entered
            else if string.count == 1 {
                //TO-DO: if not in rebus mode (i.e. each tile contains a single character), go to next tile
                if true {
                    textField.text!.count == 0 ? parent.vm.focusNext(wasEmpty: true) : parent.vm.focusNext(wasEmpty: false)
                }
                return true
            }
            //multiple characters entered (paste)
            else {
                return false
            }
        }
    }
}
