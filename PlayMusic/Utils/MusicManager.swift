//
//  MusicManager.swift
//  PlayMusic
//
//  Created by Felipe Leite on 19/11/22.
//

import Foundation
import Combine

struct MusicManager {

    private struct Consts {
        static let baseURL = URL(string: "https://api.deezer.com/")
    }
    
    private enum Endpoint {
        case chart
        
        var url: URL? {
            switch self {
            case .chart:
                return Consts.baseURL?.appending(path: "chart")
            }
        }
    }
    
    // MARK: Properties
    
    private let urlSession: URLSession

    // MARK: Initializers
    
    init(urlSession: URLSession = .shared) {
        self.urlSession = urlSession
    }

    // MARK: Public methods
    
    func loadMusics() -> AnyPublisher<[ Track ], Error> {
        guard let url = Endpoint.chart.url else { return Empty<[ Track ], Error>().eraseToAnyPublisher() }

        return self.urlSession
            .dataTaskPublisher(for: url)
            .map(\.data)
            .decode(type: ChartResponse.self, decoder: JSONDecoder())
            .map { $0.tracks.data }
            .catch { error in Empty<[ Track ], Error>() }
            .eraseToAnyPublisher()
    }
    
}
