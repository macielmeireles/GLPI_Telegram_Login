<?php
if (file_exists(__DIR__ . '/login_mod.php')) {
    include(__DIR__ . '/login_mod.php');
} else {
    include(__DIR__ . '/login_orig.php');
}
