import UIKit
// Modified from: https://stackoverflow.com/questions/49695780/codable-enum-with-default-case-in-swift-4/49697266#49697266

extension RawRepresentable where Self.RawValue == String {
    func caseInsensitiveMatch(other: String) -> Bool {
        self.rawValue.caseInsensitiveCompare(other) == .orderedSame
    }
}

protocol CaseIterableDefaultsLast: Codable & CaseIterable & RawRepresentable
    where Self.RawValue == String, Self.AllCases: BidirectionalCollection { }

extension CaseIterableDefaultsLast {
    init(from decoder: Decoder) throws {
        let all = Self.allCases
        let defaultValue = all.last!
        
        guard let valueAsString = try? decoder.singleValueContainer().decode(RawValue.self) else {
            self = defaultValue
            return
        }
        
        if let deserialized = Self(rawValue: valueAsString) {
            self = deserialized
        } else if let match = (all.first { $0.caseInsensitiveMatch(other: valueAsString) }){
            self = match
        } else {
            self = defaultValue
        }
    }
}

enum Type: String, CaseIterableDefaultsLast {
    case bet, cancelled_bet, document, profile, sign, inputDate = "input_date", inputText = "input_text" , inputNumber = "input_number", inputOption = "input_option", unknown
}


func deserialize(_ stringVal: String) -> [Type] {
    return try! JSONDecoder().decode([Type].self , from: Data(stringVal.utf8))
}

print(deserialize(#"["bet", "BET", "Bet"]"#))
print(deserialize(#"["unknown", "not_valid", "input_date"]"#))

deserialize(#"["bet", "BET", "Bet"]"#)
deserialize(#"["unknown", "not_valid", "inPut_date"]"#)
