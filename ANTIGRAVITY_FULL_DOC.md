# AntiGravity - Complete Project Documentation
# AI Voice-Controlled Smart Printing System

---

## 1. Project Title
**AntiGravity – AI Voice-Controlled Smart Printing System**

---

## 2. Problem Statement
Traditional printing systems require manual configuration such as selecting copies, color mode, pages, and printer settings. This process is time-consuming and not user-friendly, especially for non-technical users or users with accessibility needs.

---

## 3. Proposed Solution
AntiGravity introduces an AI-powered voice assistant that allows users to control printer settings using natural voice commands. The system provides a smart dashboard, real-time printer monitoring, and automated print configuration based on voice intent.

---

## 4. Overall System Diagram
```mermaid
graph TD
    User((User)) -->|Voice/Click| UI[Frontend UI (Flutter/Web)]
    UI --> STT[Speech-to-Text Engine]
    STT --> AI[AI Command Parser (NLP)]
    AI --> Logic[Print Settings Manager]
    Logic --> Backend[Backend API Server (Node.js/Python)]
    Backend --> DB[(Database)]
    Backend --> Printer[Physical Printer / System Service]
```

---

## 5. System Architecture (Layered Model)

### **Layer 1 – Presentation (UI)**
*   **Technologies**: Flutter (Web & Windows).
*   **Components**:
    *   **Dashboard**: Displays active printers and status.
    *   **Review Settings**: Main control center for print jobs.
    *   **Voice Assistant Panel**: Interactive modal for voice input.
    *   **New Printer Flow**: Setup wizard for hardware.

### **Layer 2 – Intelligence (AI)**
*   **Technologies**: Web Speech API / `speech_to_text`.
*   **Components**:
    *   **Speech Recognition**: Converts audio to text stream.
    *   **Intent Detection**: Identifies "Print", "Config", or "Cancel".
    *   **Command Verification**: Checks if request is valid (e.g., valid page range).

### **Layer 3 – Application Logic**
*   **Components**:
    *   **State Management**: Holds current configuration (Copies: 5, Color: True).
    *   **Job Queue**: Manages list of pending prints.

### **Layer 4 – Backend & Data**
*   **Technologies**: Python (Flask) / Node.js.
*   **Components**:
    *   **API**: REST endpoints for job submission.
    *   **Data Store**: Local storage or Cloud DB for printer profiles.

---

## 6. Applications Flow (User Journey)

### **Main Flow**
1.  **Splash Screen** -> App Init.
2.  **Dashboard** -> View Printer List.
3.  **Select Printer** -> Click "HP LaserJet".
4.  **Review Settings** -> View Page Options.
5.  **Voice Assistant** -> Speak "Make 5 copies".
6.  **Confirmation** -> Verify "5 Copies, B&W".
7.  **Print** -> Execute Job.

### **New Printer Setup Flow**
1.  **Dashboard** -> Click "Add Printer".
2.  **Detection** -> "New Printer Found".
3.  **Setup** -> Select Type (B&W/Color).
4.  **Pricing** -> Set Rate per Page.
5.  **Completion** -> Printer added to Dashboard.

---

## 7. UI Wireframe Concepts

### **Dashboard Screen**
```text
--------------------------------------
           AntiGravity              
--------------------------------------
 [HP LaserJet Pro]   ● PRINTING
   Location: Lab 1

 [Epson L3150]       ● IDLE
   Location: Office

             [ + Add Printer ]
--------------------------------------
```

### **Voice Assistant Panel**
```text
--------------------------------------
           Listening...             
      ||||||| | |||| | |||||||      
     (Dynamic Wave Animation)

  "Make 5 copies and set color"     
--------------------------------------
 [ Stop ]
```

---

## 8. Voice Assistant Logic (AI Command Parser)

**Pseudocode Logic:**
```javascript
function parseCommand(speechText) {
    let settings = { copies: 1, color: false };
    
    // Extract Copies
    if (speechText.includes("copies")) {
        let number = speechText.match(/\d+/);
        if (number) settings.copies = parseInt(number[0]);
    }
    
    // Extract Mode
    if (speechText.includes("color") || speechText.includes("colour")) {
        settings.color = true;
    } else if (speechText.includes("black and white") || speechText.includes("b&w")) {
        settings.color = false;
    }
    
    return settings;
}
```

**Example Data Flow:**
*   **Input**: "I need 10 copies in color."
*   **Output JSON**: `{ "copies": 10, "color": true }`
*   **Action**: Update UI State variables.

---

## 9. Code Structure Overview

### **Frontend (Flutter)**
```text
lib/
 ├── main.dart                  # Entry Point
 ├── screens/
 │    ├── home_screen.dart           # Dashboard
 │    ├── review_settings_screen.dart # Voice Logic Here
 │    ├── select_printer_screen.dart # Setup Flow
 │    ├── set_price_screen.dart      # Setup Flow
 │    └── preview_screen.dart        # Final confirmation
 ├── services/
 │    ├── speech_service.dart        # STT Logic
 │    └── printer_service.dart       # Backend API calls
 └── utils/
      ├── wave_animation.dart        # Visuals
      └── theme.dart                 # Styling
```

### **Backend (Python)**
```text
backend/
 ├── app.py                     # Flask Server
 ├── controllers/
 │    └── printer_controller.py
 ├── requirements.txt           # Dependencies
 └── database.json              # Simple Storage
```

---

## 10. Hackathon Pitch (Key Selling Points)
*   **Innovation**: Moves beyond clicking buttons to natural conversation.
*   **Accessibility**: Enables usage for visually impaired or busy users.
*   **Intelligence**: Context-aware setting updates (understands "Color" implies pricing change).
*   **Design**: High-contrast, premium aesthetic akin to modern SaaS tools.
