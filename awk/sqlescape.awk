# I use this little function to make SQL-compatible insert statements
# Usually when I'm converting .tsv files to INSERTs
# SQL has pretty simple rules: bare numbers, single quoted strings with '' to escape single quoets
function sql (item) {
  # If the string is only numbers, omit the quotes
  if (item ~ /^[0-9]+$/) return item
  # If it's an empty string, make a it a NULL
  if (item == "") return "NULL"
  # Otherwise escape the single quotes (with '') and then surround the result with single quotes
  gsub(/'/, "''", item)
  return "'"item"'"
}
