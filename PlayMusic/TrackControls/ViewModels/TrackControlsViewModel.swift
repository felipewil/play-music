//
//  TrackControlsViewModel.swift
//  PlayMusic
//
//  Created by Felipe Leite on 20/11/22.
//

import Foundation
import Combine

class TrackControlsViewModel {

    // MARK: Properties

    private var cancellables: Set<AnyCancellable> = []

    @Published var isPlaying = false
    @Published var currentTrack: Track?

    // MARK: Initializers

    init() {
        self.setupNotifications()
    }

    // MARK: Helpers

    private func setupNotifications() {
        NotificationCenter.default
            .publisher(for: .trackSelected)
            .sink(receiveValue: self.trackSelected(_:))
            .store(in: &cancellables)
    }

    private func trackSelected(_ notification: Notification) {
        self.currentTrack = notification.userInfo?["track"] as? Track
    }

}
