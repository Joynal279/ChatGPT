//
//  ContentView.swift
//  ChatGPT
//
//  Created by Joynal Abedin on 14/2/23.
//

import SwiftUI
import Combine

struct ContentView: View {
    
    @State var chatMessages: [ChatMessage] = []
    @State var messageText: String = ""
    
    let openAIService = OpenAIService()
    @State var cancellables = Set<AnyCancellable>()
    
    var body: some View {
        VStack {
            ScrollView {
                LazyVStack {
                    ForEach(chatMessages, id: \.id) { message in
                        messageView(message: message)
                    }
                }
               
            }
            HStack {
                TextField("Enter a message", text: $messageText)
                    .padding()
                    .background(.gray.opacity(0.1))
                    .cornerRadius(12)
                Button {
                    sendMessage()
                } label: {
                    Text("Send")
                        .foregroundColor(.white)
                        .padding()
                        .background(.black)
                        .cornerRadius(12)
                }

            }
        }
        .padding()
    }
    
    func messageView(message: ChatMessage) -> some View {
        HStack {
            if message.sender == .me {
                Spacer()
            }
            Text(message.content)
                .foregroundColor(message.sender == .me ? .white : .black)
                .padding()
                .background(message.sender == .me ? .blue : .gray.opacity(0.1))
                .cornerRadius(16)
            if message.sender == .gpt {
                Spacer()
            }
        }
    }
    
    func sendMessage() {
        
        let myMessage = ChatMessage(id: UUID().uuidString, content: messageText, dateCreated: Date(), sender: .me)
        chatMessages.append(myMessage)
        openAIService.sendMessage(message: messageText).sink { completion in
            //handle error
        } receiveValue: { response in
            guard let textResponse = response.choices.first?.text.trimmingCharacters(in: .whitespacesAndNewlines.union(.init(charactersIn: "\""))) else {return}
            let gptMessage = ChatMessage(id: response.id, content: textResponse, dateCreated: Date(), sender: .gpt)
            chatMessages.append(gptMessage)
        }
        .store(in: &cancellables)

        messageText = ""
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}


struct ChatMessage {
    let id: String
    let content: String
    let dateCreated: Date
    let sender: MessageSender
}

enum MessageSender {
    case me
    case gpt
}

extension ChatMessage {
    static let sampleMessage = [
        ChatMessage(id: UUID().uuidString, content: "Sample Message From me", dateCreated: Date(), sender: .me),
        ChatMessage(id: UUID().uuidString, content: "Sample Message From gpt", dateCreated: Date(), sender: .gpt),
        ChatMessage(id: UUID().uuidString, content: "Sample Message From me", dateCreated: Date(), sender: .me),
        ChatMessage(id: UUID().uuidString, content: "Sample Message From gpt", dateCreated: Date(), sender: .gpt)
    ]
}

