//
//  HomeViewModel.swift
//  PlayMusic
//
//  Created by Felipe Leite on 19/11/22.
//

import Foundation
import Combine

class HomeViewModel {
    
    // MARK: Properties
    
    let musicManager: MusicManager
    private var cancellables: Set<AnyCancellable> = []
    @Published private(set) var tracks: [ Track ] = []
    
    // MARK: Initializers
    
    init(musicManager: MusicManager = MusicManager()) {
        self.musicManager = musicManager
    }

    // MARK: Public methods
    
    func load() {
        self.musicManager
            .loadMusics()
            .sink { _ in } receiveValue: { [ weak self ] tracks in
                self?.tracks.append(contentsOf: tracks)
            }
            .store(in: &cancellables)
    }
}
