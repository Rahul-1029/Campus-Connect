# 🎓 Campus Connect
### The All-in-One Smart Marketplace & Lost & Found for MVGR Students

**Campus Connect** is a hyper-local platform designed exclusively for **MVGR College of Engineering**. It unifies two critical campus needs: a secure **Peer-to-Peer Marketplace** for academic resources and a rapid-response **Lost & Found Network**—all within a single, beautifully designed app.

---

## 🚀 Built for MVGR Hackathon (Offline Round)
**Team:** Visionary Variables  
**Status:** 🟢 LIVE (Offline Mode Ready)

---

## 🚩 The Problem
1.  **The Resource Gap:** Students spend thousands on temporary items (Aprons, books) while seniors struggle to sell them. OLX is too broad; WhatsApp groups are too chaotic.
2.  **The "Lost Item" Chaos:** When a student loses an ID card or wallet, they spam random WhatsApp groups. There is no central, searchable database for lost items on campus.

## 💡 The Solution
A **Dual-Mode Application** that adapts to the user's intent:
* **🔵 Market Mode:** A clean, AI-powered store for buying/selling.
* **🔴 Alert Mode:** A high-visibility "Red Zone" for reporting and recovering lost items instantly.

---

## ✨ Key Features

### 🔄 1. Dual-Mode Interface (Innovative UI)
* **One-Tap Toggle:** Instantly switch the entire app environment.
    * **Marketplace (Blue/White):** Calm, clean aesthetic for browsing products.
    * **Lost & Found (Red/Alert):** Urgent, high-contrast "Sticky Note" design with watermark alerts for lost items.

### 📢 2. The Lost & Found Network (NEW)
* **Sticky Note Alerts:** Lost items are displayed as digital "sticky notes" with visual watermarks, making them impossible to miss.
* **Smart "Found It" Action:** One click connects the finder to the owner via WhatsApp with a pre-filled message: *"I found your Blue Wallet..."*
* **Secure Deletion:** Posters set a **4-digit PIN** to securely delete the post once the item is recovered.

### 🤖 3. AI-Powered Listings (Powered by Gemini)
* **Zero-Typing Selling:** Users just type a title (e.g., "Engineering Physics"), click **"✨ AI Write"**, and Google Gemini generates a persuasive sales pitch automatically.

### 🔐 4. Campus-Exclusive Security
* **Verified Ecosystem:** Email domain checks ensure only `@mvgrce.edu.in` students can access the platform.
* **Privacy First:** Phone numbers are protected behind the "Chat" button; no public exposure until necessary.

---

## 🛠️ Tech Stack

* **Frontend:** Flutter (Responsive Mobile & Web)
* **Backend:** Firebase Cloud Firestore (Dual Collections: `listings` & `lost_found`)
* **Auth:** Firebase Authentication (Email/Google)
* **AI:** Google Gemini API (Content Generation)
* **State Management:** Native State (Performance Optimized)

---

## 🚀 How to Run (Offline / Judge's Demo)

Since this project uses secure keys, follow these steps to run it locally:

1.  **Clone the Repo:**
    ```bash
    git clone [https://github.com/rahul-attili/campus-connect.git](https://github.com/rahul-attili/campus-connect.git)
    cd campus-connect
    ```

2.  **Install Dependencies:**
    * *Note: If offline, ensure you have the Flutter cache on your machine.*
    ```bash
    flutter pub get
    ```

3.  **🔑 Configure Secrets (Crucial):**
    Create a file named `lib/api_key.dart` and add the following:
    ```dart
    const String geminiApiKey = "YOUR_GEMINI_API_KEY";
    ```

4.  **Run the App:**
    * **For Web (Recommended for Demo):**
        ```bash
        flutter run -d chrome
        ```

---

### 👨‍💻 Team: Visionary Variables
* **Lead:** Rahul Attili
* **Role:** Full Stack Dev & UI/UX
* *Built with ❤️ in MVGR.*
