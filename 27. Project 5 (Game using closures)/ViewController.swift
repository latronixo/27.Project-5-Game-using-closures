//
//  ViewController.swift
//  27. Project 5 (Game using closures)
//
//  Created by Валентин Картошкин on 05.05.2025.
//

import UIKit

class ViewController: UITableViewController {
    
    var allWords = [String]()
    var usedWords = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(promptForAnswer))
        
        //находим в песочнице проекта файл start с расширением txt
        if let startWordsURL = Bundle.main.url(forResource: "start", withExtension: "txt") {
            //преобразуем его в строку (безопасно)
            if let startWords = try? String(contentsOf: startWordsURL) {
                //эту строку построчно помещаем в массив строк
                allWords = startWords.components(separatedBy: "\n")
            }
        }
        
        //если наполнить массив не удалось
        if allWords.isEmpty{
            allWords = ["silkworm"]
        }
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Word")
        
        startGame()
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        allWords.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Word", for: indexPath)
        cell.textLabel?.text = allWords[indexPath.row]
        return cell
    }
    
    //начало игры
    func startGame() {
        title = allWords.randomElement()
        usedWords.removeAll(keepingCapacity: true)
        tableView.reloadData()
    }
    
    //обработка нажатия на + в правой кнопке навбара
    @objc private func promptForAnswer() {
        let ac = UIAlertController(title: "Enter answer", message: nil, preferredStyle: .alert)
        
        //добавляем текстовое поле
        ac.addTextField()

        //создаем кнопку для алерта
        let submitAction = UIAlertAction(title: "Submit", style: .default) {
            [weak self, weak ac] action in
            guard let answer = ac?.textFields?[0].text else { return }
            self?.submit(answer)
        }
        
        //добавляем эту кнопку на алерт
        ac.addAction(submitAction)
        //показываем алерт
        present(ac, animated: true)
    }
    
    //обработка нажатия кнопки Submit внутри алерта
    private func submit(_ answer: String) {
        
    }
}
