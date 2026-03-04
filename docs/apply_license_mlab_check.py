# Nicolin Govender, UCL ARC
# 26/2/2026: License header enforcement for .m files (Issue #14)
# replace "wrong" or outdated license blocks with Verbose output (we can disable after release)

import os
import sys

#==============================================================================
# Config: Set to True to see detailed line-by-line actions in the console
VERBOSE = True

LICENSE_TEXT = """% Copyright (C) 2024- The k-Wave Authors.
%
% This file is part of k-Wave-II (http://www.k-wave.org). k-Wave-II is free
% software: you can redistribute it and/or modify it under the terms of the
% GNU Lesser General Public License as published by the Free Software
% Foundation, either version 3 of the License, or (at your option) any
% later version.
% 
% k-Wave-II is distributed in the hope that it will be useful, but WITHOUT
% ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
% FITNESS FOR A PARTICULAR PURPOSE.  See the GNU Lesser General Public
% License for more details.
% 
% You should have received a copy of the GNU Lesser General Public License
% along with k-Wave-II. If not, see <http://www.gnu.org/licenses/>.
"""
#==============================================================================

#==============================================================================
# 1] Unique strings to identify the boundaries of the license block
START_ID = "% Copyright (C) 2024- The k-Wave Authors."
END_ID = "along with k-Wave-II. If not, see <http://www.gnu.org/licenses/>."
#==============================================================================

#==============================================================================
# 2] Core logic: If license is missing or wrong, it will replace/add the block
def process_file(path):
    """Checks and fixes a single .m file. Prioritizes Help-First order."""
    if not path.lower().endswith(".m"):
        return

    try:
        with open(path, 'r', encoding='utf-8') as f:
            lines = f.readlines()
    except Exception as e:
        if VERBOSE: print(f"  [!] Skip {path}: {e}")
        return
    
    content = "".join(lines)

    # Check if the exact current license is already there
    if LICENSE_TEXT in content:
        return

    if VERBOSE: print(f"\n>>> Processing: {path}")

    # Detect and remove outdated/wrong blocks to enforce requirement 2]
    start_idx = -1
    end_idx = -1
    for i, line in enumerate(lines):
        if START_ID in line:
            start_idx = i
        if END_ID in line:
            end_idx = i
            break 

    if start_idx != -1 and end_idx != -1:
        if VERBOSE: print(f"  [-] Removing outdated/wrong license (Lines {start_idx+1}-{end_idx+1})")
        del lines[start_idx : end_idx + 1]
    elif VERBOSE:
        print(f"  [+] No valid license found. Preparing fresh insertion.")

    # -------------------------------------------------------------------------
    # Help-First Insertion Logic: (NG: Normal license first is convention but the issue says helps first)
    # 1. Skip the function/classdef line (if it exists)
    # 2. Skip the first contiguous block of comments (Help text)
    # 3. Insert license there
    # -------------------------------------------------------------------------
    insert_idx = 0
    in_help_block = False

    for i, line in enumerate(lines):
        stripped = line.strip()
        
        # Skip function or classdef at the very top
        if i == 0 and (stripped.startswith('function') or stripped.startswith('classdef')):
            insert_idx = i + 1
            continue
            
        # If we hit a comment, we are in the help block
        if stripped.startswith('%'):
            in_help_block = True
            insert_idx = i + 1
        else:
            # If we hit an empty line or code AFTER having seen comments, 
            # the help block is over.
            if in_help_block:
                break
            # If we hit code before seeing any comments, insert right here (no help text exists)
            if stripped and not stripped.startswith('%'):
                break

    if VERBOSE: print(f"  [*] Inserting fresh license at line {insert_idx + 1}")

    # Assemble new content
    new_lines = lines[:insert_idx]
    
    # Add spacing for readability
    if insert_idx > 0 and not new_lines[-1].isspace():
        new_lines.append("\n")
    
    new_lines.append(LICENSE_TEXT)
    
    # Add spacing after if code follows
    if insert_idx < len(lines) and not lines[insert_idx].isspace():
        new_lines.append("\n")
        
    new_lines.extend(lines[insert_idx:])

    with open(path, 'w', encoding='utf-8') as f:
        f.writelines(new_lines)
#==============================================================================

#==============================================================================
# 3] Script Execution: Supports targeting a specific file or directory
if __name__ == "__main__":
    if VERBOSE: print("Starting license enforcement check")

    target_path = sys.argv[1] if len(sys.argv) > 1 else os.getcwd()

    if os.path.isfile(target_path):
        process_file(target_path)
    else:
        for root, _, files in os.walk(target_path):
            if any(part.startswith('.') for part in root.split(os.sep)) or "scripts" in root:
                continue
            for file in files:
                process_file(os.path.join(root, file))

    if VERBOSE: print("\nLicense enforcement check complete.")
#==============================================================================
