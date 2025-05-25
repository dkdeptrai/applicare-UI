import Foundation

class ApplianceDetailViewModel: ObservableObject {
    @Published var repairHistory: [Booking] = []
    @Published var isLoading = false
    @Published var errorMessage: String? = nil
    
    func loadRepairHistory(for applianceId: Int) {
        isLoading = true
        errorMessage = nil
        ApplianceNetworkService.shared.fetchRepairHistoryForAppliance(applianceId: applianceId) { [weak self] result in
            DispatchQueue.main.async {
                self?.isLoading = false
                switch result {
                case .success(let bookings):
                    self?.repairHistory = bookings
                case .failure(let error):
                    self?.errorMessage = error.localizedDescription
                }
            }
        }
    }
} 