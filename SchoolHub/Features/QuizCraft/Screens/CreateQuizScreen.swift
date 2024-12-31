//
//  CreateQuizView.swift
//  SchoolHub
//
//  Created by Alexandru Simedrea on 26.12.2024.
//

import PhotosUI
import SwiftData
import SwiftUI

struct CreateQuizScreen: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    @ObservedObject var viewModel: PhotoReasoningViewModel
    @State private var isPhotosPickerPresented = false
    @State private var selectedImages: [Image] = []
    @State private var isQuestionGroupPresented = false
    @State private var errorMessage: String?
    
    @State private var title = ""
    @State private var questionType: QuestionType = .singleChoice
    @State private var difficulty: QuestionDifficulty = .easy
    @State private var count: Int = 5
    @State private var questionGroups: [QuestionGroup] = []
    @State private var quiz: Quiz = .init()
    
    var isGenerating: Bool {
        quiz.unwrappedGeneration.isGenerating
    }
    
    var isGenerated: Bool {
        quiz.unwrappedGeneration.isGenerated
    }
    
    var canCreate: Bool {
        !title.isEmpty
            && !questionGroups.isEmpty
            && !viewModel.selectedItems.isEmpty
            && !isGenerating
            && !isGenerated
    }
    
    var canEdit: Bool {
        !isGenerating && !isGenerated
    }
    
    var body: some View {
        NavigationStack {
            Form {
                if let errorMessage {
                    Section {
                        VStack {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .foregroundStyle(.red)
                                .font(.title)
                            Text(errorMessage)
                                .multilineTextAlignment(.center)
                                .foregroundStyle(.red)
                        }
                        .frame(maxWidth: .infinity, alignment: .center)
                    }
                }
                
                if quiz.unwrappedGeneration.isGenerating {
                    Section {
                        HStack {
                            ProgressView(
                                value: Double(quiz.unwrappedGeneration.generatedQuestions),
                                total: Double(quiz.questionsCount)
                                
                            ) {
                                Text("Generating")
                                    .font(.headline)
                            } currentValueLabel: {
                                Text("\(quiz.unwrappedGeneration.generatedQuestions) / \(quiz.questionsCount) questions")
                                    .font(.subheadline)
                            }
                            .animation(.easeInOut(duration: 1), value: quiz.unwrappedGeneration.generatedQuestions)
                        }
                    }
                }
                
                if quiz.unwrappedGeneration.isGenerated {
                    Section {
                        VStack(spacing: 6) {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundStyle(.green)
                                .font(.largeTitle)
                            Text("Generated")
                                .font(.headline)
                        }
                        .frame(maxWidth: .infinity, alignment: .center)
                    }
                }
                
                Section {
                    TextField("Quiz Title", text: $title)
                        .disabled(!canEdit)
                } header: {
                    Text("Title")
                } footer: {
                    Text("Give your quiz a descriptive title")
                }
                
                Section {
                    if !viewModel.selectedItems.isEmpty {
                        ScrollView(.horizontal) {
                            HStack {
                                ForEach(selectedImages.indices, id: \.self) { index in
                                    ZStack(alignment: .topTrailing) {
                                        selectedImages[index]
                                            .resizable()
                                            .aspectRatio(contentMode: .fill)
                                            .frame(width: 80, height: 80)
                                            .clipped()
                                            .clipShape(RoundedRectangle(cornerRadius: 8))
                                        
                                        if !isGenerating {
                                            Button {
                                                selectedImages.remove(at: index)
                                                viewModel.selectedItems.remove(at: index)
                                                quiz.images?.remove(at: index)
                                            } label: {
                                                Image(systemName: "xmark.circle.fill")
                                                    .foregroundStyle(.white)
                                                    .background(Circle().fill(.black.opacity(0.5)))
                                            }
                                            .padding(4)
                                        }
                                    }
                                }
                            }
                            .padding(.vertical, 4)
                        }
                    }
                    
                    Button("Add Materials", systemImage: "plus") {
                        isPhotosPickerPresented = true
                    }
                    .disabled(!canEdit)
                } header: {
                    Text("Materials")
                } footer: {
                    Text("Add images or documents to generate questions from")
                }
                
                Section {
                    ForEach(questionGroups.indices, id: \.self) { index in
                        HStack {
                            VStack(alignment: .leading) {
                                Text("\(questionGroups[index].type.rawValue)")
                                    .font(.headline)
                                Text("\(questionGroups[index].count) questions • \(questionGroups[index].difficulty.rawValue)")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                            
                            Spacer()
                            
                            if !isGenerating {
                                Button {
                                    questionGroups.remove(at: index)
                                } label: {
                                    Image(systemName: "trash")
                                        .foregroundStyle(.red)
                                }
                            }
                        }
                    }
                    
                    Button("Add Question Group", systemImage: "plus") {
                        isQuestionGroupPresented = true
                    }
                    .disabled(!canEdit)
                } header: {
                    Text("Question Groups")
                } footer: {
                    Text("Add different types of questions with varying difficulty")
                }
            }
            .navigationTitle("Create Quiz")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Create") {
                        Task {
                            await createQuiz()
                        }
                    }
                    .disabled(!canCreate)
                }
            }
            .photosPicker(
                isPresented: $isPhotosPickerPresented,
                selection: $viewModel.selectedItems,
                maxSelectionCount: 5,
                matching: .images
            )
            .sheet(isPresented: $isQuestionGroupPresented) {
                QuestionGroupSheet(
                    questionGroups: $questionGroups,
                    isPresented: $isQuestionGroupPresented
                )
            }
            .scrollDismissesKeyboard(.interactively)
            .onChange(of: viewModel.selectedItems) {
                Task {
                    do {
                        let quizImages = try await viewModel.processSelectedItems()
                        quiz.images = quizImages
                        
                        selectedImages = quizImages.compactMap { quizImage in
                            if let uiImage = UIImage(data: quizImage.imageData) {
                                return Image(uiImage: uiImage)
                            }
                            return nil
                        }
                    } catch {
                        print("❌❌❌❌❌❌ error \(error)")
                        errorMessage = error.localizedDescription
                    }
                }
            }
            .onChange(of: quiz.generation?.error) {
                if let error = quiz.generation?.error {
                    errorMessage = error
                }
            }
            .onDisappear {
                viewModel.selectedItems.removeAll()
            }
        }
    }
    
    private func createQuiz() async {
        withAnimation {
            errorMessage = nil
        }
        
        quiz.title = title
        quiz.questionGroups = questionGroups
        modelContext.insert(quiz)
        try? modelContext.save()
        
        Task {
            print("start generation")
            await viewModel.generateQuestions(for: quiz)
            
            if quiz.unwrappedGeneration.isGenerated {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    dismiss()
                }
            }
        }
    }
}

struct QuestionGroupSheet: View {
    @Binding var questionGroups: [QuestionGroup]
    @Binding var isPresented: Bool
    
    @State private var questionType: QuestionType = .singleChoice
    @State private var difficulty: QuestionDifficulty = .easy
    @State private var count: Int = 5
    
    var body: some View {
        NavigationStack {
            Form {
                Picker("Question Type", selection: $questionType) {
                    ForEach(QuestionType.allCases, id: \.self) { type in
                        Text(type.rawValue).tag(type)
                    }
                }
                
                Picker("Difficulty", selection: $difficulty) {
                    ForEach(QuestionDifficulty.allCases, id: \.self) { difficulty in
                        Text(difficulty.rawValue).tag(difficulty)
                    }
                }
                
                Picker("Number of Questions", selection: $count) {
                    ForEach(1 ... 10, id: \.self) { count in
                        Text("\(count)").tag(count)
                    }
                }
            }
            .navigationTitle("Add Question Group")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        isPresented = false
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") {
                        questionGroups.append(
                            QuestionGroup(
                                difficulty: difficulty,
                                type: questionType,
                                count: count,
                                questions: []
                            )
                        )
                        isPresented = false
                    }
                }
            }
        }
    }
}

#Preview {
    CreateQuizScreen(viewModel: .init())
}
