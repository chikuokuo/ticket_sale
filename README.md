# Neuschwanstein Castle Ticket Sale App

A Flutter application for selling tickets to Neuschwanstein Castle. This app allows users to select the number of tickets, calculate the total price based on adult and child fares, fill in their details, and submit the order via an email client.

## Features

- **Dynamic Ticket Pricing**: Differentiates between adult (€23.50) and child (€2.50) ticket prices.
- **Dynamic Attendee List**: Users can add or remove attendees, and the total price updates automatically.
- **Date Restriction**: The date picker is configured to only allow booking tickets for dates starting from two days after the current date.
- **Time Slot Selection**: Users can select either a morning (AM) or afternoon (PM) time slot for their visit.
- **Customer Information Form**: Collects necessary customer details, including:
  - Customer Email (with validation)
  - Last 5 digits of the bank account for transfer verification
  - A detailed list of each attendee (Given Name, Family Name, and type).
- **Email-Based Order Submission**: Generates a pre-filled email with all order details, allowing the user to easily submit their order to a designated email address (`chikuokuo@msn.com`).

## User Flow

1.  The user opens the app and is presented with the ticket order screen.
2.  The user can see the bank transfer details and the ticket prices for adults and children.
3.  The user selects a date for the visit (must be at least two days in the future) and a time slot (AM/PM).
4.  The user fills in their email address and the last 5 digits of their bank account.
5.  By default, there is one attendee. The user can add more people by clicking the "Add Person" button.
6.  For each person, the user enters their Given Name, Family Name, and selects their type (adult or child).
7.  As attendees are added or their type is changed, the total price is automatically recalculated and displayed.
8.  Once all information is filled in, the user clicks the "Submit" button.
9.  The app opens the default email client on the user's device.
10. The email is pre-filled with the recipient (`chikuokuo@msn.com`), a subject, and a body containing all the order details.
11. The user only needs to press "Send" in their email client.
12. After the email client is launched, the form in the app is automatically cleared for a new order.

## Project Structure

The project follows a simple feature-driven structure to separate concerns.

```
sale_ticket_app/
└── lib/
    ├── main.dart         # Main entry point of the application.
    ├── models/
    │   ├── attendee.dart   # Defines the Attendee data model and AttendeeType enum.
    │   └── time_slot.dart  # Defines the TimeSlot enum.
    └── screens/
        └── ticket_order_screen.dart # Contains the main UI and business logic for the ticket order form.
```

-   `main.dart`: Initializes and runs the Flutter application. It sets up the `MaterialApp` and points to the main screen.
-   `models/`: This directory contains all the data structures (data models) used in the application.
-   `screens/`: This directory contains all the UI widget screens. `ticket_order_screen.dart` is the primary screen of the app.

## Getting Started

To run this project locally, follow these steps:

1.  Ensure you have the [Flutter SDK](https://flutter.dev/docs/get-started/install) installed on your machine.
2.  Clone the repository.
3.  Navigate to the project directory: `cd sale_ticket_app`
4.  Install the dependencies:
    ```sh
    flutter pub get
    ```
5.  Run the application:
    ```sh
    flutter run
    ```
