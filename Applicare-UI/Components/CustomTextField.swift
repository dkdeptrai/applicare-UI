//
//  CustomTextField.swift
//  Applicare-UI
//
//  Created by Đình Khoa Nguyễn on 16/3/25.
//


import SwiftUI

struct CustomTextField: View {
  var placeholder: String
  var imageName: String
  var isSecure: Bool = false
  
  @State private var text: String = ""
  @State private var isTextVisible: Bool = false
  
  var body: some View {
    HStack {
      Image(systemName: imageName)
        .foregroundColor(.gray)
      
      if isSecure {
        if isTextVisible {
          TextField(placeholder, text: $text)
        } else {
          SecureField(placeholder, text: $text)
        }
        
        Button(action: {
          isTextVisible.toggle()
        }) {
          Image(systemName: isTextVisible ? "eye.slash" : "eye")
            .foregroundColor(.gray)
        }
      } else {
        TextField(placeholder, text: $text)
      }
    }
    .padding()
    .background(Color(.systemGray6))
    .cornerRadius(10)
  }
}
