// To parse the JSON, add this file to your project and do:
//
//   let userModel = try? newJSONDecoder().decode(UserModel.self, from: jsonData)
//
// To parse values from Alamofire responses:
//
//   Alamofire.request(url).responseUserModel { response in
//     if let userModel = response.result.value {
//       ...
//     }
//   }

import Foundation
import Alamofire

enum ProjectStatus: String, Codable {
    case inProgress = "in_progress"
    case creatingGroup = "creating_group"
    case finished = "finished"
    case failure = "failure"
    case parent = "parent"
    case waitingForCorrection = "waiting_for_correction"
    case searchingGroup = "searching_a_group"
}

class UserModel: Codable {
    let id: Int?
    let email, login: String?
    let phone: String?
    let displayname: String?
    let imageURL: String?
    let correctionPoint: Int?
    let location: String?
    let wallet: Int?
    let cursusUsers: [CursusUser]?
    let projectsUsers: [ProjectsUsers]?
    
    enum CodingKeys: String, CodingKey {
        case id, email, login
        case phone, displayname
        case imageURL = "image_url"
        case correctionPoint = "correction_point"
        case location, wallet
        case cursusUsers = "cursus_users"
        case projectsUsers = "projects_users"
    }
    
    init(id: Int?, email: String?, login: String?, phone: String?, displayname: String?, imageURL: String?, correctionPoint: Int?, location: String?, wallet: Int?, cursusUsers: [CursusUser]?, projectsUsers: [ProjectsUsers]?) {
        self.id = id
        self.email = email
        self.login = login
        self.phone = phone
        self.displayname = displayname
        self.imageURL = imageURL
        self.correctionPoint = correctionPoint
        self.location = location
        self.wallet = wallet
        self.cursusUsers = cursusUsers
        self.projectsUsers = projectsUsers
    }
}

class Project: Codable {
    let id: Int?
    let name, slug: String?
    let parentID: Int?
    
    enum CodingKeys: String, CodingKey {
        case id, name, slug
        case parentID = "parent_id"
    }
    
    init(id: Int?, name: String?, slug: String?, parentID: Int?) {
        self.id = id
        self.name = name
        self.slug = slug
        self.parentID = parentID
    }
}

class ProjectsUsers: Codable {
    let id, occurrence: Int?
    let finalMark: Int?
    let status: ProjectStatus?
    let validated: Bool?
    let currentTeamID: Int?
    let project: Project?
    
    enum CodingKeys: String, CodingKey, CaseIterable {
        case id, occurrence
        case finalMark = "final_mark"
        case status
        case validated = "validated?"
        case currentTeamID = "current_team_id"
        case project
        case cursusIDS = "cursus_ids"
        case user, teams
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        id = try container.decodeIfPresent(Int.self, forKey: .id)
        occurrence = try container.decodeIfPresent(Int.self, forKey: .occurrence)
        finalMark = try container.decodeIfPresent(Int.self, forKey: .finalMark)
        status = try container.decodeIfPresent(ProjectStatus.self, forKey: .status)
        validated = try container.decodeIfPresent(Bool.self, forKey: .validated)
        currentTeamID = try container.decodeIfPresent(Int.self, forKey: .currentTeamID)
        project = try container.decodeIfPresent(Project.self, forKey: .project)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        for key in CodingKeys.allCases {
            try container.encode(key.rawValue, forKey: key)
        }
    }
    
    init(id: Int?, occurrence: Int?, finalMark: Int?, status: ProjectStatus?, validated: Bool?, currentTeamID: Int?, project: Project?) {
        self.id = id
        self.occurrence = occurrence
        self.finalMark = finalMark
        self.status = status
        self.validated = validated
        self.currentTeamID = currentTeamID
        self.project = project
    }
}

class Skills: Codable {
    let id : Int?
    let name : String?
    let level : Float?
    
    enum CodingKeys: String, CodingKey {
        case id
        case name = "name"
        case level = "level"
    }
    init(id: Int?, name: String?, level: Float?) {
        self.id = id
        self.name = name
        self.level = level
    }
}

class CursusUser: Codable {
    let id: Int?
    let skills: [Skills]?
    
    enum CodingKeys: String, CodingKey {
        case id
        case skills
    }
    
    init(id: Int?, skills: [Skills]?) {
        self.id = id
        self.skills = skills
    }
}
// MARK: Encode/decode helpers

class JSONNull: Codable, Hashable {
    
    public static func == (lhs: JSONNull, rhs: JSONNull) -> Bool {
        return true
    }
    
    public var hashValue: Int {
        return 0
    }
    
    public init() {}
    
    public required init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if !container.decodeNil() {
            throw DecodingError.typeMismatch(JSONNull.self, DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Wrong type for JSONNull"))
        }
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encodeNil()
    }
}

class JSONCodingKey: CodingKey {
    let key: String
    
    required init?(intValue: Int) {
        return nil
    }
    
    required init?(stringValue: String) {
        key = stringValue
    }
    
    var intValue: Int? {
        return nil
    }
    
    var stringValue: String {
        return key
    }
}

class JSONAny: Codable {
    let value: Any
    
    static func decodingError(forCodingPath codingPath: [CodingKey]) -> DecodingError {
        let context = DecodingError.Context(codingPath: codingPath, debugDescription: "Cannot decode JSONAny")
        return DecodingError.typeMismatch(JSONAny.self, context)
    }
    
    static func encodingError(forValue value: Any, codingPath: [CodingKey]) -> EncodingError {
        let context = EncodingError.Context(codingPath: codingPath, debugDescription: "Cannot encode JSONAny")
        return EncodingError.invalidValue(value, context)
    }
    
    static func decode(from container: SingleValueDecodingContainer) throws -> Any {
        if let value = try? container.decode(Bool.self) {
            return value
        }
        if let value = try? container.decode(Int64.self) {
            return value
        }
        if let value = try? container.decode(Double.self) {
            return value
        }
        if let value = try? container.decode(String.self) {
            return value
        }
        if container.decodeNil() {
            return JSONNull()
        }
        throw decodingError(forCodingPath: container.codingPath)
    }
    
    static func decode(from container: inout UnkeyedDecodingContainer) throws -> Any {
        if let value = try? container.decode(Bool.self) {
            return value
        }
        if let value = try? container.decode(Int64.self) {
            return value
        }
        if let value = try? container.decode(Double.self) {
            return value
        }
        if let value = try? container.decode(String.self) {
            return value
        }
        if let value = try? container.decodeNil() {
            if value {
                return JSONNull()
            }
        }
        if var container = try? container.nestedUnkeyedContainer() {
            return try decodeArray(from: &container)
        }
        if var container = try? container.nestedContainer(keyedBy: JSONCodingKey.self) {
            return try decodeDictionary(from: &container)
        }
        throw decodingError(forCodingPath: container.codingPath)
    }
    
    static func decode(from container: inout KeyedDecodingContainer<JSONCodingKey>, forKey key: JSONCodingKey) throws -> Any {
        if let value = try? container.decode(Bool.self, forKey: key) {
            return value
        }
        if let value = try? container.decode(Int64.self, forKey: key) {
            return value
        }
        if let value = try? container.decode(Double.self, forKey: key) {
            return value
        }
        if let value = try? container.decode(String.self, forKey: key) {
            return value
        }
        if let value = try? container.decodeNil(forKey: key) {
            if value {
                return JSONNull()
            }
        }
        if var container = try? container.nestedUnkeyedContainer(forKey: key) {
            return try decodeArray(from: &container)
        }
        if var container = try? container.nestedContainer(keyedBy: JSONCodingKey.self, forKey: key) {
            return try decodeDictionary(from: &container)
        }
        throw decodingError(forCodingPath: container.codingPath)
    }
    
    static func decodeArray(from container: inout UnkeyedDecodingContainer) throws -> [Any] {
        var arr: [Any] = []
        while !container.isAtEnd {
            let value = try decode(from: &container)
            arr.append(value)
        }
        return arr
    }
    
    static func decodeDictionary(from container: inout KeyedDecodingContainer<JSONCodingKey>) throws -> [String: Any] {
        var dict = [String: Any]()
        for key in container.allKeys {
            let value = try decode(from: &container, forKey: key)
            dict[key.stringValue] = value
        }
        return dict
    }
    
    static func encode(to container: inout UnkeyedEncodingContainer, array: [Any]) throws {
        for value in array {
            if let value = value as? Bool {
                try container.encode(value)
            } else if let value = value as? Int64 {
                try container.encode(value)
            } else if let value = value as? Double {
                try container.encode(value)
            } else if let value = value as? String {
                try container.encode(value)
            } else if value is JSONNull {
                try container.encodeNil()
            } else if let value = value as? [Any] {
                var container = container.nestedUnkeyedContainer()
                try encode(to: &container, array: value)
            } else if let value = value as? [String: Any] {
                var container = container.nestedContainer(keyedBy: JSONCodingKey.self)
                try encode(to: &container, dictionary: value)
            } else {
                throw encodingError(forValue: value, codingPath: container.codingPath)
            }
        }
    }
    
    static func encode(to container: inout KeyedEncodingContainer<JSONCodingKey>, dictionary: [String: Any]) throws {
        for (key, value) in dictionary {
            let key = JSONCodingKey(stringValue: key)!
            if let value = value as? Bool {
                try container.encode(value, forKey: key)
            } else if let value = value as? Int64 {
                try container.encode(value, forKey: key)
            } else if let value = value as? Double {
                try container.encode(value, forKey: key)
            } else if let value = value as? String {
                try container.encode(value, forKey: key)
            } else if value is JSONNull {
                try container.encodeNil(forKey: key)
            } else if let value = value as? [Any] {
                var container = container.nestedUnkeyedContainer(forKey: key)
                try encode(to: &container, array: value)
            } else if let value = value as? [String: Any] {
                var container = container.nestedContainer(keyedBy: JSONCodingKey.self, forKey: key)
                try encode(to: &container, dictionary: value)
            } else {
                throw encodingError(forValue: value, codingPath: container.codingPath)
            }
        }
    }
    
    static func encode(to container: inout SingleValueEncodingContainer, value: Any) throws {
        if let value = value as? Bool {
            try container.encode(value)
        } else if let value = value as? Int64 {
            try container.encode(value)
        } else if let value = value as? Double {
            try container.encode(value)
        } else if let value = value as? String {
            try container.encode(value)
        } else if value is JSONNull {
            try container.encodeNil()
        } else {
            throw encodingError(forValue: value, codingPath: container.codingPath)
        }
    }
    
    public required init(from decoder: Decoder) throws {
        if var arrayContainer = try? decoder.unkeyedContainer() {
            self.value = try JSONAny.decodeArray(from: &arrayContainer)
        } else if var container = try? decoder.container(keyedBy: JSONCodingKey.self) {
            self.value = try JSONAny.decodeDictionary(from: &container)
        } else {
            let container = try decoder.singleValueContainer()
            self.value = try JSONAny.decode(from: container)
        }
    }
    
    public func encode(to encoder: Encoder) throws {
        if let arr = self.value as? [Any] {
            var container = encoder.unkeyedContainer()
            try JSONAny.encode(to: &container, array: arr)
        } else if let dict = self.value as? [String: Any] {
            var container = encoder.container(keyedBy: JSONCodingKey.self)
            try JSONAny.encode(to: &container, dictionary: dict)
        } else {
            var container = encoder.singleValueContainer()
            try JSONAny.encode(to: &container, value: self.value)
        }
    }
}

func newJSONDecoder() -> JSONDecoder {
    let decoder = JSONDecoder()
    if #available(iOS 10.0, OSX 10.12, tvOS 10.0, watchOS 3.0, *) {
        decoder.dateDecodingStrategy = .iso8601
    }
    return decoder
}

func newJSONEncoder() -> JSONEncoder {
    let encoder = JSONEncoder()
    if #available(iOS 10.0, OSX 10.12, tvOS 10.0, watchOS 3.0, *) {
        encoder.dateEncodingStrategy = .iso8601
    }
    return encoder
}

// MARK: - Alamofire response handlers

extension DataRequest {
    fileprivate func decodableResponseSerializer<T: Decodable>() -> DataResponseSerializer<T> {
        return DataResponseSerializer { _, response, data, error in
            guard error == nil else { return .failure(error!) }
            
            guard let data = data else {
                return .failure(AFError.responseSerializationFailed(reason: .inputDataNil))
            }
            
            do {
              let _ = try newJSONDecoder().decode(T.self, from: data)
            } catch {
                print("Error: \(error)")
            }
            
            return Result { try newJSONDecoder().decode(T.self, from: data) }
        }
    }
    
    @discardableResult
    fileprivate func responseDecodable<T: Decodable>(queue: DispatchQueue? = nil, completionHandler: @escaping (DataResponse<T>) -> Void) -> Self {
        return response(queue: queue, responseSerializer: decodableResponseSerializer(), completionHandler: completionHandler)
    }
    
    @discardableResult
    func responseUserModel(queue: DispatchQueue? = nil, completionHandler: @escaping (DataResponse<UserModel>) -> Void) -> Self {
        return responseDecodable(queue: queue, completionHandler: completionHandler)
    }
}
