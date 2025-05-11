//
//  AuthDTOs.swift
//  Applicare-UI
//

import Foundation

// MARK: - Login
struct LoginRequestDTO: Codable {
    let email_address: String
    let password: String
}

struct LoginResponseDTO: Codable {
    let access_token: String
    let refresh_token: String
    let token_type: String
    let expires_in: Int
    let user_id: Int
    
    enum CodingKeys: String, CodingKey {
        case access_token
        case refresh_token
        case token_type
        case expires_in
        case user_id
    }
}

// MARK: - Registration
struct RegisterRequestDTO: Codable {
    let name: String
    let email_address: String
    let password: String
    let passwordConfirmation: String
    
    enum CodingKeys: String, CodingKey {
        case name
        case email_address
        case password
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
    let email_address: String
}

struct ResendVerificationResponseDTO: Codable {
    let message: String
}

// MARK: - User Registration
struct UserRegistrationDTO: Codable {
    let user: UserCreateDTO
    
    struct UserCreateDTO: Codable {
        let name: String
        let email_address: String
        let password: String
        let password_confirmation: String
    }
}

// MARK: - Email Verification
struct EmailVerificationDTO: Codable {
    let token: String
}

// MARK: - Resend Verification
struct ResendVerificationDTO: Codable {
    let email_address: String
}

// MARK: - Error Response
struct ErrorResponseDTO: Codable {
    let error: String
}

// MARK: - Token Refresh
struct TokenRefreshRequestDTO: Codable {
    let refresh_token: String
}

struct TokenRefreshResponseDTO: Codable {
    let access_token: String
    let refresh_token: String
    let token_type: String
    let expires_in: Int
} 