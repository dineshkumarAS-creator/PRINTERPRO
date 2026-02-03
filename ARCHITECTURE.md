# PrintPro Manager - Architecture & Workflow

## 1. High-Level Architecture
The **PrintPro Manager** is a hybrid application designed to bridge modern UI with hardware functionality.

### **Frontend layer (Flutter)**
*   **Technology**: Flutter (Dart).
*   **Platform**: Web (Chrome) & Windows Desktop.
*   **Responsibility**:
    *   **UI/UX**: Provides a premium, high-contrast "Dark/Light" aesthetic.
    *   **Logic**: Manages user session, navigation, and print settings.
    *   **Voice Interaction**: Integrates `speech_to_text` to capture user intent (e.g., "Make 5 copies").
    *   **Visuals**: Uses `CustomPainter` and `AnimatedContainer` for the dynamic "Wave" visualizations corresponding to voice amplitude.

### **Backend Layer (Python)**
*   **Technology**: Python (Flask).
*   **Responsibility**:
    *   Acts as the bridge to physical hardware (Printers, Scanners) if needed.
    *   Processes heavy data or complex print job formatting.
    *   API Server: Runs on `localhost:5000`.

---

## 2. User Workflow (The "Happy Path")
This flow describes how a user interacts with the system to complete a print job using Voice Config.

### **Step 1: Dashboard (Home)**
*   **Screen**: `HomeScreen` (`MainNavigationScreen`).
*   **Action**: User views "Active Printers" and status cards.
*   **Interaction**: User clicks on a specific printer card (e.g., "HP LaserJet") to initiate a job or check details.

### **Step 2: Configuration (Review Settings)**
*   **Screen**: `ReviewSettingsScreen`.
*   **Context**: User sees options for Pages, Color vs B&W, and Quantity.
*   **Voice Feature**:
    *   User clicks the **"Voice Assistant"** FAB (Floating Action Button).
    *   A **Listening Sheet** pops up with a **Sound Wave Animation**.
    *   **User Speaks**: *"Change page 2 to color and name it Jeffrin Project."*
    *   **System Response**: The text is transcribed in real-time using `en-IN` (English India) locale.
    *   **Result**: The app captures the instructions (Future: parses them to update state).

### **Step 3: Preview & Execution**
*   **Screen**: `PreviewPrintScreen`.
*   **Action**: User confirms the specific layout.
*   **Final**: Job is sent to the Backend/Printer.

---

## 3. Developer Workflow (How to Run)
To bring this architecture to life, follow this sequence:

1.  **Start the Backend**:
    *   Command: `python backend/app.py`
    *   *Ensures the API is ready to accept jobs.*

2.  **Start the Frontend**:
    *   Command: `flutter run -d chrome`
    *   *Launches the UI with Web-API support for reliable Speech Recognition.*

---

## 4. Key Code Modules
*   **`lib/screens/home_screen.dart`**: The main dashboard.
*   **`lib/screens/review_settings_screen.dart`**: The core configuration screen containing the **Voice Assistant Logic**.
*   **`lib/main.dart`**: Entry point, routing to the Dashboard.
