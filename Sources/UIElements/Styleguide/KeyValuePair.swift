import SwiftUI

public struct KeyValuePair: View {
    let key: String
    let value: String
        
    public init(_ key: String, _ value: (any StringProtocol)?) {
        self.key = key.capitalized
        if let value {
            self.value = String(value)
        } else {
            self.value = "<not set>"
        }
    }
    
    public init(_ key: String, _ value: (CustomStringConvertible)?) {
        self.init(key, value?.description)
    }
    
    public init(_ key: String, _ date: Date?, dateStyle: Date.FormatStyle.DateStyle = .abbreviated, timeStyle: Date.FormatStyle.TimeStyle = .shortened) {
        self.init(key, date?.formatted(date: dateStyle, time: timeStyle))
    }
    
    public init(_ key: String, _ number: (any BinaryInteger)?, formatted: Bool = true) {
        let numberString = if formatted { number?.formatted() } else { number?.description }
        self.init(key, numberString)
    }
    
    public init(_ key: String, _ number: (any BinaryFloatingPoint)?) {
        self.init(key, number?.formatted())
    }

    public init<Value: RawRepresentable>(_ key: String, _ value: Value?) where Value.RawValue: StringProtocol {
        self.init(key, value?.rawValue)
    }
    
    public init<Value: RawRepresentable>(_ key: String, _ value: Value?) where Value.RawValue: BinaryInteger {
        self.init(key, value?.rawValue)
    }

    public var body: some View {
        HStack {
            Text(key)
            Spacer()
            Text(value)
        }
    }
}

#Preview {
    enum TestEnum: Int {
        case one = 1
        case two
        case three
    }
    return Form {
        KeyValuePair("String", "some text")
        KeyValuePair("Date", .now)
        KeyValuePair("BinaryInteger", 45340)
        KeyValuePair("BinaryFloatingPoint", 34.567 as (any BinaryFloatingPoint)?)
        KeyValuePair("BinaryFloatingPoint as CustomStringConvertible", 34.567 as CustomStringConvertible?)
        KeyValuePair("TestEnum", TestEnum.one)
        KeyValuePair("No Progress", nil as Progress?)
        KeyValuePair("No Date", nil as Date?)
        KeyValuePair("No Integer", nil as Int?)
        KeyValuePair("No Double", nil as (any BinaryFloatingPoint)?)
    }
}
