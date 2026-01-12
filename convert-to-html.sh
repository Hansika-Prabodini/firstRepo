#!/bin/bash

# Convert intro.md to intro.html with basic markdown to HTML conversion

INPUT_FILE="intro.md"
OUTPUT_FILE="intro.html"

# Check if input file exists
if [ ! -f "$INPUT_FILE" ]; then
    echo "Error: $INPUT_FILE not found"
    exit 1
fi

# Clear output file
> "$OUTPUT_FILE"

# Process the markdown file line by line
while IFS= read -r line || [ -n "$line" ]; do
    # Skip empty lines initially, we'll handle them for paragraph spacing
    if [ -z "$line" ]; then
        continue
    fi
    
    # Convert H1 headings (# Heading -> <h1>Heading</h1>)
    if [[ "$line" =~ ^#[[:space:]](.+)$ ]]; then
        heading="${BASH_REMATCH[1]}"
        echo "<h1>$heading</h1>" >> "$OUTPUT_FILE"
    else
        # Process inline formatting for paragraph text
        processed_line="$line"
        
        # Convert bold: **text** -> <strong>text</strong>
        # Using sed to handle multiple occurrences
        processed_line=$(echo "$processed_line" | sed -E 's/\*\*([^*]+)\*\*/<strong>\1<\/strong>/g')
        
        # Convert italic: *text* -> <em>text</em>
        # Need to be careful not to match ** that's already been processed
        # This regex looks for * that isn't preceded or followed by another *
        processed_line=$(echo "$processed_line" | sed -E 's/(^|[^*])\*([^*]+)\*($|[^*])/\1<em>\2<\/em>\3/g')
        
        # Wrap in paragraph tags
        echo "<p>$processed_line</p>" >> "$OUTPUT_FILE"
    fi
done < "$INPUT_FILE"

echo "Conversion complete: $OUTPUT_FILE created"
