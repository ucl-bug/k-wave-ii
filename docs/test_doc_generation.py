from pathlib import Path
from os.path import isfile

n_html = len([x for x in Path('./docs/helpfiles').rglob('*.html')])
n_md = len([x for x in Path('./docs/helpfilesweb').rglob('*.md') if ('SUMMARY' not in str(x)) ])

print(n_html,n_md)
exit (n_html != n_md)
