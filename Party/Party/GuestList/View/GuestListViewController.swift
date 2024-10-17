//
//  GuestListViewController.swift
//  Party
//
//  Created by Karen Khachatryan on 16.10.24.
//

import UIKit
import Combine

class GuestListViewController: UIViewController {

    @IBOutlet weak var guestsTableView: UITableView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    private let viewModel = GuestListViewModel.shared
    private var cancellables: Set<AnyCancellable> = []

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        subscribe()
        viewModel.fetchData()
    }
    
    func setupUI() {
        setNavigationBar(title: "Guest list")
        nameLabel.font = .montserratExtraBold(size: 22)
        locationLabel.font = .montserratMedium(size: 15)
        dateLabel.font = .montserratExtraBold(size: 44)
        nameLabel.text = viewModel.partyModel?.name
        nameLabel.sizeToFit()
        locationLabel.text = viewModel.partyModel?.location
        locationLabel.sizeToFit()
        dateLabel.text = viewModel.partyModel?.date?.toString(format: "dd/MM")
        dateLabel.sizeToFit()
        guestsTableView.delegate = self
        guestsTableView.dataSource = self
        guestsTableView.register(UINib(nibName: "GuestListTableViewCell", bundle: nil), forCellReuseIdentifier: "GuestListTableViewCell")
    }
    
    func subscribe() {
        viewModel.$guest
            .receive(on: DispatchQueue.main)
            .sink { [weak self] guest in
                guard let self = self else { return }
                self.guestsTableView.reloadData()
            }
            .store(in: &cancellables)
    }
    
    @objc func addGuest() {
        let addGuestVC = AddGuestViewController(nibName: "AddGuestViewController", bundle: nil)
        AddGuestViewModel.shared.party = viewModel.partyModel
        self.navigationController?.pushViewController(addGuestVC, animated: true)
    }
    
    deinit {
        viewModel.clear()
    }

}

extension GuestListViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.guest.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "GuestListTableViewCell", for: indexPath) as! GuestListTableViewCell
        cell.setupData(guest: viewModel.guest[indexPath.row])
        cell.delegate = self
        return cell
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        guard let date = viewModel.partyModel?.date, date >= Date() else { return nil }
        let footerView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.width, height: 60))
        let addRoomButton = UIButton(type: .custom)
        addRoomButton.setImage(UIImage.customAdd, for: .normal)
        addRoomButton.addTarget(self, action: #selector(addGuest), for: .touchUpInside)
        addRoomButton.frame = CGRect(x: (footerView.frame.width - 60) / 2, y: 0, width: 60, height: 60)
        footerView.addSubview(addRoomButton)
        return footerView
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        guard let date = viewModel.partyModel?.date, date >= Date() else { return 0 }
        return 60
    }
}

extension GuestListViewController: GuestListTableViewCellDelegate {
    func confirmationGuest(guest: GuestModel) {
        viewModel.confirmationGuest(guest: guest) { [weak self] error in
            guard let self = self else { return }
            if let error = error {
                self.showErrorAlert(message: error.localizedDescription)
            } else {
                viewModel.fetchData()
            }
        }
    }
}
