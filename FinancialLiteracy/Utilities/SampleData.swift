import Foundation

struct SampleData {
    static let chapters: [Chapter] = [
        Chapter(
            title: "Financial Basics",
            description: "Learn the fundamental concepts of personal finance",
            questions: [
                Question(
                    title: "Income Understanding",
                    questionText: "What is the difference between gross and net income?",
                    options: [
                        "There is no difference",
                        "Gross income is before taxes, net income is after taxes",
                        "Net income is before taxes, gross income is after taxes",
                        "They are different terms for the same thing"
                    ],
                    correctAnswer: 1
                ),
                Question(
                    title: "Budgeting Basics",
                    questionText: "What is the 50/30/20 rule in budgeting?",
                    options: [
                        "50% savings, 30% needs, 20% wants",
                        "50% needs, 30% wants, 20% savings",
                        "50% wants, 30% savings, 20% needs",
                        "50% needs, 30% savings, 20% wants"
                    ],
                    correctAnswer: 1
                )
            ]
        ),
        Chapter(
            title: "Saving Strategies",
            description: "Master different approaches to saving money",
            questions: [
                Question(
                    title: "Emergency Fund",
                    questionText: "How much should an emergency fund typically cover?",
                    options: [
                        "1 month of expenses",
                        "3-6 months of expenses",
                        "1 year of expenses",
                        "2 weeks of expenses"
                    ],
                    correctAnswer: 1
                ),
                Question(
                    title: "Saving Methods",
                    questionText: "Which saving method involves automatically transferring money to savings?",
                    options: [
                        "Manual saving",
                        "Envelope method",
                        "Automatic saving",
                        "Cash stuffing"
                    ],
                    correctAnswer: 2
                )
            ]
        ),
        Chapter(
            title: "Investment Basics",
            description: "Understanding fundamental investment concepts",
            questions: [
                Question(
                    title: "Stock Market",
                    questionText: "What is a stock?",
                    options: [
                        "A type of bond",
                        "A ownership share in a company",
                        "A savings account",
                        "A type of cryptocurrency"
                    ],
                    correctAnswer: 1
                ),
                Question(
                    title: "Risk Management",
                    questionText: "What is diversification?",
                    options: [
                        "Putting all money in one investment",
                        "Spreading investments across different assets",
                        "Only investing in stocks",
                        "Only investing in bonds"
                    ],
                    correctAnswer: 1
                )
            ]
        )
    ]
} 