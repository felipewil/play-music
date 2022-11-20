//
//  TrackCell.swift
//  PlayMusic
//
//  Created by Felipe Leite on 20/11/22.
//

import UIKit
import Combine
import SnapKit

class TrackCell: UITableViewCell {

    private struct Consts {
        static let padding: CGFloat = 12.0
        static let imageSize: CGFloat = 64.0
        static let imageCornerRadius: CGFloat = 12.0
        static let titleFontSize: CGFloat = 15.0
        static let subtitleFontSize: CGFloat = 13.0
    }

    // MARK: Properties
    
    static let reuseIdentifier = "TrackCell"
    
    private(set) var cancellables: Set<AnyCancellable> = []
    
    // MARK: Subviews
    
    lazy var albumImageView: UIImageView = {
        let imageView = UIImageView()

        imageView.layer.masksToBounds = true
        imageView.layer.cornerRadius = Consts.imageCornerRadius
        imageView.translatesAutoresizingMaskIntoConstraints = false

        return imageView
    }()
    
    lazy var titleLabel: UILabel = {
        let label = UILabel()

        label.textColor = .label
        label.font = .systemFont(ofSize: Consts.titleFontSize, weight: .semibold)
        label.numberOfLines = 1
        label.translatesAutoresizingMaskIntoConstraints = false

        return label
    }()

    lazy var subtitleLabel: UILabel = {
        let label = UILabel()

        label.textColor = .label
        label.font = .systemFont(ofSize: Consts.subtitleFontSize)
        label.numberOfLines = 1
        label.translatesAutoresizingMaskIntoConstraints = false

        return label
    }()
    
    // MARK: Initializers
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.setup()
    }
    
    // MARK: Public methods
    
    static func dequeueReusableCell(from tableView: UITableView, viewModel: TrackViewModel, indexPath: IndexPath) -> TrackCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier,
                                                 for: indexPath) as! TrackCell

        cell.titleLabel.text = viewModel.title
        cell.subtitleLabel.text = viewModel.artist
        cell.loadImage(viewModel: viewModel)

        return cell
    }

    override func prepareForReuse() {
        cancellables.forEach { $0.cancel() }
        cancellables = []
        self.albumImageView.image = nil
    }

    // MARK: Helpers

    private func setup() {
        self.contentView.addSubview(self.titleLabel)
        self.contentView.addSubview(self.subtitleLabel)
        self.contentView.addSubview(self.albumImageView)
        
        self.albumImageView.snp.makeConstraints { make in
            make.top.left.bottom.equalToSuperview().inset(Consts.padding)
            make.size.equalTo(Consts.imageSize)
        }
        
        self.titleLabel.snp.makeConstraints { make in
            make.top.right.equalToSuperview().inset(Consts.padding)
            make.left.equalTo(self.albumImageView.snp.right).offset(Consts.padding)
        }
        
        self.subtitleLabel.snp.makeConstraints { make in
            make.top.equalTo(self.titleLabel.snp.bottom)
            make.left.equalTo(self.titleLabel.snp.left)
            make.right.equalToSuperview().inset(Consts.padding)
        }
    }

    private func loadImage(viewModel: TrackViewModel) {
        guard let url = URL(string: viewModel.coverUrl) else { return }

        self.albumImageView.loadImage(url: url).store(in: &cancellables)
    }

}
