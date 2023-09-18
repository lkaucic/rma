//
//  AuthView.swift
//  ai_pal
//
//  Created by Luka Kaučić on 14.09.2023..
//

import SwiftUI

struct AuthView: View {
    @ObservedObject var viewModel : AuthViewModel = AuthViewModel()
    @EnvironmentObject var appState: AppState
    
    var body: some View {
        VStack{
            Text("AI Travel Pal")
                .font(.title)
                .bold()
            TextField("Email", text: $viewModel.emailText)
                .padding()
                .background(Color.gray.opacity(0.1))
                .textInputAutocapitalization(.never)
                .clipShape(RoundedRectangle(cornerRadius: 12))
            
            if viewModel.isPasswordVisible {
                SecureField("Password", text: $viewModel.passwordText)
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .textInputAutocapitalization(.never)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            
            if viewModel.isLoading{
                ProgressView()
            } else {
                
                Button{
                    viewModel.authenticate(appState: appState)
                }label: {
                    Text(viewModel.userExists ? "Log In" : "Create User")
                }
                .padding()
                .foregroundStyle(Color.white)
                .background(Color.blue)
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            }
            
        }
        .padding()
    }
}

struct AuthView_Previews: PreviewProvider {
    static var previews: some View {
        AuthView()
    }
}
