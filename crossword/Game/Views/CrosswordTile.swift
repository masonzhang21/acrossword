//
//  CrosswordTile.swift
//  crossword
//
//  Created by Mason Zhang on 5/15/20.
//  Copyright © 2020 mason. All rights reserved.
//

import SwiftUI


struct CrosswordTile: UIViewRepresentable {
    
    var core: CrosswordCore
    var actions: BoardActions
    @ObservedObject var tile: TileState
    
    let loc: TileLoc
    
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    func makeClueDisplay() -> UIView {
        //computed property clueNum and clue, derived from currentWord or smth which are observable
        return UIView()
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
        
        //UIHostingController's view's center is originally set to the top left corner of its parent view, and so cluePanel is vertically and horizontally centered on the its parent's top left point. In order for cluePanel to be correctly aligned with the keyboard, it's placed inside an invisible UIView (cluePanelContainer) with the same dimensions as cluePanel, and its center is shifted to the center point of cluePanelContainer's frame.
        let cluePanelContainer = UIView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: 60))
        let cluePanel = UIHostingController(rootView: CluePanel(actions: actions, core: core, clueTracker: core.state.clueTracker)).view!
        cluePanel.center = CGPoint(x: cluePanelContainer.frame.size.width  / 2, y: cluePanelContainer.frame.size.height / 2)
        cluePanelContainer.addSubview(cluePanel)
        textField.inputAccessoryView = cluePanelContainer
        
        /*
        let toolBar = UIToolbar(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: 60))
        let doneButton = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(actions.nextWord))
        toolBar.items = [doneButton]
        toolBar.setItems([doneButton], animated: true)
        textField.inputAccessoryView = toolBar*/
        
        
        //labelContainer used to get some top padding
        let labelContainer = UIView(frame: CGRect(x: 0, y: 0, width: 50, height: 12))
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: 50, height: 11))
        label.font = label.font.withSize(8)
        label.textAlignment = .left
        labelContainer.addSubview(label)


        if let tileNum = core.scheme.gridnums[loc.row][loc.col] {
            //hacky way of getting some left padding
            label.text = " " + String(tileNum)
        } else {
            label.text = ""
        }
        
        let containerView = UIStackView(arrangedSubviews: [labelContainer, textField])

        containerView.axis = .vertical
        containerView.distribution = .fillProportionally

        let backgroundView = UIView(frame: containerView.bounds)
        backgroundView.backgroundColor = UIColor.white
        backgroundView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        containerView.insertSubview(backgroundView, at: 0)
        
        
        return containerView
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {
        let container = uiView as! UIStackView
        let background = container.subviews[0]
        let textfield = container.subviews[2] as! UITextField
        
        textfield.text = tile.text
        
        if textfield.isFirstResponder, core.state.focusedTile == nil {
            textfield.resignFirstResponder()
            return
        }
        
        if tile.isFocused {
            textfield.becomeFirstResponder()
            background.backgroundColor = Constants.Colors.currentTile
        } else if tile.isCurrentTile {
            background.backgroundColor = Constants.Colors.currentTile
        } else if tile.isCurrentWord {
            background.backgroundColor = Constants.Colors.currentWord
        } else {
            background.backgroundColor = Constants.Colors.defaultTile
        }
        
        switch tile.font {
        case .correct:
            textfield.textColor = Constants.Colors.correctAns
        case .incorrect:
            textfield.textColor = Constants.Colors.incorrectAns
        case .pencil:
            textfield.textColor = Constants.Colors.pencilAns
        case .normal:
            textfield.textColor = Constants.Colors.defaultAns
        
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
                parent.core.flipDirection()
            } else {
                parent.core.focus(tile: parent.loc)
            }
        }
        
        func textFieldShouldReturn(_ textField: UITextField) -> Bool {
            parent.core.toggleBoard()
            return true
        }
        
        func onEmptyBackspace() {
            parent.actions.prevTile()
        }
        
        
        
        func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
            let crosswordState = parent.core.state
            
            if string.count == 0 {
                //delete button pressed on nonempty tile
                let curTile = crosswordState.currentTile
                crosswordState.input[curTile.row][curTile.col]!.text = ""
            } else if string.count == 1 {
                //character entered
                let wasEmpty: Bool = textField.text!.count == 0
                if crosswordState.rebusMode {
                    //TO-DO: Implement rebus
                } else {
                    let curTile = crosswordState.currentTile
                    crosswordState.input[curTile.row][curTile.col]!.text = string.uppercased()
                    if crosswordState.pencilMode {
                        crosswordState.input[curTile.row][curTile.col]!.color = .pencil
                    } else {
                        crosswordState.input[curTile.row][curTile.col]!.color = .normal
                    }
                    parent.actions.nextTile(wasEmpty: wasEmpty)
                }
            }
            return false
        }
    }
}


