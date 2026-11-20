//
//  WidgetGuideView.swift
//  simple-quran
//

import SwiftUI

struct WidgetGuideView: View {
    @State private var viewModel: WidgetGuideViewModel

    init(taskManager: TaskManager) {
        _viewModel = State(
            initialValue: WidgetGuideViewModel(
                taskManager: taskManager
            )
        )
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 18) {
                selector

                WidgetGuidePreviewView(
                    kind: viewModel.selectedWidget,
                    progress: viewModel.todayProgress,
                    completedCount: viewModel.completedCount,
                    totalCount: viewModel.totalCount,
                    upcomingTasks: viewModel.upcomingTasks,
                    quickSurahs: viewModel.quickSurahs
                )

                selectedWidgetInfo
                addWidgetSteps

                if viewModel.selectedWidget == .quickSurahs {
                    configureQuickSurahs
                }

                footer
            }
            .padding(.horizontal, 16)
            .padding(.top, 10)
            .padding(.bottom, 28)
        }
        .background(.appBackground)
        .navigationTitle(
            NSLocalizedString("setting_widgets_action_title", comment: "")
        )
        .navigationBarTitleDisplayMode(.inline)
    }

    private var selector: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(NSLocalizedString("widget_guide_select_title", comment: ""))
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(.textGray)
                .frame(maxWidth: .infinity, alignment: .leading)

            HStack(spacing: 8) {
                ForEach(WidgetGuideKind.allCases) { kind in
                    Button {
                        withAnimation(.easeInOut(duration: 0.22)) {
                            viewModel.select(kind)
                        }
                    } label: {
                        HStack(spacing: 6) {
                            Image(systemName: kind.icon)
                                .font(.system(size: 11, weight: .semibold))

                            Text(NSLocalizedString(kind.titleKey, comment: ""))
                                .font(.system(size: 12, weight: .semibold))
                        }
                        .foregroundColor(
                            viewModel.selectedWidget == kind ? .white : .title
                        )
                        .padding(.horizontal, 14)
                        .frame(height: 38)
                        .background(
                            viewModel.selectedWidget == kind
                                ? Color.lightGreen
                                : Color.backgroundGray
                        )
                        .clipShape(Capsule())
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    private var selectedWidgetInfo: some View {
        HStack(alignment: .top, spacing: 10) {
            Image(systemName: viewModel.selectedWidget.icon)
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.lightGreen)
                .frame(width: 36, height: 36)
                .background(Color.lightGreen.opacity(0.12))
                .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))

            VStack(alignment: .leading, spacing: 3) {
                Text(
                    NSLocalizedString(
                        viewModel.selectedWidget.titleKey,
                        comment: ""
                    )
                )
                .font(.system(size: 15, weight: .bold))
                .foregroundColor(.title)

                Text(
                    NSLocalizedString(
                        viewModel.selectedWidget.bodyKey,
                        comment: ""
                    )
                )
                .font(.system(size: 12))
                .foregroundColor(.textGray)
                .fixedSize(horizontal: false, vertical: true)
            }

            Spacer(minLength: 0)
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.backgroundGray.opacity(0.55))
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    }

    private var addWidgetSteps: some View {
        VStack(alignment: .leading, spacing: 10) {
            sectionTitle("widget_guide_add_title")

            VStack(spacing: 0) {
                stepRow(number: 1, textKey: "widget_guide_add_step_1")
                stepDivider
                stepRow(number: 2, textKey: "widget_guide_add_step_2")
                stepDivider
                stepRow(number: 3, textKey: "widget_guide_add_step_3")
                stepDivider
                stepRow(number: 4, textKey: "widget_guide_add_step_4")
            }
            .padding(.vertical, 4)
            .background(Color.backgroundGray.opacity(0.55))
            .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        }
    }

    private var configureQuickSurahs: some View {
        VStack(alignment: .leading, spacing: 10) {
            sectionTitle("widget_guide_configure_title")

            Text(
                NSLocalizedString(
                    "widget_guide_configure_body",
                    comment: ""
                )
            )
            .font(.system(size: 13))
            .foregroundColor(.textGray)
            .fixedSize(horizontal: false, vertical: true)

            VStack(alignment: .leading, spacing: 8) {
                configureStep(
                    icon: "hand.tap",
                    textKey: "widget_guide_configure_step_1"
                )
                configureStep(
                    icon: "slider.horizontal.3",
                    textKey: "widget_guide_configure_step_2"
                )
                configureStep(
                    icon: "checkmark.circle",
                    textKey: "widget_guide_configure_step_3"
                )
            }
            .padding(12)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color.backgroundGray.opacity(0.55))
            .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        }
    }

    private var footer: some View {
        Text(NSLocalizedString("widget_guide_footer", comment: ""))
            .font(.system(size: 11))
            .foregroundColor(.textGray)
            .multilineTextAlignment(.center)
            .padding(.horizontal, 12)
    }

    private func sectionTitle(_ key: String) -> some View {
        Text(NSLocalizedString(key, comment: ""))
            .font(.system(size: 16, weight: .bold))
            .foregroundColor(.title)
            .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func stepRow(number: Int, textKey: String) -> some View {
        HStack(alignment: .top, spacing: 10) {
            Text("\(number)")
                .font(.system(size: 11, weight: .bold))
                .foregroundColor(.white)
                .frame(width: 22, height: 22)
                .background(Color.lightGreen)
                .clipShape(Circle())

            Text(NSLocalizedString(textKey, comment: ""))
                .font(.system(size: 13))
                .foregroundColor(.title)
                .fixedSize(horizontal: false, vertical: true)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
    }

    private func configureStep(icon: String, textKey: String) -> some View {
        HStack(alignment: .top, spacing: 9) {
            Image(systemName: icon)
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(.lightGreen)
                .frame(width: 18)

            Text(NSLocalizedString(textKey, comment: ""))
                .font(.system(size: 13))
                .foregroundColor(.title)
                .fixedSize(horizontal: false, vertical: true)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    private var stepDivider: some View {
        Divider()
            .padding(.leading, 44)
    }
}
