//
//  QuizCraftScreen.swift
//  SchoolHub
//
//  Created by Alexandru Simedrea on 26.12.2024.
//

import GoogleGenerativeAI
import PhotosUI
import SwiftData
import SwiftUI

struct QuizCraftScreen: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Quiz.createdAt, order: .reverse) private var quizzes: [Quiz]
    @StateObject var viewModel: PhotoReasoningViewModel = .init()
    @State private var navigationPath = NavigationPath()
    @State private var isShowingCreateQuiz = false
    
    var body: some View {
        NavigationStack(path: $navigationPath) {
            List {
                Section {
                    Button {
                        isShowingCreateQuiz = true
                    } label: {
                        HStack {
                            Image(systemName: "note.text.badge.plus")
                            Text("Create a new quiz")
                                .bold()
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.indigo)
                        .foregroundStyle(.white)
                        .clipShape(.rect(cornerRadius: 20))
                    }
                    .buttonStyle(.plain)
                    .listRowInsets(.init())
                    .listRowBackground(Color.clear)
                }
//                Section("Create a new quiz") {
//                    NavigationLink {
//                        CreateQuizScreen(viewModel: viewModel)
//                    } label: {
//                        HStack {
//                            Image(systemName: "plus")
//                            Text("Create a new quiz")
//                        }
//                    }
//                }
//                .headerProminence(.increased)
                
                Section("Quizzes") {
                    if quizzes.isEmpty {
                        ContentUnavailableView(
                            "No Quizzes",
                            systemImage: "questionmark.square.dashed",
                            description: Text("Create your first quiz to get started")
                        )
                    } else {
                        ForEach(quizzes) { quiz in
                            NavigationLink {
                                if let isGenerated = quiz.generation?.isGenerated {
                                    if isGenerated {
                                        QuizScreen(quiz: quiz)
                                    } else {
                                        QuizGeneratingView(quiz: quiz, viewModel: viewModel)
                                    }
                                }
                            } label: {
                                QuizRowView(quiz: quiz)
                            }
                        }
                        .onDelete(perform: deleteQuizzes)
                    }
                }
                .headerProminence(.increased)
            }
            .navigationTitle("QuizCraft")
            .sheet(isPresented: $isShowingCreateQuiz) {
                CreateQuizScreen(viewModel: viewModel)
            }
        }
    }
    
    private func deleteQuizzes(offsets: IndexSet) {
        withAnimation {
            for index in offsets {
                modelContext.delete(quizzes[index])
            }
        }
    }
}

struct QuizRowView: View {
    let quiz: Quiz
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(quiz.title)
                    .font(.headline)
                Text("\(quiz.questionsCount) questions")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            
            Spacer()
            
            if !quiz.unwrappedAttempts.isEmpty {
                Text("Best: \(quiz.unwrappedAttempts.map(\.score).max() ?? 0)%")
                    .font(.callout)
                    .foregroundStyle(.secondary)
            }
            if let generation = quiz.generation {
                if let error = generation.error, !error.isEmpty {
                    HStack {
                        Image(systemName: "exclamationmark.triangle.fill")
                        Text("Generation Error")
                            .font(.callout)
                    }
                    .foregroundStyle(.secondary)
                }
                if generation.isGenerating {
                    ProgressView()
                }
            }
        }
    }
}

struct QuizGeneratingView: View {
    let quiz: Quiz
    @ObservedObject var viewModel: PhotoReasoningViewModel
    
    var body: some View {
        Group {
            if quiz.unwrappedGeneration.isGenerating {
                VStack(spacing: 20) {
                    ProgressView()
                    Text("Generating questions...")
                }
            } else if let error = quiz.unwrappedGeneration.error {
                ContentUnavailableView {
                    Label("Generation Failed", systemImage: "exclamationmark.triangle")
                } description: {
                    Text(error)
                } actions: {
                    Button("Try Again") {
                        Task { await viewModel.generateQuestions(for: quiz) }
                    }
                }
            }
        }
    }
}

#Preview {
    QuizCraftScreen()
}
