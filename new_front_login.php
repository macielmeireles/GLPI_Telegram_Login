<?php
if (file_exists(__DIR__ . '/custom_front_login_with_telegram.php')) {
    include(__DIR__ . '/custom_front_login_with_telegram.php');
} else {
    include(__DIR__ . '/login_bak_local.php');
}
