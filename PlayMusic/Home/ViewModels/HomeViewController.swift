//
//  ViewController.swift
//  PlayMusic
//
//  Created by Felipe Leite on 19/11/22.
//

import UIKit
import Combine
import SnapKit

class HomeViewController: UIViewController {

    private struct Consts {
        static let padding: CGFloat = 12.0
    }

    // MARK: Properties

    var viewModel = HomeViewModel()
    
    private(set) var dataSource: UITableViewDiffableDataSource<Int, Track>?
    private(set) var cancellables: Set<AnyCancellable> = []

    // MARK: Subviews
    
    lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .insetGrouped)

        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.estimatedRowHeight = UITableView.automaticDimension
        tableView.rowHeight = UITableView.automaticDimension

        return tableView
    }()
    
    lazy var trackControls = TrackControlsViewController()

    // MARK: Life cycle

    override func viewDidLoad() {
        super.viewDidLoad()
        self.setup()
        self.setupNotifications()
        self.viewModel.load()
    }
    
    // MARK: Public methods

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        let bottomMargin = self.view.safeAreaInsets.bottom
        let controlHeight = self.trackControls.view.frame.height
        let bottom = self.trackControls.view.alpha == 1 ?
            controlHeight - bottomMargin + Consts.padding :
            0.0

        self.tableView.contentInset = UIEdgeInsets(top: 0.0,
                                                   left: 0.0,
                                                   bottom: bottom,
                                                   right: 0.0)
    }

    // MARK: Helpers
    
    private func setup() {
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        self.view.addSubview(self.tableView)
        self.view.backgroundColor = .systemBackground

        self.addTrackControls()

        self.dataSource = makeDataSource()
        self.tableView.dataSource = self.dataSource
        self.tableView.delegate = self
        self.tableView.register(TrackCell.self, forCellReuseIdentifier: TrackCell.reuseIdentifier)
        
        self.viewModel
            .$tracks
            .receive(on: DispatchQueue.main)
            .sink { [ weak self ] _ in self?.updateTable() }
            .store(in: &cancellables)
        
        self.tableView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }

    private func setupNotifications() {
        NotificationCenter.default
            .publisher(for: .trackSelected)
            .sink { [ weak self ] _ in self?.showTrackControls() }
            .store(in: &cancellables)
    }

    private func addTrackControls() {
        self.addChild(self.trackControls)
        self.view.addSubview(self.trackControls.view)
        self.trackControls.didMove(toParent: self)

        self.trackControls.view.transform = CGAffineTransform(translationX: 0.0, y: 50.0)
        self.trackControls.view.alpha = 0.0

        self.trackControls.view.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(Consts.padding)
            make.bottom.equalTo(self.view.safeAreaLayoutGuide.snp.bottom)
        }
    }

    private func showTrackControls() {
        UIView.animate(withDuration: 0.3, delay: 0.0) {
            self.trackControls.view.transform = .identity
            self.trackControls.view.alpha = 1.0
        }
    }

    private func makeDataSource() -> UITableViewDiffableDataSource<Int, Track> {
        return UITableViewDiffableDataSource(tableView: self.tableView) { tableView, indexPath, track in
            let trackViewModel = TrackViewModel(track: track)
            return TrackCell.dequeueReusableCell(from: tableView, viewModel: trackViewModel, indexPath: indexPath)
        }
    }

    private func updateTable() {
        var snapshot = NSDiffableDataSourceSnapshot<Int, Track>()

        snapshot.appendSections([ 0 ])
        snapshot.appendItems(self.viewModel.tracks)

        self.dataSource?.apply(snapshot)
    }
}

// MARK: -

extension HomeViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let track = self.dataSource?.itemIdentifier(for: indexPath) else { return }

        tableView.deselectRow(at: indexPath, animated: true)
        NotificationCenter.default.post(name: .trackSelected, object: nil, userInfo: [ "track": track ])
    }

}
