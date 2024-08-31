read DATE
read TITLE
read CONTENTS
read LINK
read PATTERN
turso db shell spin "INSERT INTO blog VALUES ('$DATE', '$TITLE', '$CONTENTS', '$LINK', '$PATTERN') RETURNING ROWID;"
