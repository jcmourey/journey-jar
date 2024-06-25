import SwiftUI
import Styleguide
import DatabaseRepresentable
import Date

struct TVDBInfoDetail: View {
    let info: TVDBInfo
    
    var body: some View {
        KeyValuePair("country", info.country)
        KeyValuePair("language", info.language)
        KeyValuePair("score", info.score)
        KeyValuePair("average runtime", info.averageRuntime)

        if let overview = info.overview {
            Text(overview)
                .font(.callout)
        }
    }
}

struct TVDBInfoSidebar: View {
    let info: TVDBInfo
    let fontSize: Double
    
    var body: some View {
        VStack(alignment: .trailing) {
            if let network = info.network {
                Text(network)
                    .font(.system(size: fontSize * 2))
            }
            if let year = info.year {
                Text(year.description)
                    .font(.system(size: fontSize * 2))
            }
            if let status = info.status {
                HStack(spacing: 5) {
                    Text(status)
                    if let lastAiredYear = info.lastAired?.year {
                        Text(lastAiredYear.description)
                    }
                }
            }
            if let nextAired = info.nextAired {
                Text("next: \(nextAired.formatted(date: .abbreviated, time: .omitted))")
            }
        }
        .font(.system(size: fontSize))
    }
}

#Preview {
    TVDBInfoDetail(info: .mock.hpi)
}
