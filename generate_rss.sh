#!/bin/bash

TURSO_URL="https://spin-psarna.turso.io"
READONLY_TOKEN="eyJhbGciOiJFZERTQSIsInR5cCI6IkpXVCJ9.eyJhIjoicm8iLCJpYXQiOjE2ODE4MjkxNDMsImlkIjoiNzIyY2IyYTEtY2M3MC0xMWVkLWFkM2MtOGVhNWEwNjcyYmM2In0.T55UgAMs9vP2zMI_AhOiD2AONj_bsnDNRjZiBBWUb2gKU5MEjJoW8uHbtMGqpJ0312SULpsWTWdEJ886oSjGCQ"

escape_xml() {
    echo "$1" | sed 's/&/\&amp;/g; s/</\&lt;/g; s/>/\&gt;/g; s/"/\&quot;/g; s/'"'"'/\&#039;/g'
}

format_date() {
    date -d "$1" -R 2>/dev/null || date -j -f "%Y-%m-%d" "$1" "+%a, %d %b %Y %H:%M:%S %z" 2>/dev/null
}

echo "Fetching blog data from Turso..."

response=$(curl -s -X POST "$TURSO_URL" \
    -H "Authorization: Bearer $READONLY_TOKEN" \
    -H "Content-Type: application/json" \
    -d '{"statements":[{"q":"SELECT date, title, content, link, pattern FROM blog ORDER BY date DESC LIMIT 50"}]}')

if [ $? -ne 0 ]; then
    echo "Error: Failed to fetch data from Turso"
    exit 1
fi

cat > rss.xml << 'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<rss version="2.0">
  <channel>
    <title>Write that blog!</title>
    <link>https://writethat.blog</link>
    <description>Monthly dissection of engineering blog posts. Take a hint, get inspired, and write your own already.</description>
    <language>en-us</language>
    <lastBuildDate>BUILD_DATE</lastBuildDate>
    <generator>Bash RSS Generator</generator>
EOF

sed -i "s/BUILD_DATE/$(date -R)/" rss.xml

echo "$response" | jq -r '.[] | .results | .rows[] | @tsv' | while IFS=$'\t' read -r date title content link pattern; do
    escaped_title=$(escape_xml "$title")
    escaped_content=$(escape_xml "$content")
    escaped_link=$(escape_xml "${link:-https://writethat.blog}")
    escaped_pattern=$(escape_xml "${pattern:-none}")
    formatted_date=$(format_date "$date")
    guid=$(escape_xml "${link:-https://writethat.blog/$date/$title}")
    
    cat >> rss.xml << EOF
    <item>
      <title>$escaped_title</title>
      <link>$escaped_link</link>
      <description>$escaped_content</description>
      <pubDate>$formatted_date</pubDate>
      <category>$escaped_pattern</category>
      <guid>$guid</guid>
    </item>
EOF
done

echo "  </channel>" >> rss.xml
echo "</rss>" >> rss.xml

echo "RSS feed generated: rss.xml"