import Foundation
import FoundationNetworking
import Dispatch

struct Question: Codable {
    let type: String
    let difficulty: String
    let category: String
    let question: String
    let correct_answer: String
    let incorrect_answers: [String]
}

struct Response: Codable {
    let response_code: Int
    let results: [Question]
}

func fetchQuestions(amount: Int, completion: @escaping ([Question]?) -> Void) {
    guard let url = URL(string: "https://opentdb.com/api.php?amount=\(amount)") else {
        print("Invalid URL")
        completion(nil)
        return
    }

    let task = URLSession.shared.dataTask(with: url) { data, response, error in
        guard let data = data, error == nil else {
            print("Failed to fetch data: \(error?.localizedDescription ?? "Unknown error")")
            completion(nil)
            return
        }
        do {
            let triviaResponse = try JSONDecoder().decode(Response.self, from: data)
            completion(triviaResponse.results)
        } catch {
            print("Failed to decode JSON: \(error.localizedDescription)")
            completion(nil)
        }
    }
    task.resume()
}

func displayQuestion(_ question: Question) {
    print("""
    Category: \(question.category)
    Difficulty: \(question.difficulty)
    Question: \(question.question)
    """)

    var answers = question.incorrect_answers + [question.correct_answer]
    answers.shuffle()

    for (index, answer) in answers.enumerated() {
        print("\(index + 1). \(answer)")
    }

    guard let userAnswer = getUserAnswer(count: answers.count) else {
        print("Failed to get a valid answer.")
        return
    }

    if answers[userAnswer - 1] == question.correct_answer {
        print("Correct!")
    } else {
        print("Incorrect. The correct answer was: \(question.correct_answer)")
    }
}

func getUserAnswer(count: Int) -> Int? {
    var userAnswer: Int?
    repeat {
        if let input = readLine(), let number = Int(input), (1...count).contains(number) {
            userAnswer = number
        } else {
            print("Invalid input. Please enter a number between 1 and \(count).")
        }
    } while userAnswer == nil
    return userAnswer
}

func getNumberOfQuestions() -> Int {
    var numberOfQuestions: Int?
    repeat {
        print("How many questions would you like to answer?")
        if let input = readLine(), let number = Int(input), number > 0 {
            numberOfQuestions = number
        } else {
            print("Invalid input. Please enter a positive number.")
        }
    } while numberOfQuestions == nil
    return numberOfQuestions!
}

let numberOfQuestions = getNumberOfQuestions()

fetchQuestions(amount: numberOfQuestions) { questions in
    guard let questions = questions else {
        print("No questions available.")
        exit(EXIT_FAILURE)
    }

    for question in questions {
        displayQuestion(question)
    }

    exit(EXIT_SUCCESS)
}

dispatchMain()
