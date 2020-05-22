//
//  ActivityIndicatorView.swift
//  crossword
//
//  Created by Mason Zhang on 4/26/20.
//  Copyright © 2020 mason. All rights reserved.
//

import SwiftUI

struct ActivityIndicator: UIViewRepresentable {

    @Binding var isShowing: Bool
    
    func makeUIView(context: Context) -> UIActivityIndicatorView {
        let indicator = UIActivityIndicatorView()
        indicator.color = UIColor.white
        return indicator
    }

    func updateUIView(_ uiView: UIActivityIndicatorView,
                      context: Context) {
        if self.isShowing {
            uiView.startAnimating()
        } else {
            uiView.stopAnimating()
        }
    }
}
