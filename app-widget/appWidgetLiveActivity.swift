//
//  appWidgetLiveActivity.swift
//  app-widget
//
//  Created by Mohammad Hasif Afiq on 4/30/25.
//

import ActivityKit
import WidgetKit
import SwiftUI

struct appWidgetAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        // Dynamic stateful properties about your activity go here!
        var emoji: String
    }

    // Fixed non-changing properties about your activity go here!
    var name: String
}

struct appWidgetLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: appWidgetAttributes.self) { context in
            // Lock screen/banner UI goes here
            VStack {
                Text("Hello \(context.state.emoji)")
            }
            .activityBackgroundTint(Color.cyan)
            .activitySystemActionForegroundColor(Color.black)

        } dynamicIsland: { context in
            DynamicIsland {
                // Expanded UI goes here.  Compose the expanded UI through
                // various regions, like leading/trailing/center/bottom
                DynamicIslandExpandedRegion(.leading) {
                    Text("Leading")
                }
                DynamicIslandExpandedRegion(.trailing) {
                    Text("Trailing")
                }
                DynamicIslandExpandedRegion(.bottom) {
                    Text("Bottom \(context.state.emoji)")
                    // more content
                }
            } compactLeading: {
                Text("L")
            } compactTrailing: {
                Text("T \(context.state.emoji)")
            } minimal: {
                Text(context.state.emoji)
            }
            .widgetURL(URL(string: "http://www.apple.com"))
            .keylineTint(Color.red)
        }
    }
}

extension appWidgetAttributes {
    fileprivate static var preview: appWidgetAttributes {
        appWidgetAttributes(name: "World")
    }
}

extension appWidgetAttributes.ContentState {
    fileprivate static var smiley: appWidgetAttributes.ContentState {
        appWidgetAttributes.ContentState(emoji: "😀")
     }
     
     fileprivate static var starEyes: appWidgetAttributes.ContentState {
         appWidgetAttributes.ContentState(emoji: "🤩")
     }
}

#Preview("Notification", as: .content, using: appWidgetAttributes.preview) {
   appWidgetLiveActivity()
} contentStates: {
    appWidgetAttributes.ContentState.smiley
    appWidgetAttributes.ContentState.starEyes
}
