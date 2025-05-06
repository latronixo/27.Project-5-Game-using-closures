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
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .refresh, target: self, action: #selector(startGame))
        
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
    @objc private func startGame() {
        title = allWords.randomElement()
        usedWords.removeAll(keepingCapacity: true)
        tableView.reloadData()
    }
    
    //обработка нажатия на + в правой кнопке навбара
    @objc private func promptForAnswer() {
        let ac = UIAlertController(title: "Enter answer", message: nil, preferredStyle: .alert)
        
        //добавляем текстовое поле
        ac.addTextField { textField in
            //используем NotificationCenter для отслеживания изменений текста в текстовом поле внутри алерта
            NotificationCenter.default.addObserver(forName: UITextField.textDidChangeNotification, object: textField, queue: .main) { [weak textField] _ in
                guard let txField = textField else { return }
                    if let text = txField.text {
                        txField.text = text.lowercased()
                }
            }
        }

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
        
        //проверяем на возможность, оригинальность и реальность
        if isPossible(word: lowerAnswer){
            if isOriginal(word: lowerAnswer) {
                if isReal(word: lowerAnswer) {
                    if isDiffersFromOriginalWord (word: lowerAnswer) {
                        //вставляем в массив использованных слов
                        usedWords.insert(answer, at: 0)
                        
                        //вставляем в начало tableView
                        let indexPath = IndexPath(row: 0, section: 0)
                        tableView.insertRows(at: [indexPath], with: .automatic)
                        
                        //выход из метода
                        return
                    } else {
                        showErrorMessage(errorTitle: "Это слово не подходит", errorMessage: "ты же не понимаешь, что оно такое же, что и исходное слово!")
                    }
                } else {
                    showErrorMessage(errorTitle: "Это слово не подходит", errorMessage: "ты же не можешь просто так их выдумать, понимаешь!")
                }
            } else {
                showErrorMessage(errorTitle: "Это слово уже было", errorMessage: "Будь более оригинальным!")
            }
        } else {
            guard let title = title else { return }
            showErrorMessage(errorTitle: "Нет такого слова", errorMessage: "вы не можете произнести это слово по буквам из \(title.lowercased())")
        }
    }
    
    //проверка на вхождение всех букв слова пользователя в заданное слово (в title)
    private func isPossible(word: String) -> Bool {
        //безопасно получаем текст в title, заодно переводим в нижний регистр
        guard var tempWord = title?.lowercased() else { return false }
        
        if tempWord != word {
            for letter in word {
                if let position = tempWord.firstIndex(of: letter) {
                    tempWord.remove(at: position)
                } else {
                    return false
                }
            }
        } else {
            //если слово пользователя совпадает с заданным словом
            return false
        }
        
        return true
    }

    //проверка, не совпадает ли слово пользователя с заданным словом
    private func isDiffersFromOriginalWord (word: String) -> Bool {
        guard let tempWord = title?.lowercased() else { return false }
        
        if tempWord == word {
            return false
        } else {
            return true
        }
    }
    
    //проверка на оригинальность (запрещено пользователю вводить одно слово дважды)
    private func isOriginal(word: String) -> Bool {
        return !usedWords.contains(word)
    }
    
    //проверка на реальность (запрещено пользователю писать несуществующие слова)
    private func isReal(word: String) -> Bool {
        if word.count > 2 {
            //если в слове больше 2 символов
            let checker = UITextChecker()
            let range = NSRange(location: 0, length: word.utf16.count)
            let misspelledRange = checker.rangeOfMisspelledWord(in: word, range: range, startingAt: 0, wrap: false, language: "en")
            return misspelledRange.location == NSNotFound
        } else  {
            return false
        }
    }
    
    //вызов алерта с текстом, что пользователь сделал не так
    private func showErrorMessage(errorTitle: String, errorMessage: String) {
        let ac = UIAlertController(title: errorTitle, message: errorMessage, preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "OK", style: .default))
        present(ac, animated: true)
    }

}
