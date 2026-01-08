# Campus Connect 🎓

**Campus Connect** is a dedicated student marketplace and utility app designed for **MVGR College of Engineering**. It serves as a unified platform for students to buy/sell items, report lost belongings, and exchange books within the campus community.

## 🚀 Features

### 1. Student Marketplace 🛒
* **Buy & Sell:** Students can list items like books, electronics, lab coats, and tools.
* **Category Filtering:** Filter items by category (Books, Electronics, Lab Coat, etc.).
* **Direct WhatsApp Integration:** Buyers can chat with sellers directly via WhatsApp with a single click.
* **Secure Deletion:** Sellers create a unique 4-digit PIN to delete their posts after a sale.

### 2. Lost & Found Report 🔍
* **Dedicated Section:** A distinct UI designed to look like "Urgent Sticky Notes" to grab attention.
* **Location Tracking:** Reports include a "Last Seen" location field.
* **One-Tap Claim:** Finders can click "I Found This Item" to instantly notify the owner via WhatsApp.

### 3. Book Exchange Hub 📚
* **Library Card Aesthetics:** A beautiful, custom-designed UI for book trading.
* **Trade Requests:** Instead of prices, users specify what they want in return (e.g., "Trading 'Data Structures' for 'Python Crash Course'").
* **Optimized for Students:** Encourages a cashless, knowledge-sharing economy.

### 4. AI-Powered Assistant ✨
* **Auto-Descriptions:** Integrated with the **Gemini 2.5 Flash Lite API**.
* **Smart Writing:** Users can type a title (e.g., "Scientific Calculator") and click **"AI Write"** to generate a catchy, persuasive sales pitch or exchange description automatically.

### 5. Verification & Security 🔐
* **College Email Verification:** Ensures only verified students (using `@mvgrce.edu.in` or permitted domains) can post.
* **PIN Protection:** Every post is secured with a user-defined PIN to prevent unauthorized deletions.

---

## 🛠️ Tech Stack

* **Frontend:** Flutter (Dart)
* **Backend:** Firebase Firestore (NoSQL Database)
* **Authentication:** Firebase Auth (Email Link Verification)
* **AI Integration:** Google Gemini API (REST HTTP implementation)
* **State Management:** `setState` (Clean & efficient for this scale)

---

## 📂 Project Structure

* `lib/main.dart`: Entry point and Firebase initialization.
* `lib/home_page.dart`: The core dashboard containing the **Three-Mode Toggle** (Market, Lost, Exchange) and the dynamic GridView.
* `lib/post_page.dart`: Form for selling items with AI description generation.
* `lib/exchange_post_page.dart`: Specialized form for the Book Exchange feature.
* `lib/report_lost_page.dart`: Form for reporting lost items.
* `lib/api_key.dart`: Secure storage for the Gemini API key.

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

3.  **Firebase Setup**
    * Create a project in the Firebase Console.
    * Add your `google-services.json` (Android) or `GoogleService-Info.plist` (iOS) to the respective folders.
    * Enable **Authentication** (Email/Password) and **Firestore Database**.

4.  **API Key Configuration**
    * Get your API key from Google AI Studio.
    * Create a file `lib/api_key.dart`:
        ```dart
        const String geminiApiKey = "YOUR_API_KEY_HERE";
        ```

5.  **Run the App**
    ```bash
    flutter run
    ```

---

## 🤝 Contribution

This project is built by **Visionary Variables** for the MVGR student community.
**Team Lead:** Rahul Attili

---

*“Pass the knowledge, not the cost.”*
