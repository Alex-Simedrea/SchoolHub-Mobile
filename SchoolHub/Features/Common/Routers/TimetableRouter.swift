//
//  TimetableRouter.swift
//  SchoolHub
//
//  Created by Alexandru Simedrea on 22.12.2024.
//

import Alamofire
import Foundation

struct TimetableSubjectDTO: Codable {
    var displayName: String
    var symbolName: String
    var color: SubjectColor
    var timeSlots: [TimeSlotDTO]
    
    struct TimeSlotDTO: Codable {
        var weekday: Int
        var startTime: Date
        var endTime: Date
    }
}

enum TimetableRouter: URLRequestConvertible {
    case postTimetable(timetable: [TimetableSubjectDTO])
    case deleteTimetable
    case pauseTimetable(timestamp: Date)
    case resumeTimetable
    case deviceToken
    case startToken(token: String)
    case updateToken(token: String)
    
    var baseURL: String {
        return "https://school-visualizer-backend.onrender.com"
    }
    
    var path: String {
        switch self {
        case .postTimetable:
            return "/timetable"
        case .deleteTimetable:
            return "/timetable"
        case .pauseTimetable:
            return "/settings/pause"
        case .resumeTimetable:
            return "/settings/unpause"
        case .deviceToken:
            return "/auth/device-token"
        case .startToken:
            return "/auth/start-token"
        case .updateToken:
            return "/auth/update-token"
        }
    }
    
    var method: HTTPMethod {
        switch self {
        case .postTimetable:
            return .post
        case .deleteTimetable:
            return .delete
        case .pauseTimetable:
            return .patch
        case .resumeTimetable:
            return .patch
        case .deviceToken:
            return .post
        case .startToken:
            return .post
        case .updateToken:
            return .post
        }
    }
    
    var parameters: Encodable? {
        switch self {
        case .postTimetable(let timetable):
//            let encoder = JSONEncoder()
//            encoder.dateEncodingStrategy = .iso8601
//            let json = try! encoder.encode(timetable)
//            print(String(data: json, encoding: .utf8)!)
            return ["subjects": timetable]
        case .deleteTimetable:
            return nil
        case .pauseTimetable(let timestamp):
            return ["timestamp": timestamp]
        case .resumeTimetable:
            return nil
        case .deviceToken:
            return nil
        case .startToken(let token):
            return ["token": token]
        case .updateToken(let token):
            return ["token": token]
        }
    }
    
    func asURLRequest() throws -> URLRequest {
        let url = try baseURL.asURL()
        var urlRequest = URLRequest(url: url.appendingPathComponent(path))
        urlRequest.method = method
        
        let keychain = KeychainSwift()
        let deviceToken = keychain.get("deviceToken")
        urlRequest.headers = .init([.authorization(bearerToken: "\(deviceToken ?? "")")])
        
        if let parameters = parameters {
            let encoder = JSONEncoder()
            encoder.dateEncodingStrategy = .iso8601
//            let dateFormatter = DateFormatter()
//            dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
//            dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
//
//            encoder.dateEncodingStrategy = .custom { date, encoder in
//                var container = encoder.singleValueContainer()
//                let formattedDate = dateFormatter.string(from: date)
//                try container.encode(formattedDate)
//            }
            let parameterEncoder = JSONParameterEncoder(encoder: encoder)
            
            print(try! String(data: encoder.encode(parameters), encoding: .utf8)!)
            
            return try parameterEncoder.encode(
                parameters,
                into: urlRequest
            )
        }
        
        return urlRequest
    }
}
