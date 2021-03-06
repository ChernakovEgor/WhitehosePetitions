//
//  ViewController.swift
//  WhitehosePetitions
//
//  Created by Egor Chernakov on 06.03.2021.
//

import UIKit

class ViewController: UITableViewController {
    
    var petitions = [Petition]()
    var filteredPetitions = [Petition]()
    var urlString: String {
        if navigationController?.tabBarItem.tag == 0  {
        return "https://www.hackingwithswift.com/samples/petitions-1.json"
        } else {
            return "https://www.hackingwithswift.com/samples/petitions-2.json"
        }
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Credits", style: .plain, target: self, action: #selector(showCredits))
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Filter", style: .plain, target: self, action: #selector(showFilter))
        
        if let url = URL(string: urlString) {
            if let data = try? Data(contentsOf: url) {
                parse(json: data)
                tableView.reloadData()
            }
        }
    }
    
    func parse(json: Data) {
        let decoder = JSONDecoder()
        if let decoded = try? decoder.decode(Petitions.self, from: json) {
            petitions = decoded.results
        }
    }
    
    @objc func showCredits() {
        let ac = UIAlertController(title: "Credits", message: "Data comes from the We The People API of the Whitehouse.", preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "Close", style: .default, handler: nil))
        present(ac, animated: true)
    }
    
    func filter(containing word: String) {
        filteredPetitions.removeAll()
        for petition in petitions {
            if petition.title.localizedCaseInsensitiveContains(word) || petition.body.localizedCaseInsensitiveContains(word) {
                filteredPetitions.append(petition)
            }
        }
        tableView.reloadData()
    }
    
    @objc func showFilter() {
        let ac = UIAlertController(title: "Filter", message: "Enter search words", preferredStyle: .alert)
        ac.addTextField()
        ac.addAction(UIAlertAction(title: "Search", style: .default, handler: { [weak ac, weak self] _ in
            guard let word = ac?.textFields?[0].text else { return }
            self?.filter(containing: word)
        }))
        present(ac, animated: true)
    }
}

//MARK: TableView Data Source
extension ViewController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredPetitions.isEmpty ? petitions.count : filteredPetitions.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let dataSource = filteredPetitions.isEmpty ? petitions : filteredPetitions
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        let petition = dataSource[indexPath.row]
        cell.textLabel?.text = petition.title
        cell.detailTextLabel?.text = petition.body
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc = DetailViewController()
        vc.petition = (filteredPetitions.isEmpty ? petitions : filteredPetitions)[indexPath.row]
        navigationController?.pushViewController(vc, animated: true)
    }
}
