#!/bin/bash

n_html=`find docs/helpfiles/ -name "*.html" | wc -l`
if [ $n_html -eq 0 ]; then
    echo "No html help files were generated"
    return 1
fi

n_md=`find docs/helpfilesweb/ -name "*.md" | grep -v SUMMARY | wc -l`
if [ $n_md -eq 0 ]; then
    echo "No md documentation files were generated"
    return 1
fi

if [ $n_html -ne $n_md ]; then
    echo "Number of html and md help files generated are not equal:" $n_html "vs" $n_md
    return 1
fi

echo $n_html "html files generated," $n_md "md files generated"
