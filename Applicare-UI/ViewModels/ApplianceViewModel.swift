import Foundation

class ApplianceViewModel: ObservableObject {
    @Published var appliances: [Appliance] = []
    @Published var isLoading = false
    @Published var errorMessage: String? = nil
    
    func loadMyAppliances() {
        isLoading = true
        errorMessage = nil
        ApplianceNetworkService.shared.fetchMyAppliances { [weak self] result in
            DispatchQueue.main.async {
                self?.isLoading = false
                switch result {
                case .success(let appliances):
                    self?.appliances = appliances
                    print("[DEBUG] Loaded appliances: \(appliances)")
                case .failure(let error):
                    self?.errorMessage = error.localizedDescription
                    print("[DEBUG] Error loading appliances: \(error)")
                }
            }
        }
    }
    
    var isEmpty: Bool { appliances.isEmpty }
} 