# EE2390-Final-Project
State Machine Design for a Stopwatch

### TimeSet mode
- Use sw15 to enter TimeSet mode from the stopped state
- When in TimeSet mode, press start to begin rapidly counting in the direction of dir_active
- Pressing stop will pause the counting, but remain in TimeSet mode
- If sw15 is turned off while stopped, the stopwatch will return to the stopped state
- If sw15 is turned off while rapidly counting, the stopwatch will keep counting, but return to the normal speed
