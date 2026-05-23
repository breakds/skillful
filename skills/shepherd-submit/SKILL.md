---
name: shepherd-submit
description: Use when the user wants to submit a markdown file (.md) as a task to the shepherd task system, or mentions sending work to shepherd
---

# Submit Task to Shepherd

Submit a `.md` file (typically a plan or spec) as a task to the shepherd system.

## Inputs

- **file** (required): Path to the `.md` file. User provides as argument or references in conversation.
- **channel** (required): Shepherd channel name. If not provided, ask the user before proceeding.
- **server** (optional): Shepherd server URL. Default: `http://10.77.1.185:10201`

## Steps

1. Read the `.md` file content.
2. Generate a short kebab-case title summarizing the document (under 60 chars, e.g. `choice-reason-separate-line`).
3. Submit:
   ```bash
   shepherd task add \
     --server <server> \
     --title "<title>" \
     --description-file "<file-path>" \
     --channel "<channel>"
   ```
4. Confirm to the user: title, channel, and server used.
5. Verify with `shepherd task list --server <server> --channel <channel>` and confirm the task appears.
