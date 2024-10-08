import Dependencies
import ErrorService

extension ErrorService: DependencyKey {
    public static let liveValue = {
        Self(
            detail: { error, label, file, function, line in
                let text = if let label { "\(label): \(error.localizedDescription)" } else { "\(error.localizedDescription)" }
                return "\(file): \(function):\(line): \(text)"
            },
            warning: { label, file, function, line in
                "\(file): \(function):\(line): Warning:\(label)"
            }
        )
    }()
}
