//
//  PartiesViewController.swift
//  Party
//
//  Created by Karen Khachatryan on 15.10.24.
//

import UIKit
import Combine

class PartiesViewController: UIViewController {

    @IBOutlet weak var partiesTableView: UITableView!
    @IBOutlet weak var partiesTypeButton: UIButton!
    private let viewModel = PartiesViewModel.shared
    private var cancellables: Set<AnyCancellable> = []

    override func viewDidLoad() {
        super.viewDidLoad()
        setNavigationBar(title: "My partyes", setButtons: false)
        setNaviagtionMenuButton()
        setupTableView()
        subscribe()
        viewModel.fetchData()
    }
    
    func setupTableView() {
        partiesTableView.delegate = self
        partiesTableView.dataSource = self
        partiesTableView.register(UINib(nibName: "PartyTableViewCell", bundle: nil), forCellReuseIdentifier: "PartyTableViewCell")
    }
    
    func subscribe() {
        viewModel.$parties
            .receive(on: DispatchQueue.main)
            .sink { [weak self] partyModel in
                guard let self = self else { return }
                self.partiesTableView.reloadData()
            }
            .store(in: &cancellables)
    }
    
    @objc func addParty() {
        let createPartyVC = CreatePartyViewController(nibName: "CreatePartyViewController", bundle: nil)
        createPartyVC.completion = { [weak self] in
            guard let self = self else { return }
            self.viewModel.fetchData()
        }
        self.navigationController?.pushViewController(createPartyVC, animated: true)
    }
    
    @IBAction func clickedPartiesType(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        let type = sender.isSelected ? PartyType.past : .upcoming
        viewModel.filter(type: type)
    }
    
    deinit {
        viewModel.clear()
    }
}

extension PartiesViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.parties.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PartyTableViewCell", for: indexPath) as! PartyTableViewCell
        cell.setupData(party: viewModel.parties[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let footerView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.width, height: 60))
        let addRoomButton = UIButton(type: .custom)
        addRoomButton.setImage(UIImage.customAdd, for: .normal)
        addRoomButton.addTarget(self, action: #selector(addParty), for: .touchUpInside)
        addRoomButton.frame = CGRect(x: (footerView.frame.width - 60) / 2, y: 0, width: 60, height: 60)
        footerView.addSubview(addRoomButton)
        return footerView
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        60
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let guestListVC = GuestListViewController(nibName: "GuestListViewController", bundle: nil)
        GuestListViewModel.shared.partyModel = viewModel.parties[indexPath.row]
        self.navigationController?.pushViewController(guestListVC, animated: true)
    }
}
