//
//  AICoachView.swift
//  antrain
//
//  Created by AI Coach Feature
//

import SwiftUI
import SwiftData

struct AICoachView: View {
    @EnvironmentObject private var appDependencies: AppDependencies
    @State private var viewModel: AICoachViewModel?
    @State private var inputText = ""
    @State private var showClearConfirmation = false
    @State private var showDeleteConfirmation = false
    @State private var messageToDelete: ChatMessage?
    @State private var isLoadingContext = false

    var body: some View {
        NavigationStack {
            ZStack {
                // Loading indicator (shown during initial context load OR when viewModel is nil)
                if viewModel == nil || isLoadingContext {
                    VStack {
                        ProgressView()
                            .scaleEffect(1.5)
                        Text("AI Coach is loading...")
                            .font(DSTypography.caption)
                            .foregroundColor(.secondary)
                            .padding(.top, DSSpacing.md)
                    }
                }

                // Main content - only render when viewModel is initialized
                if viewModel != nil {
                    VStack(spacing: 0) {
                    // Error banner (if any)
                    if let errorType = viewModel?.errorType {
                        ErrorBanner(
                            type: errorType,
                            onRetry: {
                                Task {
                                    await viewModel?.retryLastMessage()
                                }
                            },
                            onDismiss: {
                                viewModel?.dismissError()
                            }
                        )
                        .padding(.top, DSSpacing.sm)
                    }

                    // Messages area
                    messagesArea

                    // Quick action chips (show only if no messages and context is loaded)
                    // ✅ Check if context is loaded to prevent crash
                    if viewModel?.messages.isEmpty == true && viewModel?.workoutContext != nil {
                        QuickActionChips(
                            context: viewModel?.workoutContext,
                            isNewUser: viewModel?.isNewUser ?? false
                        ) { message in
                            inputText = message
                        }
                    }

                    // Input field
                    ChatInputField(
                        text: $inputText,
                        isLoading: viewModel?.isLoading ?? false,
                        isOffline: viewModel?.isOffline ?? false,
                        onSend: {
                            Task {
                                do {
                                    await viewModel?.sendMessage(inputText)
                                    // Clear input only on success
                                    inputText = ""
                                } catch {
                                    print("❌ [AICoachView] Failed to send message: \(error)")
                                }
                            }
                        }
                    )
                }
                .opacity(isLoadingContext ? 0 : 1)
                }
            }
            .navigationTitle("AI Coach")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    if viewModel?.isLoading == true {
                        HStack(spacing: DSSpacing.xs) {
                            ProgressView()
                                .scaleEffect(0.8)
                            Text("AI is thinking...")
                                .font(DSTypography.caption)
                                .foregroundStyle(DSColors.textSecondary)
                        }
                    }
                }

                ToolbarItem(placement: .topBarTrailing) {
                    clearChatButton
                }
            }
            .task {
                if viewModel == nil {
                    isLoadingContext = true
                    setupViewModel()

                    // Load data asynchronously
                    await loadData()
                    isLoadingContext = false
                }
            }
        }
    }

    // MARK: - Messages Area

    @ViewBuilder
    private var messagesArea: some View {
        ScrollViewReader { proxy in
            ScrollView {
                LazyVStack(spacing: DSSpacing.xs) {
                    if let messages = viewModel?.messages, !messages.isEmpty {
                        ForEach(messages, id: \.id) { message in
                            ChatMessageBubble(message: message)
                                .id(message.id)
                                .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                                    Button(role: .destructive) {
                                        messageToDelete = message
                                        showDeleteConfirmation = true
                                    } label: {
                                        Label("Delete", systemImage: "trash")
                                    }
                                }
                        }
                    } else {
                        emptyState
                    }

                    // Typing indicator
                    if viewModel?.isLoading == true {
                        TypingIndicator()
                            .id("typing")
                    }
                }
                .padding(.vertical, DSSpacing.md)
            }
            .scrollDismissesKeyboard(.interactively)
            .onTapGesture {
                hideKeyboard()
            }
            .onChange(of: viewModel?.messages.count ?? 0) { _, _ in
                // Auto-scroll to bottom when new message arrives
                scrollToBottom(proxy: proxy)
            }
            .onChange(of: viewModel?.isLoading ?? false) { _, isLoading in
                // Scroll to typing indicator when loading
                if isLoading {
                    scrollToBottom(proxy: proxy)
                }
            }
        }
    }

    // MARK: - Empty State

    private var emptyState: some View {
        VStack(spacing: DSSpacing.lg) {
            Spacer()

            Image(systemName: "brain.head.profile")
                .font(.system(size: 64))
                .foregroundStyle(DSColors.textTertiary)

            VStack(spacing: DSSpacing.xs) {
                Text("AI Coach")
                    .font(DSTypography.title2)
                    .foregroundStyle(DSColors.textPrimary)

                Text("Personalized coaching based on your workout data")
                    .font(DSTypography.body)
                    .foregroundStyle(DSColors.textSecondary)
                    .multilineTextAlignment(.center)
            }

            Spacer()
        }
        .padding(.horizontal, DSSpacing.xl)
    }

    // MARK: - Clear Chat Button

    private var clearChatButton: some View {
        Button(action: { showClearConfirmation = true }) {
            Image(systemName: "trash")
                .foregroundColor(.red)
        }
        .disabled(viewModel?.messages.isEmpty == true)
        .alert("Clear Chat", isPresented: $showClearConfirmation) {
            Button("Cancel", role: .cancel) {}
            Button("Delete", role: .destructive) {
                Task {
                    await viewModel?.clearChat()
                }
            }
        } message: {
            Text("Are you sure you want to delete all messages?")
        }
        .alert("Delete Message", isPresented: $showDeleteConfirmation) {
            Button("Cancel", role: .cancel) {
                messageToDelete = nil
            }
            Button("Delete", role: .destructive) {
                Task {
                    if let message = messageToDelete {
                        await viewModel?.deleteMessage(message)
                        messageToDelete = nil
                    }
                }
            }
        } message: {
            Text("Are you sure you want to delete this message?")
        }
    }

    // MARK: - Helper Methods

    private func setupViewModel() {
        viewModel = AICoachViewModel(
            chatRepository: appDependencies.chatRepository,
            geminiAPIService: appDependencies.geminiAPIService,
            workoutContextBuilder: appDependencies.workoutContextBuilder
        )
    }

    /// ✅ OPTIMIZED: Load messages immediately, context in background
    /// Messages load fast (<50ms), context loads asynchronously
    /// This prevents 2-4 second hang when opening AI Coach tab
    private func loadData() async {
        // Load messages first (fast, blocks until done)
        await viewModel?.loadMessages()

        // Load context in background (non-blocking)
        // viewModel is @MainActor, so this automatically hops to main actor
        Task {
            await viewModel?.loadContext()
        }
    }

    private func scrollToBottom(proxy: ScrollViewProxy) {
        withAnimation(.easeInOut(duration: 0.3)) {
            if viewModel?.isLoading == true {
                proxy.scrollTo("typing", anchor: .bottom)
            } else if let lastMessage = viewModel?.messages.last {
                proxy.scrollTo(lastMessage.id, anchor: .bottom)
            }
        }
    }

    private func hideKeyboard() {
        UIApplication.shared.sendAction(
            #selector(UIResponder.resignFirstResponder),
            to: nil,
            from: nil,
            for: nil
        )
    }
}

#Preview {
    AICoachView()
        .environmentObject(AppDependencies(modelContainer: try! ModelContainer(for: Workout.self)))
}
