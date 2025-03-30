//
//  AuthDTOs.swift
//  Applicare-UI
//
//  Created by Applicare on 16/3/25.
//

import Foundation

// MARK: - Login
struct LoginRequestDTO: Codable {
    let email: String
    let password: String
}

struct LoginResponseDTO: Codable {
    let token: String
    let user: UserDTO
}

// MARK: - Registration
struct RegisterRequestDTO: Codable {
    let email: String
    let password: String
    let passwordConfirmation: String
    
    enum CodingKeys: String, CodingKey {
        case email, password
        case passwordConfirmation = "password_confirmation"
    }
}

struct RegisterResponseDTO: Codable {
    let message: String
    let user: UserDTO
}

// MARK: - Email Verification
struct VerifyEmailRequestDTO: Codable {
    let token: String
}

struct VerifyEmailResponseDTO: Codable {
    let message: String
}

// MARK: - Resend Verification
struct ResendVerificationRequestDTO: Codable {
    let email: String
}

struct ResendVerificationResponseDTO: Codable {
    let message: String
} 