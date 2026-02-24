# Nicolin Govender, UCL ARC
# 18/02/2026 Init version with local testing flags

import os
import sys
import re
from github import Github

# ------------------------------------------------------------------------------
# A] Config
SCRIPT_DIR = os.path.dirname(os.path.abspath(__file__))
FILE_PATH = os.path.join(SCRIPT_DIR, "docs/CONTRIBUTORS.md")

ACCESS_TOKEN = os.getenv("GITHUB_TOKEN")
REPO_NAME = os.getenv("GITHUB_REPOSITORY", "ucl-bug/k-wave")

SECTION_HEADER = "## Community Contributors"
SECTION_ENDER = "---"
# ------------------------------------------------------------------------------


def update_contributors():
    # ------------------------------------------------------------------------------
    # 1. Read Existing File First (We need to know where to start counting)
    if not os.path.exists(FILE_PATH):
        print(f"Error: File not found at {FILE_PATH}")
        sys.exit(1)

    with open(FILE_PATH, "r", encoding="utf-8") as f:
        content = f.read()

    if SECTION_HEADER not in content:
        print(f"Error: Header '{SECTION_HEADER}' not found.")
        sys.exit(1)

    # Split the file to isolate the Community Section
    _, post_header = content.split(SECTION_HEADER, 1)

    # If there's a footer, stop reading there
    if SECTION_ENDER in post_header:
        current_section, _ = post_header.split(SECTION_ENDER, 1)
    else:
        current_section = post_header

    # A) Find existing PR numbers to avoid duplicates (Regex: (#101))
    existing_prs = set(re.findall(r"\(#(\d+)\)", current_section))

    # B) Find the highest index number used so far (Regex: start of line "10.")
    # We look for digits followed by a dot at the start of a line
    existing_indices = [
        int(m.group(1)) for m in re.finditer(r"^(\d+)\.", current_section, re.MULTILINE)
    ]

    if existing_indices:
        next_index = max(existing_indices) + 1
    else:
        next_index = 1

    print(
        f"Found {len(existing_prs)} existing items. Next list number will be: {next_index}."
    )
    # ------------------------------------------------------------------------------

    # ------------------------------------------------------------------------------
    # 2. Fetch New Data
    new_lines_to_add = []

    if not ACCESS_TOKEN:
        print("!!! DRY RUN MODE (No Token) !!!")
        # Change numbers here to test adding new ones (e.g. 104, 105, 106)
        fake_prs = [
            {
                "title": "Added CUDA support",
                "number": 101,
                "user": "LocalTester",
                "url": "http://github.com/NG",
            },
            {
                "title": "Fixed memory leak",
                "number": 109,
                "user": "SampleDev",
                "url": "http://github.com/FeatureBranch",
            },
            {
                "title": "Documentation typos",
                "number": 1090,
                "user": "LocalTester",
                "url": "http://github.com/NG",
            },
        ]

        for pr in fake_prs:
            if str(pr["number"]) not in existing_prs:
                # Use the 'next_index' variable here
                line = f"{next_index}. {pr['title']} (#{pr['number']}) by [@{pr['user']}]({pr['url']})"
                new_lines_to_add.append(line)
                next_index += 1  # Increment for the next loop

    else:
        print(f"Connecting to {REPO_NAME}...")
        try:
            g = Github(ACCESS_TOKEN)
            repo = g.get_repo(REPO_NAME)
            pulls = repo.get_pulls(state="closed", sort="updated", direction="desc")

            # Do we want to add oldest new PRs first to keep numbering logical?
            # Or newest first? Usually lists grow downwards, so we process normally.

            # We convert to a list to reverse it if needed, or just iterate
            # Let's iterate.
            for pr in pulls:
                if pr.merged and pr.user.type != "Bot":
                    if str(pr.number) not in existing_prs:
                        clean_title = pr.title.strip().replace("|", "-")

                        # Use the counter variable
                        line = f"{next_index}. {clean_title} ([#{pr.number}]({pr.html_url})) by [@{pr.user.login}]({pr.user.html_url})"
                        new_lines_to_add.append(line)
                        next_index += 1  # Increment

        except Exception as e:
            print(f"GitHub Error: {e}")
            sys.exit(1)
    # ------------------------------------------------------------------------------

    # ------------------------------------------------------------------------------
    # 3. Update File (Append Strategy)
    if not new_lines_to_add:
        print("No new contributions found to add.")
        return

    # We need to insert the new lines *before* the SECTION_ENDER (---)
    # But *after* the SECTION_HEADER

    pre_ender, post_ender = content.split(SECTION_ENDER, 1)

    # 1. Clean the 'pre_ender' to remove trailing whitespace/newlines
    clean_pre_ender = pre_ender.rstrip()

    # 2. Construct the append block
    # We join the new items with newlines
    append_block = "\n".join(new_lines_to_add)

    # 3. CRITICAL FIX:
    # Add TWO newlines before the list starts to force a paragraph break in Markdown
    # Add TWO newlines after the list ends to separate it from the footer
    new_content = (
        clean_pre_ender + "\n\n" + append_block + "\n\n" + SECTION_ENDER + post_ender
    )

    with open(FILE_PATH, "w", encoding="utf-8") as f:
        f.write(new_content)

    print(f"Success! Added {len(new_lines_to_add)} new contributions.")


if __name__ == "__main__":
    update_contributors()
