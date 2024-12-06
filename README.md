# MATLAB Ball Tracking and Robot Control Script

## Overview
This MATLAB script is designed to detect a target object (e.g., a ball) using a webcam, calculate its position in real-world coordinates, and control a robotic arm to interact with the object. The program includes features for real-time video processing, stability detection, and sending movement commands to a robot via serial communication.

---

## Features
- **Real-time Ball Detection:** Captures video from a webcam, processes it to identify the target based on HSV color thresholds, and computes the object's centroid.
- **Stability Detection:** Monitors object movement to ensure it's stable before making robotic decisions.
- **Robotic Arm Control:** Calculates coordinates for the robot arm to move to positions relative to the ball (e.g., 2 cm behind or 5 cm forward) and sends commands via a serial connection.
- **Visualization:** Displays real-time processed frames and overlays the detected centroid.

---

## Requirements

### Hardware
- **Webcam:** A compatible camera (e.g., NexiGo N60 FHD Webcam).
- **Robotic Arm:** A robotic arm that accepts serial commands for movement.
- **Serial Port:** COM3 (or another port, adjustable in the code).

### Software
- **MATLAB:** Version R2021a or newer (with Image Processing Toolbox).
- **Dependencies:**
  - MATLAB's `webcam` support package.
  - Inverse kinematics function `inverse_kin_3DOF` (must be provided separately or implemented).

---

## Setup Instructions
1. **Connect Devices:**
   - Plug in the webcam.
   - Connect the robotic arm to the computer via a serial port.

2. **Configure the Code:**
   - Update the webcam model name in the `webcam` initialization line if necessary:
     ```matlab
     cam = webcam('Your Webcam Name');
     ```
   - Adjust the serial port if different from `COM3`:
     ```matlab
     p1 = serial('COM3', 'BaudRate', 115200);
     ```

3. **Install Required Packages:**
   - Ensure MATLAB has the necessary toolboxes and the `webcam` support package installed.

---

## How to Run
1. Open the script in MATLAB.
2. Run the script using the "Run" button or by typing the script's filename in the command window.
3. The program will:
   - Initialize the webcam and serial connection.
   - Start detecting the target and display results in a pop-up window.
   - Send commands to the robotic arm to interact with the ball.

---

## Parameters

### Adjustable Detection Parameters
- **HSV Thresholds:** Modify `channel1Min`, `channel1Max`, etc., to adjust color detection sensitivity.
- **Stability Detection:**
  - `stable_threshold`: Minimum movement threshold for detecting stability (in pixels).
  - `stable_frames`: Number of frames to consider for stability.

### Robot Interaction
- The robot calculates the following positions relative to the ball:
  - **Back Position:** 2 cm behind the ball.
  - **Forward Position:** 5 cm ahead of the ball.
  - These offsets can be adjusted by changing the `0.03` values in the direction calculations.

---

## Visualization
- A live video feed shows the processed binary image with the detected object's centroid marked with a magenta star.

---

## Error Handling
- If the ball is not detected, the script outputs:
No target detected!
- Ensure the webcam and robotic arm are properly connected if errors persist.

---

## Notes
- The `inverse_kin_3DOF` function must be implemented to translate x-y-z coordinates into robot-specific joint angles.
- The script assumes the target object's color fits within the defined HSV range.

---

## Troubleshooting
- **Webcam Not Detected:**
- Ensure the correct webcam name is specified.
- Use `webcamlist` in MATLAB to identify available webcams.
- **No Target Detected:**
- Adjust HSV thresholds for better segmentation.
- **Robot Not Moving:**
- Confirm the serial port is correct.
- Verify the robotic arm's communication protocol matches the script's format.

---

## License
This code is provided as-is for educational and research purposes. Feel free to modify it for your needs.

---

## Contact
For questions or issues, please reach out to `[Your Name/Email]`.
