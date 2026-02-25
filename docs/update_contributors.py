# Nicolin Govender, UCL ARC
# 25/02/2026 Updated to ensure unique user lines and proper Markdown spacing

import os
import sys
import re
from github import Github

# ------------------------------------------------------------------------------
# A] Config
SCRIPT_DIR = os.path.dirname(os.path.abspath(__file__))
FILE_PATH = os.path.join(SCRIPT_DIR, "CONTRIBUTORS.md")

ACCESS_TOKEN = os.getenv("GITHUB_TOKEN")
REPO_NAME = os.getenv("GITHUB_REPOSITORY", "ucl-bug/k-wave")

SECTION_HEADER = "## Community Contributors"
SECTION_ENDER = "---"
# ------------------------------------------------------------------------------

def update_contributors():
    # ------------------------------------------------------------------------------
    # 1. Read Existing File and Find Existing Users Only  NG Updated
    if not os.path.exists(FILE_PATH):
        print(f"Error: File not found at {FILE_PATH}")
        sys.exit(1)

    with open(FILE_PATH, "r", encoding="utf-8") as f:
        content = f.read()

    if SECTION_HEADER not in content:
        print(f"Error: Header '{SECTION_HEADER}' not found.")
        sys.exit(1)

    # Isolate the section where the list lives
    _, post_header = content.split(SECTION_HEADER, 1)
    if SECTION_ENDER in post_header:
        current_section, _ = post_header.split(SECTION_ENDER, 1)
    else:
        current_section = post_header

    # Extract all existing URLs to avoid duplicate people NG Updated
    existing_urls = set(re.findall(r"\(https://github\.com/[^\)]+\)", current_section))
    
    # Calculate the next index for the numbered list
    existing_indices = [
        int(m.group(1)) for m in re.finditer(r"^(\d+)\.", current_section, re.MULTILINE)
    ]
    next_index = max(existing_indices) + 1 if existing_indices else 1
    # ------------------------------------------------------------------------------

    # ------------------------------------------------------------------------------
    # 2. Fetch New Data (GitHub or Local Dry Run)
    new_lines_to_add = []
    seen_urls_this_run = set()

    if not ACCESS_TOKEN:
        print("!!! DRY RUN MODE (No Token) !!!")
        fake_data = [
            {"user": "LocalTesterAA", "url": "https://github.com/NGAA"},
            {"user": "SampleDev", "url": "https://github.com/FeatureBranch"},
            {"user": "LocalTester", "url": "https://github.com/NG"}, # Duplicate check
        ]
        for item in fake_data:
            url_pattern = f"({item['url']})"
            if url_pattern not in existing_urls and item['url'] not in seen_urls_this_run:
                line = f"{next_index}. [@{item['user']}]({item['url']})"
                new_lines_to_add.append(line)
                seen_urls_this_run.add(item['url'])
                next_index += 1
    else:
        print(f"Connecting to {REPO_NAME}...")
        try:
            g = Github(ACCESS_TOKEN)
            repo = g.get_repo(REPO_NAME)
            pulls = repo.get_pulls(state="closed", sort="updated", direction="desc")

            for pr in pulls:
                if pr.merged and pr.user.type != "Bot":
                    user_url = pr.user.html_url
                    url_pattern = f"({user_url})"
                    
                    if url_pattern not in existing_urls and user_url not in seen_urls_this_run:
                        line = f"{next_index}. [@{pr.user.login}]({user_url})"
                        new_lines_to_add.append(line)
                        seen_urls_this_run.add(user_url)
                        next_index += 1
        except Exception as e:
            print(f"GitHub Error: {e}")
            sys.exit(1)
    # ------------------------------------------------------------------------------

    # ------------------------------------------------------------------------------
    # 3. Reconstruct and Write File
    if not new_lines_to_add:
        print("No new unique contributors found.")
        return

    # Split original content at the ender
    pre_ender, post_ender = content.split(SECTION_ENDER, 1)
    
    # Strip trailing whitespace from pre_ender to prevent growing gaps
    clean_pre_ender = pre_ender.rstrip()
    
    # Combine new items with explicit newlines
    append_block = "\n".join(new_lines_to_add)

    # Reassemble: 
    # [Pre-Ender] + [Double Newline] + [List] + [Double Newline] + [Ender] + [Post-Ender]
    new_content = (
        clean_pre_ender + 
        "\n\n" + 
        append_block + 
        "\n\n" + 
        SECTION_ENDER + 
        post_ender
    )

    with open(FILE_PATH, "w", encoding="utf-8") as f:
        f.write(new_content)

    print(f"Success! Added {len(new_lines_to_add)} unique contributor(s) to {FILE_PATH}")
    # ------------------------------------------------------------------------------

if __name__ == "__main__":
    update_contributors()