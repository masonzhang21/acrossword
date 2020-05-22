//
//  LabelledDivider.swift
//  crossword
//
//  Created by Mason Zhang on 4/26/20.
//  Copyright © 2020 mason. All rights reserved.
//

import SwiftUI

struct LabelledDivider: View {

    let label: String
    let horizontalPadding: CGFloat
    let textColor: Color
    let lineColor: Color

    init(label: String, horizontalPadding: CGFloat = 10, textColor: Color = .black, lineColor: Color = .gray) {
        self.label = label
        self.horizontalPadding = horizontalPadding
        self.textColor = textColor
        self.lineColor = lineColor
        
    }

    var body: some View {
        HStack {
            line
            Text(label).foregroundColor(textColor)
            line
        }
    }

    var line: some View {
        VStack { Divider().background(lineColor) }.padding(horizontalPadding)
    }
}

struct LabelledDivider_Previews: PreviewProvider {
    static var previews: some View {
        LabelledDivider(label: "Hello")
    }
}
