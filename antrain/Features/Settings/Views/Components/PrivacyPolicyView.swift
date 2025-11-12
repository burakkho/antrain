import SwiftUI

/// Displays the app's privacy policy
struct PrivacyPolicyView: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: DSSpacing.lg) {
                Text(privacyPolicyText)
                    .font(DSTypography.body)
                    .foregroundStyle(DSColors.textPrimary)
                    .textSelection(.enabled)
            }
            .padding(DSSpacing.lg)
        }
        .navigationTitle(Text("Privacy Policy"))
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "xmark")
                        .foregroundStyle(DSColors.textSecondary)
                }
            }
        }
    }

    // MARK: - Privacy Policy Text

    private var privacyPolicyText: AttributedString {
        let markdown = """
        # Privacy Policy for Antrain

        **Last Updated:** January 11, 2025

        ## Introduction

        Antrain ("we", "our", or "us") is committed to protecting your privacy. This Privacy Policy explains how we handle your information when you use our fitness tracking application.

        ## Data Collection and Storage

        **Most data is stored locally on your device only.**

        Antrain generally does NOT:
        - Collect any personal information
        - Track your location
        - Access your contacts
        - Use analytics or tracking services
        - Require account creation or login

        **Exception - AI Coach Feature:**
        When you use the AI Coach feature, your workout data is sent to Google's Gemini API to provide personalized fitness guidance. See "AI Coach & Third-Party Services" section below for details.

        ## What Data is Stored Locally

        The following data is stored only on your device using Apple's SwiftData framework:

        ### Workout Data
        - Exercise logs (sets, reps, weights)
        - Workout history and dates
        - Personal records (PRs)
        - Cardio and MetCon workout logs
        - Custom exercises you create

        ### Nutrition Data
        - Daily food logs and meals
        - Macro tracking (calories, protein, carbs, fats)
        - Custom food items you create
        - Daily nutrition goals

        ### Profile Data
        - Your name (optional)
        - Body weight entries
        - Nutrition goal preferences
        - Unit preferences (kg/lbs, etc.)

        ## Data Ownership

        - You own 100% of your data
        - Your data is stored locally on your device
        - Data only leaves your device when you use AI Coach (sent to Google Gemini)
        - Deleting the app deletes all your local data permanently
        - No cloud backup or sync to our servers (all local to your device)

        ## AI Coach & Third-Party Services

        ### AI Coach Feature (Google Gemini API)

        Antrain's AI Coach feature uses **Google's Gemini AI API** to provide personalized fitness guidance. This is the ONLY third-party service we use.

        **When You Use AI Coach:**

        Data sent to Google Gemini includes:
        - Your last 30 days of workout data (exercises, sets, reps, weights, dates)
        - Your personal records (PRs) for exercises
        - Your nutrition data (daily macros, calorie intake)
        - Your active training program (if any)
        - Your profile information (name, bodyweight, goals, fitness level)
        - Your chat messages with the AI Coach

        **Important Details:**
        - ✅ Data is only sent when you actively use the AI Coach tab
        - ✅ Your data is processed by Google to generate AI responses
        - ✅ All conversations are stored locally on your device
        - ✅ You can delete conversations anytime
        - ✅ You can simply avoid the AI Coach tab if you prefer complete privacy
        - ✅ All other features remain 100% local and private

        **Google's Privacy Policy:**
        Google Gemini's data handling is governed by Google's Privacy Policy: https://policies.google.com/privacy

        **Data Retention:**
        - Google may retain your data according to their privacy policy
        - We do not have control over Google's data retention
        - Chat conversations are stored locally on your device only

        ### Other Third-Party Services

        Antrain does NOT use:
        - Analytics services (Google Analytics, Firebase Analytics, etc.)
        - Advertising networks
        - Crash reporting services
        - Cloud storage services (your data is not backed up to our servers)
        - Social media integrations

        ## Children's Privacy

        Antrain does not knowingly collect any information from children under 13 years of age. The app is designed for users 17+ as it contains fitness content.

        ## HealthKit Integration

        Currently, Antrain does NOT integrate with Apple HealthKit. If we add this feature in the future:
        - We will request your explicit permission
        - Data will only sync if you approve
        - You can revoke access anytime in iOS Settings

        ## Data Security

        Your data is protected by:
        - iOS device encryption (when device is locked)
        - Apple's sandboxed app environment
        - HTTPS encryption for AI Coach API calls
        - No third-party access (except Google Gemini when using AI Coach)

        ## Your Rights

        Since all data is local on your device:
        - **Access:** You can view all your data in the app
        - **Delete:** You can delete individual items or all data by deleting the app
        - **Export:** Available via Settings > Data Management (CSV format)
        - **Modify:** You can edit or delete any data in the app

        ## Changes to This Policy

        We may update this Privacy Policy from time to time. We will notify you of any changes by:
        - Updating the "Last Updated" date
        - Posting the new policy in the app and on our GitHub repository
        - Notifying users through app updates

        ## Open Source

        Antrain is built with privacy in mind. Our code is available for review to ensure transparency about data handling.

        ## Contact Us

        If you have questions about this Privacy Policy, please contact us:
        - **GitHub:** https://github.com/burakkho/antrain
        - **Email:** burakkho@gmail.com

        ## Compliance

        This Privacy Policy complies with:
        - Apple App Store Review Guidelines
        - General Data Protection Regulation (GDPR) principles
        - California Consumer Privacy Act (CCPA) principles

        ---

        **Summary:** Antrain is privacy-focused. All your workout and nutrition data is stored locally on your device. The only exception is the AI Coach feature, which sends your fitness data to Google Gemini API to provide personalized guidance. You can choose not to use AI Coach to keep your data 100% private and local.
        """

        return (try? AttributedString(markdown: markdown, options: AttributedString.MarkdownParsingOptions(interpretedSyntax: .inlineOnlyPreservingWhitespace))) ?? AttributedString(markdown)
    }
}

#Preview {
    NavigationStack {
        PrivacyPolicyView()
    }
}
