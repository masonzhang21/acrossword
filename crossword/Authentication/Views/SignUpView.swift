//
//  SignUpView.swift
//  crossword
//
//  Created by Mason Zhang on 4/27/20.
//  Copyright © 2020 mason. All rights reserved.
//

import SwiftUI

struct SignUpView: View {
    @State private var email: String = ""
    @State private var username: String = ""
    @State private var password: String = ""
    @Environment(\.presentationMode) var presentation: Binding<PresentationMode>
    
    @ObservedObject var vm: SignUpVM
    
    
    
    var body: some View {
        
        VStack{
            Image("login_pic")
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: 180, height: 80)
                .cornerRadius(10)
            Text("Create an Account").font(.title).bold()
            
            TextField("Email address", text: $email).padding()
                .background(Constants.Colors.lightGrey)
                .cornerRadius(5.0)
                .border(Color.black)
            TextField("Username", text: $username).padding()
                .background(Constants.Colors.lightGrey)
                .cornerRadius(5.0)
                .border(Color.black)
            
            SecureField("Password", text: $password).padding()
                .background(Constants.Colors.lightGrey)
                .cornerRadius(5.0)
                .border(Color.black)
            
            VStack(alignment: .leading) {
                Text("Username: 6-32 alphanumeric characters").padding(.bottom, 5)
                Text("Password: 6-32 alphanumeric characters or symbols")
            }.padding(.leading).padding([.top, .bottom], 10).font(.caption).frame(maxWidth: .infinity, alignment: .leading)
            
            Button(action: {self.vm.createAccount(email: self.email, username: self.username, password: self.password)}) {
                HStack{
                    Text("Create Account")
                    ActivityIndicator(isShowing: $vm.loading)
                }.padding()
                    .frame(minWidth: 0, maxWidth: .infinity)
                    .background(Constants.Colors.darkGrey)
                    .foregroundColor(Color(UIColor.white))
                    .cornerRadius(10)
            }
            HStack {
                Text("Have an account?")
                Button(action: {self.presentation.wrappedValue.dismiss()}) {
                    Text("Log in.")
                }
            }
            
            
            if (vm.response == nil) {
                Text(" ").frame(maxWidth: .infinity, alignment: .leading).padding()
            } else {
                HStack{
                Text("* ").foregroundColor(Color.red) +
                    Text(vm.response!)}.frame(maxWidth: .infinity, alignment: .leading).padding().foregroundColor(Color.red)
            }
        }.padding().onAppear(perform: self.vm.reset)
    }
}
    
    struct SignUpView_Previews: PreviewProvider {
        static var previews: some View {
            SignUpView(vm: SignUpVM())
        }
}
