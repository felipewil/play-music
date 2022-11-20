//
//  UIImageView+Extensions.swift
//  PlayMusic
//
//  Created by Felipe Leite on 20/11/22.
//

import UIKit
import Combine

extension UIImageView {

    /// Returns a image with the given URL.
    func loadImage(url: URL) -> AnyCancellable {
        return URLSession.shared
            .dataTaskPublisher(for: url)
            .map(\.data)
            .catch { _ in Empty() }
            .receive(on: DispatchQueue.main)
            .sink { self.image = UIImage(data: $0) }
    }

}
