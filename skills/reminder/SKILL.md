---
name: reminder
description: Set a macOS reminder at a specific time. Use when the user asks to be reminded about something, wants alerts before meetings, or says "remind me at...", "notify me before...", etc.
---

# Set Reminder

Create a persistent macOS reminder that will trigger a notification at a specified time.

## Usage

Use AppleScript to create a reminder with the correct date/time:

```bash
osascript <<'EOF'
tell application "Reminders"
    set targetList to default list

    -- Get today's date and set the desired time
    set reminderDate to current date
    set hours of reminderDate to 14      -- 24-hour format (e.g., 14 = 2 PM)
    set minutes of reminderDate to 58
    set seconds of reminderDate to 0

    -- Create the reminder
    set newReminder to make new reminder in targetList
    set name of newReminder to "Your reminder message here"
    set remind me date of newReminder to reminderDate
end tell
EOF
```

## Important Notes

1. **Use `current date` as the base** - Don't try to parse date strings directly, as AppleScript date parsing is unreliable. Always start with `current date` and modify the hours/minutes.

2. **Use 24-hour format for hours** - Set hours using 24-hour time (0-23).

3. **Verify after creation** - Always verify the reminder was created correctly:

```bash
osascript <<'EOF'
tell application "Reminders"
    repeat with r in (reminders in default list whose completed is false)
        set rName to name of r
        if rName contains "your search term" then
            set rDate to remind me date of r
            log rName & " - " & (rDate as string)
        end if
    end repeat
end tell
EOF
```

## Why Use Reminders Instead of Background Processes

- Background shell processes (`sleep X && notify`) won't persist if the terminal closes
- Reminders persist system-wide and work even after logout/restart
- Reminders app handles notification delivery reliably
