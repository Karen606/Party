//
//  CoctailsViewController.swift
//  Party
//
//  Created by Karen Khachatryan on 17.10.24.
//

import UIKit
import Combine

class CoctailsViewController: UIViewController {

    @IBOutlet weak var coctailsTableView: UITableView!
    private let viewModel = CoctailsViewModel.shared
    private var cancellables: Set<AnyCancellable> = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setNavigationBar(title: "Cocktail")
        setupTableView()
        subscribe()
        viewModel.fetchData()
    }
    
    func setupTableView() {
        coctailsTableView.delegate = self
        coctailsTableView.dataSource = self
        coctailsTableView.register(UINib(nibName: "CoctailTableViewCell", bundle: nil), forCellReuseIdentifier: "CoctailTableViewCell")
    }
    
    func subscribe() {
        viewModel.$coctails
            .receive(on: DispatchQueue.main)
            .sink { [weak self] coctails in
                guard let self = self else { return }
                self.coctailsTableView.reloadData()
            }
            .store(in: &cancellables)
    }
    
    @objc func addCoctail() {
        let coctailFormVC = CoctailFormViewController(nibName: "CoctailFormViewController", bundle: nil)
        coctailFormVC.completion = { [weak self] in
            guard let self = self else { return }
            self.viewModel.fetchData()
        }
        self.navigationController?.pushViewController(coctailFormVC, animated: true)
    }
    
    deinit {
        viewModel.clear()
    }
}

extension CoctailsViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.coctails.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CoctailTableViewCell", for: indexPath) as! CoctailTableViewCell
        cell.setupData(coctail: viewModel.coctails[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let footerView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.width, height: 84))
        let addRoomButton = UIButton(type: .custom)
        addRoomButton.setImage(UIImage.customAdd, for: .normal)
        addRoomButton.addTarget(self, action: #selector(addCoctail), for: .touchUpInside)
        addRoomButton.frame = CGRect(x: (footerView.frame.width - 60) / 2, y: 24, width: 60, height: 60)
        footerView.addSubview(addRoomButton)
        return footerView
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        84
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let coctailFormVC = CoctailFormViewController(nibName: "CoctailFormViewController", bundle: nil)
        CoctailFormViewModel.shared.coctail = viewModel.coctails[indexPath.row]
        coctailFormVC.completion = { [weak self] in
            guard let self = self else { return }
            self.viewModel.fetchData()
        }
        self.navigationController?.pushViewController(coctailFormVC, animated: true)
    }
}
