# 🎓 Campus Connect
### The Smart, Exclusive Marketplace for MVGR Students

**Campus Connect** is a hyper-local peer-to-peer marketplace designed exclusively for the students of MVGR College of Engineering. It empowers students to buy, sell, and recycle academic resources like textbooks, drafters, and electronics within a secure, "walled garden" environment.

---

## 🚩 The Problem
Every semester, students spend thousands on new textbooks and engineering tools (drafters, lab coats), only to use them for a few months. Meanwhile, seniors struggle to discard these same items. Existing platforms like OLX are too broad, full of spam, and lack trust.

## 💡 The Solution
A **college-exclusive platform** that bridges the gap between seniors and juniors. By combining **AI-powered listing tools** with **strict student verification**, we created a marketplace that is fast, safe, and incredibly easy to use.

---

## ✨ Key Features

### 🤖 1. AI-Powered Listings (Powered by Gemini)
* **Smart Descriptions:** Writing sales pitches is boring. We integrated **Google Gemini AI**. Users simply type a title (e.g., "Engineering Physics"), click **"✨ AI Write"**, and the app automatically generates a persuasive, catchy description for the item.

### 🔐 2. Campus-Exclusive Security
* **Domain Lock:** The app strictly enforces an `@mvgrce.edu.in` email check. Outsiders cannot post listings.
* **Real-Time Verification:** We use **Firebase Auth** to send instant verification links. A post is held in a "pending" state and only goes live once the student verifies their email ownership.

### 🎨 3. Modern "Frictionless" UI
* **Visual Discovery:** A beautiful, pastel-coded grid layout makes browsing enjoyable.
* **Smart Filters:** One-tap pill filters for categories (*Books, Electronics, Tools, Lab Coats*).
* **Product Details Page:** A dedicated, immersive view for every item showing full AI descriptions and seller details.

### ⚡ 4. Instant Connection
* **Direct WhatsApp Integration:** No need to save numbers. The "Chat to Buy" button instantly opens WhatsApp with a pre-filled message: *"Hi, I'm interested in your [Item Name]..."*
* **PIN Management:** Sellers create a 4-digit PIN to securely delete their items after they are sold.

---

## 🛠️ Tech Stack

* **Frontend:** Flutter (Mobile & Web)
* **Backend:** Firebase Cloud Firestore (Real-time Database)
* **Authentication:** Firebase Auth (Email Verification)
* **AI Integration:** Google Gemini API (via Direct HTTP for speed & stability)
* **State Management:** Native State (Clean & Efficient)

---

## 🚀 How to Run Locally

1.  **Clone the Repository:**
    ```bash
    git clone [https://github.com/your-username/campus-connect.git](https://github.com/your-username/campus-connect.git)
    ```

2.  **Install Dependencies:**
    ```bash
    flutter pub get
    ```

3.  **Setup Secrets:**
    * Create a file `lib/api_key.dart` and add your Gemini API Key:
    * `const String geminiApiKey = "YOUR_KEY_HERE";`

4.  **Run the App:**
    ```bash
    flutter run
    ```

---

## 🔮 Future Roadmap

* **In-App Bidding:** Allow students to bid on high-demand items like Drafters during exam season.
* **Book Exchange Mode:** A "Swap" feature where money isn't needed—just trade book for book.
* **Lost & Found:** A dedicated section for reporting lost IDs or keys on campus.

---

### 👨‍💻 Team: Visionary Variables
*Built with ❤️ for the MVGR Hackathon.*