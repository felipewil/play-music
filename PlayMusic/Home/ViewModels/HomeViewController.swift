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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setup()
        self.viewModel.load()
    }

    // MARK: Helpers
    
    private func setup() {
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        self.view.backgroundColor = .white
        self.view.addSubview(self.tableView)

        self.dataSource = makeDataSource()
        self.tableView.dataSource = self.dataSource
        self.tableView.register(TrackCell.self, forCellReuseIdentifier: TrackCell.reuseIdentifier)
        
        self.viewModel
            .$tracks
            .receive(on: DispatchQueue.main)
            .sink { [ weak self ] _ in
                self?.updateTable()
            }
            .store(in: &cancellables)
        
        self.tableView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }

    private func makeDataSource() -> UITableViewDiffableDataSource<Int, Track> {
        return UITableViewDiffableDataSource(tableView: self.tableView) { tableView, indexPath, track in
            let trackViewModel = TrackViewModel(track: track)
            return TrackCell.dequeueReusableCell(from: tableView, viewModel: trackViewModel, indexPath: indexPath)
        }
    }

    private func updateTable() {
        print("updated")
        var snapshot = NSDiffableDataSourceSnapshot<Int, Track>()

        snapshot.appendSections([ 0 ])
        snapshot.appendItems(self.viewModel.tracks)

        self.dataSource?.apply(snapshot)
    }
}

// MARK: -


