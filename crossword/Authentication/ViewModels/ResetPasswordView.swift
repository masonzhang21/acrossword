//
//  ResetPasswordView.swift
//  crossword
//
//  Created by Mason Zhang on 4/27/20.
//  Copyright © 2020 mason. All rights reserved.
//

import SwiftUI

struct ResetPasswordView: View {
    @State private var email: String = ""
    @ObservedObject var vm: ResetPasswordVM = ResetPasswordVM()

    var body: some View {
        
        return VStack{
            Image("login_pic")
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: 180, height: 80)
                .cornerRadius(10)
                .padding(.bottom, 30)
            Text("Forgot your password?").font(.title).bold().padding()
            TextField("Email address", text: $email).padding()
                .background(Constants.Colors.lightGrey)
                .cornerRadius(5.0)
                .border(Color.black)
            Text("We'll email you a link to reset your password.").padding(.leading).padding([.top, .bottom], 10).font(.caption).frame(maxWidth: .infinity, alignment: .leading)
            Button(action: {self.vm.resetPassword(email: self.email)}) {
                Text("Send Link")
            }.padding()
                .frame(minWidth: 0, maxWidth: .infinity)
                .background(Constants.Colors.darkGrey)
                .foregroundColor(Color(UIColor.white))
                .cornerRadius(10)
            
            if (vm.response == nil) {
                Text(" ").frame(maxWidth: .infinity, alignment: .leading).padding()
            } else {
                Text(vm.response!).frame(maxWidth: .infinity, alignment: .leading).padding()
            }
            
        }.padding().frame(maxHeight: .infinity, alignment: .topLeading).onAppear(perform: vm.reset)
    }
}

struct ResetPasswordView_Previews: PreviewProvider {
    static var previews: some View {
        ResetPasswordView()
    }
}
