# 🎓 Campus Connect
### Exclusive Peer-to-Peer Marketplace for MVGR Students

**Campus Connect** is a secure, student-exclusive platform designed to make buying and selling academic resources within the MVGR campus effortless. It connects seniors and juniors to exchange textbooks, tools, and electronics without the hassle of external platforms.

---

## 🚩 The Problem
Students often struggle to find affordable textbooks, drafters, and lab coats at the start of the semester. Meanwhile, seniors hoard these items or sell them as scrap. Existing platforms like OLX are too broad, full of spam, and lack trust.

## 💡 The Solution
A hyper-local marketplace that is **exclusive** to our college. By enforcing domain-level email verification, we ensure that every buyer and seller is a genuine student of MVGR, creating a safe and trusted community.

---

## ✨ Key Features

### 🔐 1. Verified & Secure (The "Walled Garden")
* **Domain Validation:** The app strictly enforces an `@mvgrce.edu.in` email check. Only students with a valid college ID can list items.
* **Email Verification:** Integration with **Firebase Auth** sends a real-time verification link to the student's inbox. Listings are only published once the email is verified.

### 🔎 2. Search & Discovery
* **Real-Time Search:** Users can instantly search for items by title (e.g., "Physics", "Arduino") using the integrated search bar.
* **Category Filters:** Filter the feed by specific categories: *Books, Electronics, Lab Coats, Tools,* and *Other*.
* **Grid View:** Items are displayed in a clean, responsive grid layout for easy browsing.

### 💬 3. Direct Connection
* **One-Click WhatsApp:** No need to save numbers. The "Chat" button instantly redirects buyers to WhatsApp with a pre-filled message mentioning the specific item.

### 🗑️ 4. Post Management
* **PIN Security:** Sellers create a unique **4-digit PIN** when posting.
* **Easy Deletion:** Items can be deleted securely by the owner using their PIN once the product is sold.

---

## 🛠️ Tech Stack

* **Frontend:** Flutter (Mobile & Web)
* **Backend:** Firebase Firestore (NoSQL Database)
* **Authentication:** Firebase Auth
* **State Management:** `setState` (Clean & Efficient)

---

## 🚀 Installation

To run this project locally:

1.  **Clone the repo:**
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

---

## 🔮 Future Enhancements
* **AI Price Suggestions:** Integrating Gemini API to help students price their used items fairly.
* **In-App Chat:** Building a dedicated chat system to preserve privacy.
* **Lost & Found Section:** A dedicated space for reporting lost items on campus.

---

### 👨‍💻 Team: Visionary Variables
*Built for the MVGR Hackathon.*
