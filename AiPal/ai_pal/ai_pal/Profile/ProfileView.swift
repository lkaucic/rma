//
//  ProfileView.swift
//  ai_pal
//
//  Created by Luka Kaučić on 14.09.2023..
//

import SwiftUI

struct ProfileView: View {
    @State var apiKey: String = UserDefaults.standard.string(forKey: "openai_api_key") ?? "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"
    var body: some View {
        List {
            Section("OpenAI API Key"){
                TextField("Enter Key", text: $apiKey){
                    UserDefaults.standard.set(apiKey, forKey: "openai_api_key")
                }
            }
            
        }
    }
}

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView()
    }
}
