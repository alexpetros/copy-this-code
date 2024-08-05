<?php
[
  'sequences' => $sequences,
  'info' => $info
] = $_POST;

$issue_date = new DateTime($issue_date_str);
$txt = "
$sequences

$info
-------------^^^----
";

file_put_contents('/var/www/submissions.txt', $txt.PHP_EOL, FILE_APPEND | LOCK_EX);

header("Location: /switch-emoji/success");
http_response_code(303);
die();
?>


