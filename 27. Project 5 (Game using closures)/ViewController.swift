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
        usedWords.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Word", for: indexPath)
        cell.textLabel?.text = usedWords[indexPath.row]
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
        //переводим ответ в нижний регистр
        let lowerAnswer = answer.lowercased()
        
        let errorTitle: String
        let errorMessage: String
        
        //проверяем на возможность, оригинальность и реальность
        if isPossible(word: lowerAnswer){
            if isOriginal(word: lowerAnswer) {
                if isReal(word: lowerAnswer) {
                    //вставляем в массив использованных слов
                    usedWords.insert(answer, at: 0)
                    
                    //вставляем в начало tableView
                    let indexPath = IndexPath(row: 0, section: 0)
                    tableView.insertRows(at: [indexPath], with: .automatic)
                    
                    //выход из метода
                    return
                } else {
                    errorTitle = "Это слово не подходит"
                    errorMessage = "ты же не можешь просто так их выдумать, понимаешь!"
                }
            }else {
                errorTitle = "Это слово уже было"
                errorMessage = "Будь более оригинальным!"
            }
        } else {
            guard let title = title else { return }
            errorTitle = "Нет такого слова"
            errorMessage = "вы не можете произнести это слово по буквам из \(title.lowercased())"
        }
        
        let ac = UIAlertController(title: errorTitle, message: errorMessage, preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "OK", style: .default))
        present(ac, animated: true)
    }
    
    //проверка на вхождение всех букв слова пользователя в заданное слово (в title)
    private func isPossible(word: String) -> Bool {
        //безопасно получаем текст в title, заодно переводим в нижний регистр
        guard var tempWord = title?.lowercased() else { return false }
        
        for letter in word {
            if let position = tempWord.firstIndex(of: letter) {
                tempWord.remove(at: position)
            } else {
                return false
            }
        }
        
        return true
    }
    
    //проверка на оригинальность (запрещено пользователю вводить одно слово дважды)
    private func isOriginal(word: String) -> Bool {
        return !usedWords.contains(word)
    }
    
    //проверка на реальность (запрещено пользователю писать несуществующие слова)
    private func isReal(word: String) -> Bool {
        let checker = UITextChecker()
        let range = NSRange(location: 0, length: word.utf16.count)
        let misspelledRange = checker.rangeOfMisspelledWord(in: word, range: range, startingAt: 0, wrap: false, language: "en")
        return misspelledRange.location == NSNotFound
    }
}
