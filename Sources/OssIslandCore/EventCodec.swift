import Foundation

public enum EventCodec {
    public static func encodeLine(_ event: AgentEvent) throws -> Data {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        encoder.outputFormatting = [.sortedKeys, .withoutEscapingSlashes]
        var data = try encoder.encode(event)
        data.append(0x0A)
        return data
    }

    public static func decodeLines(_ data: Data) -> [AgentEvent] {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601

        return data.split(separator: 0x0A).compactMap { line in
            try? decoder.decode(AgentEvent.self, from: Data(line))
        }
    }
}
