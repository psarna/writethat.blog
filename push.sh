read DATE
read TITLE
read CONTENTS
read LINK
read PATTERN
echo "INSERT INTO blog VALUES ('$DATE', '$TITLE', '$CONTENTS', '$LINK', '$PATTERN');"
