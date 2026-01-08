# Campus Connect 🎓

**Campus Connect** is a centralized, verified student marketplace and utility platform designed exclusively for **MVGR College of Engineering**. It bridges the gap between students for buying/selling items, recovering lost belongings, and exchanging books, all secured by college email verification.

## 🚀 Key Features

### 1. Student Marketplace 🛒
* **Buy & Sell:** A classifieds section for students to list used items like electronics, lab coats, and drafters.
* **Category Filtering:** Easily browse by categories (Books, Electronics, Tools, etc.).
* **WhatsApp Integration:** Direct "Chat with Seller" button to initiate negotiations instantly.

### 2. Lost & Found Hub 🔍
* **Urgent Reporting:** A dedicated "Sticky Note" interface for reporting lost items.
* **Location Tracking:** Includes "Last Seen" fields to help recover items faster.
* **One-Tap Claim:** Finders can instantly notify the owner via WhatsApp.

### 3. Book Exchange (Barter System) 📚
* **Cashless Trading:** A "Library Card" style interface designed for swapping books rather than selling them.
* **Trade Requests:** Users specify what they want in return (e.g., "Trading 'Data Structures' for 'Python Crash Course'").

### 4. AI-Powered Writing Assistant ✨
* **Gemini Integration:** Powered by the **Google Gemini 2.5 Flash Lite API**.
* **Smart Descriptions:** Users can simply enter a title (e.g., "Scientific Calculator"), and the AI auto-generates a persuasive, professional sales pitch or lost item description.

### 5. Smart Email Notifications 🔔
* **Subscriber Model:** Users can subscribe with their personal email (Gmail, etc.) to receive alerts.
* **Real-Time Alerts:** When a new item is posted in *any* category (Market, Lost, or Exchange), subscribers receive an instant email notification via **EmailJS**.

### 6. Security & Verification 🔐
* **Strict College Authentication:** Sign-ups and posts are restricted to verified `@mvgrce.edu.in` email addresses only.
* **PIN Protection:** Every post is secured with a user-defined 4-digit PIN to prevent unauthorized deletions.

---

## 🛠️ Tech Stack

* **Frontend:** Flutter (Dart)
* **Backend:** Firebase Firestore (NoSQL Database)
* **Authentication:** Firebase Auth (Email Link Verification)
* **AI Engine:** Google Gemini API (REST HTTP)
* **Notifications:** EmailJS (REST API)

---

## 📂 Project Structure

* `lib/main.dart`: App entry point and Firebase initialization.
* `lib/home_page.dart`: Main dashboard with the **3-Way Toggle** (Market/Lost/Exchange) and Subscription feature.
* `lib/post_page.dart`: Marketplace listing form with AI and strict email validation.
* `lib/exchange_post_page.dart`: Specialized form for the Book Exchange feature.
* `lib/report_lost_page.dart`: Form for reporting lost items.
* `lib/notification_service.dart`: Handles EmailJS integration and subscriber management.
* `lib/api_key.dart`: Stores the Gemini API Key.

---

## ⚙️ Installation & Setup

1.  **Clone the Repository**
    ```bash
    git clone [https://github.com/your-username/campus-connect.git](https://github.com/your-username/campus-connect.git)
    cd campus-connect
    ```

2.  **Install Dependencies**
    ```bash
    flutter pub get
    ```

3.  **Firebase Configuration**
    * Create a project in the Firebase Console.
    * Add `google-services.json` (Android) or `GoogleService-Info.plist` (iOS).
    * Enable **Firestore Database** and **Authentication** (Email/Password).

4.  **API Keys Setup**
    * **Gemini API:** Get your key from Google AI Studio.
    * **EmailJS:** Create an account at emailjs.com, create a Service and Template, and get your User ID.
    * Update `lib/api_key.dart` and `lib/notification_service.dart` with your respective keys.

5.  **Run the App**
    ```bash
    flutter run
    ```

---

## 🤝 Team

**Team Name:** Visionary Variables
**Lead:** Rahul Attili
**Project:** Built for the GDG On Campus TechSprint.

---

*“Pass the knowledge, not the cost.”*
