from pathlib import Path
from os.path import isfile

n_html = len([x for x in Path('./docs/helpfiles').rglob('*.html')])
if n_html == 0:
    print("No html help files were generated")
    exit(1)

n_md = len([x for x in Path('./docs/helpfilesweb').rglob('*.md') if ('SUMMARY' not in str(x)) ])
if n_md == 0:
    print("No md documentation files were generated")
    exit(1)

if n_html != n_md:
    print("Number of html and md help files generated are not equal:", n_html, "vs", n_md)
    exit(1)

print(n_html, "html files generated,", n_md, "md files generated")
