# AI usage or MemoUp

I used Claude as an ai assistant in making this app. used it for code generations, development guides.

## 1. How I used AI

At least six entries. One per real use. Every entry needs a commit link.

### 2026-09-19 -   Development of Home screen

- **Tool:Claude AI**
- **What I asked for: Assistance for creating the home screen**
- **What it gave back: constants/spacing.dart, home_screen.dart, and three widgets (task_card.dart, primary_button.dart, bottom_nav_bar.dart), wired into main.dart.**
- **What I kept, what I changed, and why:i kept the overall looks of the home screen, the today's reminder and upcoming reminders were empty so i put temporary stakholders to show what it would look like finised.**
- **Commit: https://github.com/ZachLN23/MemoUp/commit/ab59cd74da5280a534e8aae8aa6cb1439a975c28

### 2026-09-26 -  Task Detail and Completed screens

- **Tool:Claude AI**
- **What I asked for:add/edit a reminder, and a completed-reminders screen.**
- **What it gave back:task_detail_screen.dart (title, date/time pickers, subtasks, Save), completed_screen.dart (list + Clear History), plus task.dart and app_data.dart**
- **What I kept, what I changed, and why:kept the given code overall but tweaked the design to my liking**
- **Commit: https://github.com/ZachLN23/MemoUp/commit/9c075ff0c27ffd6288c69ac69f1dad93b95fdd99

### 2026-09-26 - file_picker version bug

- **Tool:Claude AI**
- **What I asked for:help after FilePicker.platform showed as an undefined getter even though the import resolved.**
- **What it gave back:identified that file_picker 10.3.9 shipped with .platform accidentally removed (an upstream bug, fixed in 10.3.10), and narrowed the pubspec.yaml constraint to >=10.3.10 <12.0.0 to dodge both that regression and v12's unrelated API rewrite.**
- **What I kept, what I changed, and why:The first fix attempt (constraining to >=8.0.0 <12.0.0) still left the door open to the exact broken release — I didn't catch that myself, Claude found it after I reported .platform was still showing undefined. Kept the corrected >=10.3.10 <12.0.0 constraint once that was explained.**
- **Commit: https://github.com/ZachLN23/MemoUp/commit/9c075ff0c27ffd6288c69ac69f1dad93b95fdd99

### 2026-09-26 - file_picker version bug

- **Tool:Claude AI**
- **What I asked for:help to develop the "upload custom audio" feature from the design system**
- **What it gave back:sound_settings_screen.dart (snooze-time picker, a sound checklist, Upload New Audio wired to the real device file picker via the file_picker package) and the matching AppData methods.**
- **What I kept, what I changed, and why:Kept the code for the upload audio, changed the look of the given page**
- **Commit: https://github.com/ZachLN23/MemoUp/commit/9c075ff0c27ffd6288c69ac69f1dad93b95fdd99

### 2026-10-04 - file_picker version bug

- **Tool:Claude AI**
- **What I asked for:to help me with the notification pop up feature**
- **What it gave back:**
- **What I kept, what I changed, and why:Kept the code for the upload audio, changed the look of the given page**
- **Commit: https://github.com/ZachLN23/MemoUp/commit/0a002e67af7f0b2f6df2f3e4bd0523102e7af2c3

## 2. Where the AI got it wrong

Three cases. Be specific. If you write that the AI was never wrong, this section
scores zero.

### Case 1 - file_picker constraint too wide

- **What it gave me: file_picker: ">=8.0.0 <12.0.0"**
- **What was wrong with it: that range still allowed pub to resolve to 10.3.9, a specific patch release with FilePicker.platform accidentally removed — so the constraint "worked" in the sense of not crashing, but didn't actually guarantee the API I was calling would exist.**
- **What I did instead: tightened it to >=10.3.10 <12.0.0, with a comment explaining why the lower bound is there specifically, not just the upper one.**
- **Commit: https://github.com/ZachLN23/MemoUp/commit/9c075ff0c27ffd6288c69ac69f1dad93b95fdd99**


### Case 2 - "notification feature" wasn't actually a notification

- **What it gave me: an Alarm Popup that fires from a 30-second in-app timer checking task due-times while Home is open.**
- **What was wrong with it: it only works if the app happens to be open in the foreground at that moment. If the app is closed or backgrounded, nothing fires at all.**
- **What I did instead: real notifications need flutter_local_notifications plus Android/iOS permission setup, which isn't done.**
- **Commit:https://github.com/ZachLN23/MemoUp/commit/0a002e67af7f0b2f6df2f3e4bd0523102e7af2c3**

### Case 3 - 30 seconds late, by design, without flagging the cost

- **What it gave me: Runs on a Timer.periodic every 30 seconds.**
- **What was wrong with it: Runs on a Timer.periodic every 30 seconds**
- **What I did instead: Shorten the interval**
- **Commit:https://github.com/ZachLN23/MemoUp/commit/0a002e67af7f0b2f6df2f3e4bd0523102e7af2c3 **

  
## 3. Who wrote what

At least a fifth of this project is code you wrote yourself. Name it, and explain
it in your own words.

> Group projects: give each member their own heading below, and use your GitHub
> handle as the heading. You are graded on your own section.

### Written by me

- **File: lib/theme.dart**
- **Commit: //github.com/ZachLN23/MemoUp/commit/9c075ff0c27ffd6288c69ac69f1dad93b95fdd99**
- **What it does and why it is built this way: This file contains the colors and theme settings used throughout the app. I customized the theme based on my personal preferences to make the app look clean, consistent, and visually appealing**

### The AI-written part I understand best

- **File:lib/home_screen.dart**
- **Commit:https://github.com/ZachLN23/MemoUp/commit/ab59cd74da5280a534e8aae8aa6cb1439a975c28**
- **What it does and why we kept it:This file contains the main home screen of MemoUp. It displays the main features and information that users see when they open the app. Kept it because it serves as the starting point of the app and provides access to the other features. **
