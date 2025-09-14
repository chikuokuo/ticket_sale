# Flutter Ticket Sale App

A comprehensive Flutter application for browsing and purchasing tickets for various services, including museum admissions and train journeys. This app integrates with third-party services like G2Rail for real-time train data and Stripe for secure online payments.

## Features

- **Multi-Service Ticketing**: Supports ordering tickets for different categories.
  - **Museum Tickets**: A rebuilt module for Neuschwanstein Castle tickets.
  - **Train Tickets**: Search for train routes and book tickets.
- **Real-Time Data**: Integrates with the **G2Rail API** to fetch up-to-date train schedules and availability.
- **Secure Payments**: Utilizes **Stripe** to handle online payment processing securely.
- **State Management**: Uses **Riverpod** for robust and scalable state management across the application.
- **Theming**: A centralized theme system for a consistent look and feel.
- **Environment-Based Configuration**: Manages API keys and sensitive information using a `.env` file.

## User Flow

### Museum Ticket Purchase
1.  Navigate to the Museum section from the main screen.
2.  Users can see ticket prices for adults and children.
3.  Select a visit date (must be at least two days in the future) and a time slot (AM/PM).
4.  Fill in contact email and payment information.
5.  Add attendees, specifying their name and type (adult/child).
6.  The total price is automatically recalculated as attendees are managed.
7.  Proceed to the summary screen to review the order.
8.  Complete the purchase using the Stripe payment gateway.

### Train Ticket Purchase
1.  Navigate to the Train section from the main screen.
2.  Search for train routes between desired stations.
3.  The app fetches and displays available trips from the G2Rail API.
4.  Select a desired trip to view details.
5.  Enter passenger information for the booking.
6.  Review the trip details and total price on the summary screen.
7.  Complete the purchase using the Stripe payment gateway.

## Project Structure

The project is organized into a feature-driven structure that separates concerns and improves scalability.

```
sale_ticket_app/
└── lib/
    ├── main.dart             # Main entry point of the application.
    ├── models/               # Data models (Attendee, TrainTrip, etc.).
    ├── providers/            # Riverpod providers for state management.
    ├── screens/              # UI screens for different features.
    ├── services/             # Clients for external services (G2Rail, Stripe).
    ├── theme/                # Application-wide color schemes and themes.
    └── widgets/              # Reusable UI components.
```

-   `main.dart`: Initializes the app, sets up providers, and defines routes.
-   `models/`: Contains all data structures for museum and train ticketing.
-   `providers/`: Holds the business logic and state, managed by Riverpod.
-   `screens/`: Contains individual screens, organized by feature (e.g., `museum_ticket_screen.dart`, `train_ticket_screen.dart`).
-   `services/`: Handles communication with external APIs like G2Rail and Stripe.
-   `theme/`: Defines the visual style of the application.
-   `widgets/`: Contains smaller, reusable widgets used across multiple screens.

## Getting Started

To run this project locally, follow these steps:

### 1. Prerequisites
- Ensure you have the [Flutter SDK](https://flutter.dev/docs/get-started/install) installed.
- You will need API keys for G2Rail and Stripe.

### 2. Installation
1.  Clone the repository.
2.  Navigate to the project directory: `cd sale_ticket_app`
3.  Install the dependencies:
    ```sh
    flutter pub get
    ```

### 3. Configuration
1.  At the root of the project, create a file named `.env`.
2.  Add your API keys and other environment-specific variables to this file. It should look like this:
    ```
    # G2Rail API Credentials
    G2RAIL_API_KEY=your_g2rail_api_key_here

    # Stripe API Credentials
    STRIPE_PUBLISHABLE_KEY=your_stripe_publishable_key_here
    STRIPE_SECRET_KEY=your_stripe_secret_key_here
    ```

### 4. Run the Application
```sh
flutter run
```
