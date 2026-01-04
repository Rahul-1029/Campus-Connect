# 🎓 Campus Connect: MVGR Peer-to-Peer Marketplace

**Campus Connect** is a hyper-local, exclusive marketplace built specifically for the students of MVGR College of Engineering. It solves the problem of expensive academic resources by connecting seniors with juniors to buy, sell, and recycle textbooks, tools, and electronics securely.

---

## 🚀 Project Overview

Most students struggle to find affordable textbooks or engineering tools (like Drafters/Lab Coats) nearby, while seniors often discard them. Campus Connect bridges this gap with a **frictionless, secure, and college-exclusive** platform.

Unlike public marketplaces (OLX/Facebook), Campus Connect creates a "Walled Garden" where **only verified MVGR students** can list items, ensuring safety and relevance.

---

## ✨ Key Features

### 🔒 1. Campus-Exclusive Security (The "Walled Garden")
* **Domain Verification:** We enforce strict email validation. Only users with a valid `@mvgrce.edu.in` email address can post listings.
* **Real-Time Verification:** Integrated with **Firebase Authentication** to send instant verification links. A post only goes live after the user verifies ownership of the college email.

### 🔎 2. Modern Discovery & Filtering
* **Global Search:** A floating search bar allows students to find specific items (e.g., "Quantum Physics", "Scientific Calculator") instantly.
* **Smart Filters:** One-tap category pills to toggle between *Books, Electronics, Lab Coats,* and *Tools*.
* **Visual Grid Layout:** A polished, Pinterest-style 2-column grid with pastel color-coding for effortless browsing.

### ⚡ 3. Frictionless User Experience
* **No-Login Browsing:** Buyers can open the app and browse immediately without creating an account.
* **Direct WhatsApp Integration:** A "Chat to Buy" button instantly opens a pre-filled WhatsApp message to the seller (e.g., *"Hi, I am interested in your Engineering Physics book..."*).
* **Secure Management:** Sellers create a unique **4-digit PIN** for every post, allowing them to securely delete the item once it is sold.

---

## 🛠️ Tech Stack

* **Framework:** Flutter (Cross-platform for Web & Mobile)
* **Language:** Dart
* **Database:** Cloud Firestore (Real-time data syncing)
* **Authentication:** Firebase Auth (Email Link Verification)
* **Networking:** HTTP (Direct API integration capability)

---

## 📖 How It Works

### For Buyers:
1.  **Search:** Use the search bar or category filters to find what you need.
2.  **View:** Tap on a card to see the price, seller name, and time posted.
3.  **Buy:** Click the **WhatsApp Icon**. The app redirects you to a chat with the seller.

### For Sellers:
1.  **List:** Tap the **+ (Add)** button.
2.  **Details:** Enter the Item Title, Price, and your WhatsApp number.
3.  **Verify:** Enter your **@mvgrce.edu.in** email.
4.  **Publish:** Click the verification link sent to your inbox. The app detects this automatically and pushes your item to the live feed.

---

## 🔧 Installation & Setup

To run this project locally:

1.  **Clone the repository:**
    ```bash
    git clone [https://github.com/your-username/campus-connect.git](https://github.com/your-username/campus-connect.git)
    ```

2.  **Install dependencies:**
    ```bash
    flutter pub get
    ```

3.  **Run the app:**
    ```bash
    flutter run
    ```

*(Note: This project requires a valid `firebase_options.dart` file linked to your Firebase Console project to function correctly.)*

---

## 🔮 Future Scope

* **AI Price Estimator:** Integration with Gemini API to suggest fair market prices for used items.
* **Barter Mode:** Enabling students to exchange items directly (e.g., swapping a 1st-year book for a 2nd-year book).
* **In-App Messaging:** A built-in chat system to replace WhatsApp for privacy.

---

### 👨‍💻 Team: Visionary Variables
*Built with ❤️ for the MVGR Student Community.*