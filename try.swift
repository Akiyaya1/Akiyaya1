import SwiftUI

struct ContentView: View {
    @State private var cards: [Card] = []
    @State private var showAddCardView: Bool = false
    @State private var showQuizView: Bool = false
    
    var body: some View {
        ZStack {
            Color.black.edgesIgnoringSafeArea(.all)
            
            VStack {
                if cards.isEmpty {
                    Text("Нет карточек")
                        .font(.title)
                        .foregroundColor(.white)
                } else {
                    List {
                        ForEach(cards.indices, id: \.self) { index in
                            VStack(alignment: .leading) {
                                Text(cards[index].question)
                                    .font(.title2)
                                    .foregroundColor(.white)
                                Text("Ответ: \(cards[index].answer)")
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                            }
                            .padding()
                            .background(Color.gray.opacity(0.1))
                            .cornerRadius(10)
                        }
                        .onDelete(perform: deleteCard)
                    }
                    .listStyle(PlainListStyle())
                    .background(Color.black)
                }
                
                Spacer()
                
                HStack {
                    Button(action: {
                        showAddCardView = true
                    }) {
                        Text("Добавить карточку")
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.blue)
                            .cornerRadius(10)
                    }
                    
                    if !cards.isEmpty {
                        Button(action: {
                            showQuizView = true
                        }) {
                            Text("Начать викторину")
                                .font(.headline)
                                .foregroundColor(.white)
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(Color.green)
                                .cornerRadius(10)
                        }
                    }
                }
                .padding()
            }
        }
        .sheet(isPresented: $showAddCardView) {
            AddCardView(cards: $cards)
        }
        .sheet(isPresented: $showQuizView) {
            QuizView(cards: $cards)
        }
        .onAppear {
            loadCards()
        }
    }
    
    private func deleteCard(at offsets: IndexSet) {
        cards.remove(atOffsets: offsets)
        saveCards()
    }
    
    private func loadCards() {
        if let data = UserDefaults.standard.data(forKey: "cards") {
            if let decoded = try? JSONDecoder().decode([Card].self, from: data) {
                cards = decoded
            }
        }
    }
    
    private func saveCards() {
        if let encoded = try? JSONEncoder().encode(cards) {
            UserDefaults.standard.set(encoded, forKey: "cards")
        }
    }
}

struct AddCardView: View {
    @Binding var cards: [Card]
    
    @State private var question: String = ""
    @State private var answer: String = ""
    @State private var wrongAnswer1: String = ""
    @State private var wrongAnswer2: String = ""
    @State private var wrongAnswer3: String = ""
    
    var body: some View {
        ZStack {
            Color.black.edgesIgnoringSafeArea(.all)
            
            VStack {
                TextField("Введите вопрос", text: $question)
                    .font(.title)
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(10)
                    .padding()
                
                TextField("Правильный ответ", text: $answer)
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(10)
                    .padding(.horizontal)
                
                TextField("Неправильный ответ 1", text: $wrongAnswer1)
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(10)
                    .padding(.horizontal)
                
                TextField("Неправильный ответ 2", text: $wrongAnswer2)
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(10)
                    .padding(.horizontal)
                
                TextField("Неправильный ответ 3", text: $wrongAnswer3)
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(10)
                    .padding(.horizontal)
                
                Button(action: {
                    let newCard = Card(
                        question: question,
                        answer: answer,
                        wrongAnswers: [wrongAnswer1, wrongAnswer2, wrongAnswer3]
                    )
                    cards.append(newCard)
                    saveCards(cards: cards)
                    question = ""
                    answer = ""
                    wrongAnswer1 = ""
                    wrongAnswer2 = ""
                    wrongAnswer3 = ""
                }) {
                    Text("Добавить карточку")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.blue)
                        .cornerRadius(10)
                        .padding()
                }
            }
        }
    }
    
    private func saveCards(cards: [Card]) {
        if let encoded = try? JSONEncoder().encode(cards) {
            UserDefaults.standard.set(encoded, forKey: "cards")
        }
    }
}

struct Card: Codable, Identifiable {
    let id = UUID()
    let question: String
    let answer: String
    let wrongAnswers: [String]
    
    var allAnswers: [String] {
        var answers = wrongAnswers
        answers.append(answer)
        return answers.shuffled() 
    }
}

struct QuizView: View {
    @Binding var cards: [Card]
    
    @State private var currentCardIndex: Int = 0
    @State private var selectedAnswer: String = ""
    @State private var showResult: Bool = false
    @State private var isCorrect: Bool = false
    
    var body: some View {
        ZStack {
            Color.black.edgesIgnoringSafeArea(.all)
            
            VStack {
                if currentCardIndex < cards.count {
                    Text(cards[currentCardIndex].question)
                        .font(.title)
                        .foregroundColor(.white)
                        .padding()
                    
                    // Отображение всех ответов
                    ForEach(cards[currentCardIndex].allAnswers, id: \.self) { answer in
                        Button(action: {
                            selectedAnswer = answer
                            checkAnswer()
                        }) {
                            Text(answer)
                                .font(.headline)
                                .foregroundColor(.white)
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(Color.gray.opacity(0.2))
                                .cornerRadius(10)
                                .padding(.horizontal)
                        }
                    }
                    
                    if showResult {
                        Text(isCorrect ? "Правильно!" : "Неправильно!")
                            .font(.title2)
                            .foregroundColor(isCorrect ? .green : .red)
                            .padding()
                        
                        Button(action: {
                            nextQuestion()
                        }) {
                            Text("Следующий вопрос")
                                .font(.headline)
                                .foregroundColor(.white)
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(Color.green)
                                .cornerRadius(10)
                                .padding()
                        }
                    }
                } else {
                    Text("Викторина завершена!")
                        .font(.title)
                        .foregroundColor(.white)
                        .padding()
                    
                    Button(action: {
                        currentCardIndex = 0
                        selectedAnswer = ""
                        showResult = false
                    }) {
                        Text("Начать заново")
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.blue)
                            .cornerRadius(10)
                            .padding()
                    }
                }
            }
        }
    }
    
    // Проверка ответа
    private func checkAnswer() {
        if selectedAnswer == cards[currentCardIndex].answer {
            isCorrect = true
        } else {
            isCorrect = false
        }
        showResult = true
    }
    
    private func nextQuestion() {
        currentCardIndex += 1
        selectedAnswer = ""
        showResult = false
    }
}
struct CardApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
