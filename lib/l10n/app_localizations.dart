import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_de.dart';
import 'app_localizations_en.dart';
import 'app_localizations_fr.dart';
import 'app_localizations_ja.dart';
import 'app_localizations_ko.dart';
import 'app_localizations_vi.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('de'),
    Locale('en'),
    Locale('fr'),
    Locale('ja'),
    Locale('ko'),
    Locale('vi'),
  ];

  /// The title of the application
  ///
  /// In en, this message translates to:
  /// **'Future Dream'**
  String get appTitle;

  /// Welcome message
  ///
  /// In en, this message translates to:
  /// **'Welcome'**
  String get welcome;

  /// Tickets tab label
  ///
  /// In en, this message translates to:
  /// **'Tickets'**
  String get tickets;

  /// Trains tab label
  ///
  /// In en, this message translates to:
  /// **'Trains'**
  String get trains;

  /// Bundles tab label
  ///
  /// In en, this message translates to:
  /// **'Bundles'**
  String get bundles;

  /// Treasure Hunt tab label
  ///
  /// In en, this message translates to:
  /// **'Treasure Hunt'**
  String get treasureHunt;

  /// Search button text
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get search;

  /// Departure station label
  ///
  /// In en, this message translates to:
  /// **'From'**
  String get from;

  /// Destination station label
  ///
  /// In en, this message translates to:
  /// **'To'**
  String get to;

  /// Date selection label
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get date;

  /// Time selection label
  ///
  /// In en, this message translates to:
  /// **'Time'**
  String get time;

  /// Number of passengers label
  ///
  /// In en, this message translates to:
  /// **'Passengers'**
  String get passengers;

  /// Adult passengers label
  ///
  /// In en, this message translates to:
  /// **'Adults'**
  String get adults;

  /// Child passengers label
  ///
  /// In en, this message translates to:
  /// **'Children'**
  String get children;

  /// Select ticket button text
  ///
  /// In en, this message translates to:
  /// **'Select Ticket'**
  String get selectTicket;

  /// Book now button text
  ///
  /// In en, this message translates to:
  /// **'Book Now'**
  String get bookNow;

  /// Price label
  ///
  /// In en, this message translates to:
  /// **'Price'**
  String get price;

  /// Total price label
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get total;

  /// Payment method label
  ///
  /// In en, this message translates to:
  /// **'Payment Method'**
  String get paymentMethod;

  /// Credit card payment option
  ///
  /// In en, this message translates to:
  /// **'Credit Card'**
  String get creditCard;

  /// PayPal payment option
  ///
  /// In en, this message translates to:
  /// **'PayPal'**
  String get paypal;

  /// Apple Pay payment option
  ///
  /// In en, this message translates to:
  /// **'Apple Pay'**
  String get applePay;

  /// Google Pay payment option
  ///
  /// In en, this message translates to:
  /// **'Google Pay'**
  String get googlePay;

  /// Confirm button text
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirm;

  /// Cancel button text
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// Back button text
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get back;

  /// Next button text
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get next;

  /// Done button text
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get done;

  /// Loading message
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get loading;

  /// Error message
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get error;

  /// Retry button text
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No data message
  ///
  /// In en, this message translates to:
  /// **'No data available'**
  String get noDataAvailable;

  /// Language selection title
  ///
  /// In en, this message translates to:
  /// **'Select Language'**
  String get selectLanguage;

  /// Language label
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// Settings label
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// Profile label
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// Logout button text
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logout;

  /// Login button text
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get login;

  /// Register button text
  ///
  /// In en, this message translates to:
  /// **'Register'**
  String get register;

  /// Email field label
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// Password field label
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// First name field label
  ///
  /// In en, this message translates to:
  /// **'First Name'**
  String get firstName;

  /// Last name field label
  ///
  /// In en, this message translates to:
  /// **'Last Name'**
  String get lastName;

  /// Phone number field label
  ///
  /// In en, this message translates to:
  /// **'Phone Number'**
  String get phoneNumber;

  /// Address field label
  ///
  /// In en, this message translates to:
  /// **'Address'**
  String get address;

  /// City field label
  ///
  /// In en, this message translates to:
  /// **'City'**
  String get city;

  /// Country field label
  ///
  /// In en, this message translates to:
  /// **'Country'**
  String get country;

  /// Zip code field label
  ///
  /// In en, this message translates to:
  /// **'Zip Code'**
  String get zipCode;

  /// Order summary title
  ///
  /// In en, this message translates to:
  /// **'Order Summary'**
  String get orderSummary;

  /// Order details title
  ///
  /// In en, this message translates to:
  /// **'Order Details'**
  String get orderDetails;

  /// Ticket details title
  ///
  /// In en, this message translates to:
  /// **'Ticket Details'**
  String get ticketDetails;

  /// Passenger information title
  ///
  /// In en, this message translates to:
  /// **'Passenger Information'**
  String get passengerInfo;

  /// Departure time label
  ///
  /// In en, this message translates to:
  /// **'Departure Time'**
  String get departureTime;

  /// Arrival time label
  ///
  /// In en, this message translates to:
  /// **'Arrival Time'**
  String get arrivalTime;

  /// Journey duration label
  ///
  /// In en, this message translates to:
  /// **'Duration'**
  String get duration;

  /// Train platform label
  ///
  /// In en, this message translates to:
  /// **'Platform'**
  String get platform;

  /// Seat number label
  ///
  /// In en, this message translates to:
  /// **'Seat Number'**
  String get seatNumber;

  /// Train car number label
  ///
  /// In en, this message translates to:
  /// **'Car Number'**
  String get carNumber;

  /// Ticket type label
  ///
  /// In en, this message translates to:
  /// **'Ticket Type'**
  String get ticketType;

  /// First class ticket type
  ///
  /// In en, this message translates to:
  /// **'First Class'**
  String get firstClass;

  /// Second class ticket type
  ///
  /// In en, this message translates to:
  /// **'Second Class'**
  String get secondClass;

  /// Economy ticket type
  ///
  /// In en, this message translates to:
  /// **'Economy'**
  String get economy;

  /// Business ticket type
  ///
  /// In en, this message translates to:
  /// **'Business'**
  String get business;

  /// Premium ticket type
  ///
  /// In en, this message translates to:
  /// **'Premium'**
  String get premium;

  /// Explore new treasure map button text
  ///
  /// In en, this message translates to:
  /// **'🗺️ Explore New Treasure Map'**
  String get exploreNewTreasureMap;

  /// Treasure found success message
  ///
  /// In en, this message translates to:
  /// **'Treasure Found!'**
  String get treasureFound;

  /// Congratulations message
  ///
  /// In en, this message translates to:
  /// **'Congratulations!'**
  String get congratulations;

  /// Collect reward button text
  ///
  /// In en, this message translates to:
  /// **'Collect Reward'**
  String get collectReward;

  /// Rail pass label
  ///
  /// In en, this message translates to:
  /// **'Rail Pass'**
  String get railPass;

  /// Pass validity label
  ///
  /// In en, this message translates to:
  /// **'Validity'**
  String get validity;

  /// Days unit
  ///
  /// In en, this message translates to:
  /// **'Days'**
  String get days;

  /// Unlimited travel description
  ///
  /// In en, this message translates to:
  /// **'Unlimited'**
  String get unlimited;

  /// Flexible travel description
  ///
  /// In en, this message translates to:
  /// **'Flexible Travel'**
  String get flexibleTravel;

  /// Purchase rail pass button text
  ///
  /// In en, this message translates to:
  /// **'Purchase Rail Pass'**
  String get purchaseRailPass;

  /// Select bundle button text
  ///
  /// In en, this message translates to:
  /// **'Select Bundle'**
  String get selectBundle;

  /// Bundle includes label
  ///
  /// In en, this message translates to:
  /// **'Bundle Includes'**
  String get bundleIncludes;

  /// Bundle participants label
  ///
  /// In en, this message translates to:
  /// **'Participants'**
  String get participants;

  /// Add participant button text
  ///
  /// In en, this message translates to:
  /// **'Add Participant'**
  String get addParticipant;

  /// Remove participant button text
  ///
  /// In en, this message translates to:
  /// **'Remove Participant'**
  String get removeParticipant;

  /// Museum label
  ///
  /// In en, this message translates to:
  /// **'Museum'**
  String get museum;

  /// Gallery label
  ///
  /// In en, this message translates to:
  /// **'Gallery'**
  String get gallery;

  /// Castle label
  ///
  /// In en, this message translates to:
  /// **'Castle'**
  String get castle;

  /// Attraction label
  ///
  /// In en, this message translates to:
  /// **'Attraction'**
  String get attraction;

  /// Opening hours label
  ///
  /// In en, this message translates to:
  /// **'Opening Hours'**
  String get openingHours;

  /// Closing time label
  ///
  /// In en, this message translates to:
  /// **'Closing Time'**
  String get closingTime;

  /// Booking reference label
  ///
  /// In en, this message translates to:
  /// **'Booking Reference'**
  String get bookingReference;

  /// QR code label
  ///
  /// In en, this message translates to:
  /// **'QR Code'**
  String get qrCode;

  /// Show QR code button text
  ///
  /// In en, this message translates to:
  /// **'Show QR Code'**
  String get showQRCode;

  /// Download ticket button text
  ///
  /// In en, this message translates to:
  /// **'Download Ticket'**
  String get downloadTicket;

  /// Share ticket button text
  ///
  /// In en, this message translates to:
  /// **'Share Ticket'**
  String get shareTicket;

  /// My tickets title
  ///
  /// In en, this message translates to:
  /// **'My Tickets'**
  String get myTickets;

  /// Upcoming trips title
  ///
  /// In en, this message translates to:
  /// **'Upcoming Trips'**
  String get upcomingTrips;

  /// Past trips title
  ///
  /// In en, this message translates to:
  /// **'Past Trips'**
  String get pastTrips;

  /// Trip details title
  ///
  /// In en, this message translates to:
  /// **'Trip Details'**
  String get tripDetails;

  /// Contact support button text
  ///
  /// In en, this message translates to:
  /// **'Contact Support'**
  String get contactSupport;

  /// Help center title
  ///
  /// In en, this message translates to:
  /// **'Help Center'**
  String get helpCenter;

  /// FAQ title
  ///
  /// In en, this message translates to:
  /// **'FAQ'**
  String get faq;

  /// Terms and conditions title
  ///
  /// In en, this message translates to:
  /// **'Terms and Conditions'**
  String get termsAndConditions;

  /// Privacy policy title
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get privacyPolicy;

  /// About us title
  ///
  /// In en, this message translates to:
  /// **'About Us'**
  String get aboutUs;

  /// App version label
  ///
  /// In en, this message translates to:
  /// **'Version'**
  String get version;

  /// App build number label
  ///
  /// In en, this message translates to:
  /// **'Build Number'**
  String get buildNumber;

  /// Changed status message
  ///
  /// In en, this message translates to:
  /// **'changed'**
  String get changed;

  /// Title for treasure hunt screen
  ///
  /// In en, this message translates to:
  /// **'🏴‍☠️ European Treasure Hunt Adventure'**
  String get europeanTreasureHunt;

  /// Description for treasure hunt adventure
  ///
  /// In en, this message translates to:
  /// **'🗺️ Explore ancient European treasure maps and discover mysterious treasures hidden in cities like London, Paris, and Rome!'**
  String get treasureHuntDescription;

  /// Welcome header message
  ///
  /// In en, this message translates to:
  /// **'Welcome to your dream journey'**
  String get welcomeToYourDreamJourney;

  /// Welcome description message
  ///
  /// In en, this message translates to:
  /// **'Discover amazing destinations and create unforgettable memories'**
  String get discoverAmazingDestinations;

  /// Popular destinations section title
  ///
  /// In en, this message translates to:
  /// **'Popular Destinations'**
  String get popularDestinations;

  /// View all button text
  ///
  /// In en, this message translates to:
  /// **'View All'**
  String get viewAll;

  /// Neuschwanstein Castle name
  ///
  /// In en, this message translates to:
  /// **'Neuschwanstein Castle'**
  String get neuschwansteinCastle;

  /// Royal Castle Tour description
  ///
  /// In en, this message translates to:
  /// **'Royal Castle Tour'**
  String get royalCastleTour;

  /// Uffizi Galleries name
  ///
  /// In en, this message translates to:
  /// **'Uffizi Galleries'**
  String get uffiziGalleries;

  /// Art museum description
  ///
  /// In en, this message translates to:
  /// **'World-Class Art Museum'**
  String get worldClassArtMuseum;

  /// Price with from prefix
  ///
  /// In en, this message translates to:
  /// **'from {price}'**
  String fromPrice(String price);

  /// Book tickets title
  ///
  /// In en, this message translates to:
  /// **'Book Tickets'**
  String get bookTickets;

  /// Select date label
  ///
  /// In en, this message translates to:
  /// **'Select Date'**
  String get selectDate;

  /// Select time slot label
  ///
  /// In en, this message translates to:
  /// **'Select Time Slot'**
  String get selectTimeSlot;

  /// Select tickets label
  ///
  /// In en, this message translates to:
  /// **'Select Tickets'**
  String get selectTickets;

  /// Date selection validation message
  ///
  /// In en, this message translates to:
  /// **'Please select a date.'**
  String get pleaseSelectDate;

  /// Time slot selection validation message
  ///
  /// In en, this message translates to:
  /// **'Please select a time slot (AM/PM)'**
  String get pleaseSelectTimeSlot;

  /// Email validation message
  ///
  /// In en, this message translates to:
  /// **'Please fill in Contact Email'**
  String get pleaseFillContactEmail;

  /// Ticket holder details title
  ///
  /// In en, this message translates to:
  /// **'Ticket Holder Details'**
  String get ticketHolderDetails;

  /// Purchase rail pass screen title
  ///
  /// In en, this message translates to:
  /// **'Purchase Rail Pass'**
  String get purchaseRailPassTitle;

  /// Treasure hunt dig count
  ///
  /// In en, this message translates to:
  /// **'Dig Count'**
  String get digCount;

  /// Treasures found count
  ///
  /// In en, this message translates to:
  /// **'Treasures Found'**
  String get treasuresFound;

  /// Discovered count
  ///
  /// In en, this message translates to:
  /// **'Discovered'**
  String get discovered;

  /// Instruction for selecting visit details
  ///
  /// In en, this message translates to:
  /// **'Select your visit date, time, and number of tickets.'**
  String get selectVisitDetails;

  /// Book museum tickets title
  ///
  /// In en, this message translates to:
  /// **'Book Museum Tickets'**
  String get bookMuseumTickets;

  /// Date selection validation for museum
  ///
  /// In en, this message translates to:
  /// **'Please select a date before continuing.'**
  String get pleaseSelectDateBeforeContinuing;

  /// Important information section title
  ///
  /// In en, this message translates to:
  /// **'Important Information'**
  String get importantInformation;

  /// Ticket validity and museum visit information
  ///
  /// In en, this message translates to:
  /// **'• Tickets are valid for the selected date only\n• Please arrive 15 minutes before your visit\n• Children under 18 enter free with valid ID\n• Audio guides available for rent at entrance'**
  String get ticketValidityInfo;

  /// Placeholder text for date selection
  ///
  /// In en, this message translates to:
  /// **'Select a date'**
  String get selectADate;

  /// Adult age range
  ///
  /// In en, this message translates to:
  /// **'Ages 18+'**
  String get agesEighteenPlus;

  /// Child age range
  ///
  /// In en, this message translates to:
  /// **'Ages 0-17'**
  String get agesZeroToSeventeen;

  /// Free price label
  ///
  /// In en, this message translates to:
  /// **'Free'**
  String get free;

  /// Continue button text
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueButton;

  /// No description provided for @neuschwansteinCastleTicket.
  ///
  /// In en, this message translates to:
  /// **'Neuschwanstein Castle Ticket'**
  String get neuschwansteinCastleTicket;

  /// No description provided for @bankTransferInformation.
  ///
  /// In en, this message translates to:
  /// **'Bank Transfer Information:'**
  String get bankTransferInformation;

  /// No description provided for @account.
  ///
  /// In en, this message translates to:
  /// **'Account: 1234-5678-9999'**
  String get account;

  /// No description provided for @ticketPrice.
  ///
  /// In en, this message translates to:
  /// **'Ticket Price: €{adultPrice} (Adult), {childPrice} (Child)'**
  String ticketPrice(String adultPrice, String childPrice);

  /// No description provided for @totalAmount.
  ///
  /// In en, this message translates to:
  /// **'Total: €{amount}'**
  String totalAmount(String amount);

  /// No description provided for @peopleCount.
  ///
  /// In en, this message translates to:
  /// **'({count} people)'**
  String peopleCount(int count);

  /// No description provided for @yourInformation.
  ///
  /// In en, this message translates to:
  /// **'Your Information:'**
  String get yourInformation;

  /// No description provided for @noDateChosen.
  ///
  /// In en, this message translates to:
  /// **'No date chosen'**
  String get noDateChosen;

  /// No description provided for @dateSelected.
  ///
  /// In en, this message translates to:
  /// **'Date: {date}'**
  String dateSelected(String date);

  /// No description provided for @timeSlot.
  ///
  /// In en, this message translates to:
  /// **'Time Slot: '**
  String get timeSlot;

  /// No description provided for @am.
  ///
  /// In en, this message translates to:
  /// **'AM'**
  String get am;

  /// No description provided for @pm.
  ///
  /// In en, this message translates to:
  /// **'PM'**
  String get pm;

  /// No description provided for @customerEmail.
  ///
  /// In en, this message translates to:
  /// **'Customer Email'**
  String get customerEmail;

  /// No description provided for @pleaseEnterEmail.
  ///
  /// In en, this message translates to:
  /// **'Please enter an email address'**
  String get pleaseEnterEmail;

  /// No description provided for @pleaseEnterValidEmail.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid email address'**
  String get pleaseEnterValidEmail;

  /// No description provided for @attendees.
  ///
  /// In en, this message translates to:
  /// **'Attendees:'**
  String get attendees;

  /// No description provided for @addPerson.
  ///
  /// In en, this message translates to:
  /// **'Add Person'**
  String get addPerson;

  /// No description provided for @processingPayment.
  ///
  /// In en, this message translates to:
  /// **'Processing Payment...'**
  String get processingPayment;

  /// No description provided for @payAmount.
  ///
  /// In en, this message translates to:
  /// **'Pay €{amount}'**
  String payAmount(String amount);

  /// No description provided for @pleaseSelectDateFirst.
  ///
  /// In en, this message translates to:
  /// **'Please select a date'**
  String get pleaseSelectDateFirst;

  /// No description provided for @paymentSuccessful.
  ///
  /// In en, this message translates to:
  /// **'🎉 Payment successful! Please check your email for tickets.'**
  String get paymentSuccessful;

  /// No description provided for @paymentFailed.
  ///
  /// In en, this message translates to:
  /// **'Payment failed. Please try again.'**
  String get paymentFailed;

  /// Preferences section title
  ///
  /// In en, this message translates to:
  /// **'Preferences'**
  String get preferences;

  /// About section title
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get about;

  /// About app title
  ///
  /// In en, this message translates to:
  /// **'About App'**
  String get aboutApp;

  /// Rate app title
  ///
  /// In en, this message translates to:
  /// **'Rate App'**
  String get rateApp;

  /// Thank you for rating message
  ///
  /// In en, this message translates to:
  /// **'Thank you for rating our app!'**
  String get thankYouForRating;

  /// App description text
  ///
  /// In en, this message translates to:
  /// **'Your ultimate travel companion for booking tickets and discovering amazing destinations across Europe.'**
  String get appDescription;

  /// OK button text
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get ok;

  /// Digging progress overlay title
  ///
  /// In en, this message translates to:
  /// **'Digging...'**
  String get digging;

  /// Accelerate digging button text
  ///
  /// In en, this message translates to:
  /// **'Accelerate'**
  String get accelerate;

  /// Dig cancelled message
  ///
  /// In en, this message translates to:
  /// **'Dig Cancelled'**
  String get digCancelled;

  /// Treasure found dialog title
  ///
  /// In en, this message translates to:
  /// **'Treasure Found at {treasureName}!'**
  String treasureFoundAt(String treasureName);

  /// Treasure email notification message
  ///
  /// In en, this message translates to:
  /// **'We have sent \'{treasureName}\' to your email {userEmail}. Please check within 24 hours.'**
  String treasureEmailSent(String treasureName, String userEmail);

  /// Got it button text
  ///
  /// In en, this message translates to:
  /// **'Got It'**
  String get gotIt;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>[
    'de',
    'en',
    'fr',
    'ja',
    'ko',
    'vi',
  ].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'de':
      return AppLocalizationsDe();
    case 'en':
      return AppLocalizationsEn();
    case 'fr':
      return AppLocalizationsFr();
    case 'ja':
      return AppLocalizationsJa();
    case 'ko':
      return AppLocalizationsKo();
    case 'vi':
      return AppLocalizationsVi();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
