//
//  ChatViewModel.swift
//  ai_pal
//
//  Created by Luka Kaučić on 14.09.2023..
//

import Foundation
import OpenAI
import FirebaseFirestoreSwift
import FirebaseFirestore
import SwiftUI

class ChatViewModel: ObservableObject {
    @Published var chat: AppChat?
    @Published var messages: [AppMessage] = []
    @Published var messageText: String = ""
    @Published var selectedModel: ChatModel = .gpt3_5_turbo
    
    let chatId: String
    
    @AppStorage("openai_api_key") var apiKey = "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"
    let db = Firestore.firestore()
    
    init(chatId: String){
        self.chatId = chatId
    }
    
    func fetchData(){
     //   self.messages = [
       //     AppMessage(id: "1", text: "Hello how are you", role: .user, createdAt: Date()),
         //   AppMessage(id: "2", text: "Good, and you?", role: .assistant, createdAt: Date()),
        // ]
    }
    
    func sendMessage() async throws {
        var newMessage = AppMessage(id: UUID().uuidString, text: messageText, role: .user)
        
        do {
            let documentRef = try storeMessage(message: newMessage)
            newMessage.id = documentRef.documentID
        } catch {
            print(error)
        }
        
        if messages.isEmpty {
            setupNewChat()
        }
        
        await MainActor.run{ [newMessage] in
            messages.append(newMessage)
            messageText=""
        }
        
        try await generateResponse(for: newMessage)
        
        
        
    }
    
    private func storeMessage(message: AppMessage) throws -> DocumentReference {
        return try db.collection("chats").document(chatId).collection("message").addDocument(from: message)
    }
    
    private func setupNewChat(){
        db.collection("chats").document(chatId).updateData(["model" : selectedModel.rawValue])
        DispatchQueue.main.async{ [weak self] in
            self?.chat?.model = self?.selectedModel
        }
    }
    
    private func generateResponse(for message: AppMessage) async throws {
        let openAI = OpenAI(apiToken: apiKey)
        let queryMessage = messages.map {appMessage in
            Chat(role: appMessage.role, content: appMessage.text)
        }
        let query = ChatQuery(model: chat?.model?.model ?? .gpt3_5Turbo, messages: queryMessage)
        for try await result in openAI.chatsStream(query: query){
            guard let newText = result.choices.first?.delta.content else {continue }
            await MainActor.run{
                if let lastMessage = messages.last, lastMessage.role != .user {
                    messages[messages.count-1].text += newText
                } else {
                    let newMessage = AppMessage(id: result.id, text: newText, role: .assistant)
                    messages.append(newMessage)
                }
            }
        }
        
        if let lastMessage = messages.last {
            _ = try storeMessage(message: lastMessage)
        }
    }
}


struct AppMessage: Identifiable,Codable,Hashable {
    @DocumentID var id: String?
    var text: String
    let role: Chat.Role
    let createdAt: FirestoreDate = FirestoreDate()
}
