# Applicare-UI

## Chat Features

### User Chat

The regular `ChatView` and `SimpleChatView` components are intended for customer use, showing customer messages on the right and repairer messages on the left.

### Repairer Chat

For repairers, there's now a dedicated `RepairerChatView` that correctly aligns messages:

- Messages from the repairer (current user) appear on the right
- Messages from the customer appear on the left

#### Using Repairer Chat

To add chat functionality to a repairer view:

```swift
// Use the button component (includes both icon and text)
RepairerChatButton(
    booking: booking,
    customerName: booking.user?.name ?? "Customer"
)

// Or use just the icon button
RepairerChatIconButton(
    booking: booking,
    customerName: booking.user?.name ?? "Customer"
)

// Or create your own button that opens the view
Button("Chat") {
    // Show chat view
}
.sheet(isPresented: $showChat) {
    RepairerChatView(
        booking: booking,
        customerName: booking.user?.name ?? "Customer"
    )
}
```

This ensures the chat messages are displayed correctly with repairer messages on the right and customer messages on the left.
