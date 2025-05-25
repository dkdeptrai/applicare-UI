import SwiftUI

struct ApplianceCard: View {
    let appliance: Appliance
    
    var year: String {
        // Extract year from created_at (format: yyyy-MM-dd...)
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        if let date = formatter.date(from: String(appliance.created_at.prefix(19))) {
            let yearFormatter = DateFormatter()
            yearFormatter.dateFormat = "yyyy"
            return yearFormatter.string(from: date)
        }
        return "-"
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            ZStack {
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color(.systemGray6))
                    .frame(height: 110)
                if let urlString = appliance.image_url, let url = URL(string: urlString) {
                    AsyncImage(url: url) { image in
                        image
                            .resizable()
                            .scaledToFill()
                            .frame(height: 110)
                            .clipped()
                    } placeholder: {
                        ProgressView()
                    }
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                } else {
                    Image(systemName: "photo")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 48, height: 48)
                        .foregroundColor(.gray)
                }
            }
            .padding([.top, .horizontal], 8)
            Text(appliance.name)
                .font(.headline)
                .foregroundColor(.primary)
                .padding(.horizontal, 8)
                .lineLimit(2)
                .truncationMode(.tail)
            HStack(spacing: 4) {
                Image(systemName: "calendar")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                Text("Since : \(year)")
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
            .padding(.horizontal, 8)
            .padding(.bottom, 8)
        }
        .frame(width: 150, height: 200)
        .background(Color.white)
        .cornerRadius(18)
        .shadow(color: Color(.black).opacity(0.07), radius: 6, x: 0, y: 2)
    }
}

struct ApplianceCard_Previews: PreviewProvider {
    static var previews: some View {
        ApplianceCard(appliance: Appliance(id: 1, name: "Air purifier with a very long name that should be truncated", brand: "Winix", model: "A230", image_url: nil, created_at: "2017-01-01T00:00:00", updated_at: "2017-01-01T00:00:00"))
            .previewLayout(.sizeThatFits)
            .padding()
    }
} 