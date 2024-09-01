<?php
$uri = $_SERVER["REQUEST_URI"];
$path =  parse_url($_SERVER['REQUEST_URI'], PHP_URL_PATH);

if ($uri == "/") {
  return false;
} else if (file_exists("./public/$path")) {
  return false;
} else {
  http_response_code(404);
  echo '<h1>404 NOT FOUND</h1>';
}

?>


