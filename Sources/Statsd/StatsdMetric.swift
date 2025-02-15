import Foundation
import MetricsUtils

// https://github.com/statsd/statsd/blob/master/docs/metric_types.md
open class StatsdMetric: CustomStringConvertible, Hashable {
    public enum Value: Hashable {
        case gauge(Int)
        case time(TimeInterval)
        case count(Int)
        
        public func build() -> String {
            switch self {
            case let .gauge(value):
                return "\(value)|g"
            case let .time(value):
                return "\(Int(value * 1000))|ms"
            case let .count(value):
                return "\(value)|c"
            }
        }
    }
    
    public let components: [String]
    public let value: Value
    
    public static let reservedField = "reserved"

    public init(
        fixedComponents: [StaticString],
        variableComponents: [String],
        value: Value
    ) {
        self.components = (fixedComponents.map { $0.description } + variableComponents).map { $0.suitableForMetric }
        self.value = value
    }
    
    public func build(domain: [String]) -> String {
        return "\((domain + components).joined(separator: ".")):\(value.build())"
    }
    
    public var description: String {
        return "<\(type(of: self)) components=\(components), value=\(value)"
    }

    public static func ==(left: StatsdMetric, right: StatsdMetric) -> Bool {
        return left.components == right.components
            && left.value == right.value
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(components)
        hasher.combine(value)
    }
}
