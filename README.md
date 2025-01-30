# **Mac-style Dock** 🚀

A Flutter-based **Mac-style Dock** with smooth hover and drag interactions. This project provides a dynamic, interactive dock with customizable scaling and reordering capabilities.

## 📖 **Overview of Documentation**

The existing documentation provides detailed explanations of the following components:

### **1. Application Structure**
- **`main.dart`** → Defines the application's entry point and initializes the `HomePage`.
- **`HomePage.dart`** → Hosts the `MacDock` widget and manages the UI layout.

### **2. `MacDock<T>` Widget**
A customizable dock that supports:
- ✅ **Dynamic item scaling** on hover.
- ✅ **Smooth drag-and-drop reordering** of icons.

The documentation includes:
- Usage guidelines.
- Explanation of core functionalities.
- Customization options for developers.

### **3. State Management (`MacDockState<T>`)**
Handles essential logic for:
- **Hover scaling calculations** to create a smooth zoom effect.
- **Drag interactions** for reordering icons dynamically.

#### 🔹 **Key Method: `calculateItemValue()`**
- Determines item scaling based on cursor distance.
- Ensures a responsive and smooth animation effect.

### **4. Drag Placeholder (`PlaceholderWidget`)**
A temporary widget used during drag operations to maintain smooth animations.

The documentation covers:
- **Role of the placeholder** in drag-and-drop interactions.
- **Customization options** to modify its behavior.

## 🛠 **How It Works**
For implementation details, customization options, and best practices, refer to the **in-code documentation** provided within the project files.
