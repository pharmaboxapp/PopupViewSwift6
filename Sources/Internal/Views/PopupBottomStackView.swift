//
//  PopupBottomStackView.swift of PopupView
//
//  Created by Tomasz Kurylik
//    - Twitter: https://twitter.com/tkurylik
//    - Mail: tomasz.kurylik@mijick.com
//
//  Copyright ©2023 Mijick. Licensed under MIT License.


import SwiftUI

@MainActor 
struct PopupBottomStackView: PopupStack {
    let items: [AnyPopup<BottomPopupConfig>]
    let globalConfig: GlobalConfig
    @State var gestureTranslation: CGFloat = 0
    @State var heights: [String: CGFloat] = [:]
    @GestureState var isGestureActive: Bool = false
    @ObservedObject private var screenManager: ScreenManager = .shared
    @ObservedObject private var keyboardManager: KeyboardManager = .shared

    
    var body: some View {
        ZStack(alignment: .top, content: createPopupStack)
            .background(createTapArea())
            .animation(getHeightAnimation(isAnimationDisabled: screenManager.animationsDisabled), value: heights)
            .animation(isGestureActive ? dragGestureAnimation : transitionRemovalAnimation, value: gestureTranslation)
            .animation(.keyboard, value: isKeyboardVisible)
            .onDragGesture($isGestureActive, onChanged: onPopupDragGestureChanged, onEnded: onPopupDragGestureEnded)
    }
}

private extension PopupBottomStackView {
    func createPopupStack() -> some View {
        ForEach(items, id: \.self, content: createPopup)
    }
}

private extension PopupBottomStackView {
    func createPopup(_ item: AnyPopup<BottomPopupConfig>) -> some View {
        item.body
            .padding(.top, getContentTopPadding())
            .padding(.bottom, getContentBottomPadding())
            .padding(.leading, screenManager.safeArea.left)
            .padding(.trailing, screenManager.safeArea.right)
            .fixedSize(horizontal: false, vertical: getFixedSize(item))
            .readHeight { saveHeight($0, for: item) }
            .frame(height: getHeight(item), alignment: .top).frame(maxWidth: .infinity, maxHeight: height)
            .background(getBackgroundColour(for: item), overlayColour: getStackOverlayColour(item), shadow: popupShadow)
            .padding(.horizontal, popupHorizontalPadding)
            .offset(y: getOffset(item))
            .scaleEffect(x: getScale(item))
            .opacity(getOpacity(item))
            .compositingGroup()
            .focusSectionIfAvailable()
            .align(to: .bottom, lastPopupConfig.contentFillsEntireScreen ? 0 : popupBottomPadding)
            .transition(transition)
            .zIndex(getZIndex(item))
    }
}

// MARK: - Gesture
private extension PopupBottomStackView {
    func onPopupDragGestureChanged(_ value: CGFloat) {
        if lastPopupConfig.dragGestureEnabled ?? globalConfig.bottom.dragGestureEnabled { gestureTranslation = max(0, value) }
    }
    func onPopupDragGestureEnded(_ value: CGFloat) {
        dismissLastItemIfNeeded()
        resetGestureTranslationOnEnd()
    }
}
private extension PopupBottomStackView {
    func dismissLastItemIfNeeded() {
        if translationProgress >= gestureClosingThresholdFactor { items.last?.remove() }
    }
    func resetGestureTranslationOnEnd() {
        let resetAfter = items.count == 1 && translationProgress >= gestureClosingThresholdFactor ? 0.25 : 0
        DispatchQueue.main.asyncAfter(deadline: .now() + resetAfter) { gestureTranslation = 0 }
    }
}

// MARK: - View Modifiers
private extension PopupBottomStackView {
    func saveHeight(_ height: CGFloat, for item: AnyPopup<BottomPopupConfig>) { if !isGestureActive {
        let config = item.configurePopup(popup: .init())

        if config.contentFillsEntireScreen { return heights[item.id] = screenManager.size.height + screenManager.safeArea.top }
        if config.contentFillsWholeHeight { return heights[item.id] = getMaxHeight() }
        return heights[item.id] = min(height, maxHeight)
    }}
    func getMaxHeight() -> CGFloat {
        let basicHeight = screenManager.size.height - screenManager.safeArea.top
        let stackedViewsCount = min(max(0, globalConfig.bottom.stackLimit - 1), items.count - 1)
        let stackedViewsHeight = globalConfig.bottom.stackOffset * .init(stackedViewsCount) * maxHeightStackedFactor
        return basicHeight - stackedViewsHeight
    }
    func getContentBottomPadding() -> CGFloat {
        if isKeyboardVisible { return keyboardManager.height + distanceFromKeyboard }
        if lastPopupConfig.contentIgnoresSafeArea { return 0 }

        return max(screenManager.safeArea.bottom - popupBottomPadding, 0)
    }
    func getContentTopPadding() -> CGFloat { lastPopupConfig.contentFillsEntireScreen && !lastPopupConfig.contentIgnoresSafeArea ? screenManager.safeArea.top : 0 }
    func getHeight(_ item: AnyPopup<BottomPopupConfig>) -> CGFloat? { getConfig(item).contentFillsEntireScreen ? nil : height }
    func getFixedSize(_ item: AnyPopup<BottomPopupConfig>) -> Bool { !(getConfig(item).contentFillsEntireScreen || getConfig(item).contentFillsWholeHeight || height == maxHeight) }
    func getBackgroundColour(for item: AnyPopup<BottomPopupConfig>) -> Color { item.configurePopup(popup: .init()).backgroundColour ?? globalConfig.bottom.backgroundColour }
}

// MARK: - Flags & Values
extension PopupBottomStackView {
    var popupBottomPadding: CGFloat { lastPopupConfig.popupPadding.bottom }
    @MainActor var popupHorizontalPadding: CGFloat { lastPopupConfig.popupPadding.horizontal }
    var popupShadow: Shadow { globalConfig.bottom.shadow }
    @MainActor var height: CGFloat { heights.first { $0.key == items.last?.id }?.value ?? (lastPopupConfig.contentFillsEntireScreen ? screenManager.size.height : getInitialHeight()) }
    var maxHeight: CGFloat { getMaxHeight() - popupBottomPadding }
    @MainActor var distanceFromKeyboard: CGFloat { lastPopupConfig.distanceFromKeyboard ?? globalConfig.bottom.distanceFromKeyboard }
    var cornerRadius: CGFloat { let cornerRadius = lastPopupConfig.cornerRadius ?? globalConfig.bottom.cornerRadius; return lastPopupConfig.contentFillsEntireScreen ? min(cornerRadius, screenManager.cornerRadius ?? 0) : cornerRadius }
    @MainActor var maxHeightStackedFactor: CGFloat { 0.85 }
    var isKeyboardVisible: Bool { keyboardManager.height > 0 }

    @MainActor var stackLimit: Int { globalConfig.bottom.stackLimit }
    var stackScaleFactor: CGFloat { globalConfig.bottom.stackScaleFactor }
    @MainActor var stackOffsetValue: CGFloat { -globalConfig.bottom.stackOffset }
    var stackCornerRadiusMultiplier: CGFloat { globalConfig.bottom.stackCornerRadiusMultiplier }

    @MainActor var translationProgress: CGFloat { abs(gestureTranslation) / height }
    var gestureClosingThresholdFactor: CGFloat { globalConfig.bottom.dragGestureProgressToClose }
    @MainActor var transition: AnyTransition { .move(edge: .bottom) }

    var tapOutsideClosesPopup: Bool { lastPopupConfig.tapOutsideClosesView ?? globalConfig.bottom.tapOutsideClosesView }
}
