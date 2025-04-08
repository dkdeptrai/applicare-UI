//
//  NetworkServiceTests.swift
//  Applicare-UI
//
//  Created by Đình Khoa Nguyễn on 16/3/25.
//


import XCTest
@testable import YourProjectName

class NetworkServiceTests: XCTestCase {
    
    func testFetchDataSuccess() {
        let expectation = self.expectation(description: "FetchData")
        
        NetworkService.shared.fetchData(from: "https://api.example.com/users") { (result: Result<[User], NetworkError>) in
            switch result {
            case .success(let users):
                XCTAssertNotNil(users)
                expectation.fulfill()
            case .failure:
                XCTFail("Expected success, got failure")
            }
        }
        
        waitForExpectations(timeout: 5, handler: nil)
    }
    
    func testFetchDataFailure() {
        let expectation = self.expectation(description: "FetchData")
        
        NetworkService.shared.fetchData(from: "invalid_url") { (result: Result<[User], NetworkError>) in
            switch result {
            case .success:
                XCTFail("Expected failure, got success")
            case .failure(let error):
                XCTAssertEqual(error, .invalidURL)
                expectation.fulfill()
            }
        }
        
        waitForExpectations(timeout: 5, handler: nil)
    }
}