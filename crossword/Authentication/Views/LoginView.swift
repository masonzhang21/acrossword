//
//  LoginView.swift
//  crossword
//
//  Created by Mason Zhang on 4/19/20.
//  Copyright © 2020 mason. All rights reserved.
//

import SwiftUI
import Validator

/// Main login view
struct LoginView: View {
    @State private var email: String = ""
    @State private var password: String = ""
    @ObservedObject var vm: LoginVM
    
    var body: some View {
        let signInForm: some View = VStack {
            TextField("Email address", text: $email)
                .padding()
                .background(Constants.Colors.lightGrey)
                .cornerRadius(5.0)
                .border(Color.black)
            
            SecureField("Password", text: $password)
                .padding()
                .background(Constants.Colors.lightGrey)
                .cornerRadius(5.0)
                .border(Color.black)
                .padding(.bottom)
            
            Button(action: {self.vm.signInUser(email: self.email, password: self.password)}) {
                HStack{
                    Text("Sign in")
                    ActivityIndicator(isShowing: $vm.loading)
                }.padding()
                    .frame(minWidth: 0, maxWidth: .infinity)
                    .background(Constants.Colors.blue)
                    .foregroundColor(Color(UIColor.white))
                    .cornerRadius(10)
            }
            
            NavigationLink(destination: ResetPasswordView()) {
                Text("Forgot password?")
                    .font(.caption)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding([.leading, .bottom])
                    .padding([.top], 5)
                    .foregroundColor(Color.black)
            }
            
            if (vm.response != nil) {
                Text(vm.response!)
                    .foregroundColor(Color.red)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding([.leading])
            } else {
                Text(" ")
                    .foregroundColor(Color.red)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding([.leading])
            }
        }
        
        return NavigationView{
            VStack {
                Text("Crossword Multi").font(.largeTitle).fontWeight(.semibold)
                Image("login_pic")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 180, height: 80)
                    .cornerRadius(10)
                    .padding(.bottom, 30)
                LabelledDivider(label: "Sign in")
                signInForm
                LabelledDivider(label: "or")
                NavigationLink(destination: SignUpView(vm: SignUpVM())) {
                    Text("Sign Up")
                        .padding()
                        .frame(minWidth: 0, maxWidth: .infinity)
                        .background(Color.black)
                        .foregroundColor(Color(UIColor.white))
                        .cornerRadius(10)
                        .padding(.bottom, 50)
                }
            }.padding()
        }
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView(vm: LoginVM())
    }
}
