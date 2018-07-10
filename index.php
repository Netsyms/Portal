<?php
/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

require_once __DIR__ . "/required.php";

require_once __DIR__ . "/lib/login.php";

// If we're logged in, we don't need to be here.
if ($_SESSION['loggedin'] && !is_empty($_SESSION['password'])) {
    header('Location: home.php');
    die();
// This branch will likely run if the user signed in from a different app.
} else if ($_SESSION['loggedin'] && is_empty($_SESSION['password'])) {
    $alert = $Strings->get("sign in again", false);
    $alerttype = "info";
}

/* Authenticate user */
$username_ok = false;
$multiauth = false;
$change_password = false;
if ($VARS['progress'] == "1") {
    engageRateLimit();
    if (!CAPTCHA_ENABLED || (CAPTCHA_ENABLED && verifyCaptcheck($VARS['captcheck_session_code'], $VARS['captcheck_selected_answer'], CAPTCHA_SERVER . "/api.php"))) {
        $autherror = "";
        if (user_exists($VARS['username'])) {
            $status = get_account_status($VARS['username'], $error);
            switch ($status) {
                case "LOCKED_OR_DISABLED":
                    $alert = $Strings->get("account locked", false);
                    break;
                case "TERMINATED":
                    $alert = $Strings->get("account terminated", false);
                    break;
                case "CHANGE_PASSWORD":
                    $alert = $Strings->get("password expired", false);
                    $alerttype = "info";
                    $_SESSION['username'] = strtolower($VARS['username']);
                    $_SESSION['uid'] = $database->get('accounts', 'uid', ['username' => strtolower($VARS['username'])]);
                    $change_password = true;
                    break;
                case "NORMAL":
                    $username_ok = true;
                    break;
                case "ALERT_ON_ACCESS":
                    $mail_resp = sendLoginAlertEmail($VARS['username']);
                    if (DEBUG) {
                        var_dump($mail_resp);
                    }
                    $username_ok = true;
                    break;
                default:
                    if (!is_empty($error)) {
                        $alert = $error;
                    } else {
                        $alert = $Strings->get("login error", false);
                    }
                    break;
            }
            if ($username_ok) {
                if (authenticate_user($VARS['username'], $VARS['password'], $autherror)) {
                    $_SESSION['passok'] = true; // stop logins using only username and authcode
                    if (userHasTOTP($VARS['username'])) {
                        $multiauth = true;
                        $_SESSION['password'] = $VARS['password'];
                    } else {
                        doLoginUser($VARS['username'], $VARS['password']);
                        insertAuthLog(1, $_SESSION['uid']);
                        header('Location: home.php');
                        die("Logged in, go to home.php");
                    }
                } else {
                    if (!is_empty($autherror)) {
                        $alert = $autherror;
                        insertAuthLog(2, null, "Username: " . $VARS['username']);
                    } else {
                        $alert = $Strings->get("login incorrect", false);
                        insertAuthLog(2, null, "Username: " . $VARS['username']);
                    }
                }
            }
        } else { // User does not exist anywhere
            $alert = $Strings->get("login incorrect", false);
            insertAuthLog(2, null, "Username: " . $VARS['username']);
        }
    } else {
        $alert = $Strings->get("captcha error", false);
        insertAuthLog(8, null, "Username: " . $VARS['username']);
    }
} else if ($VARS['progress'] == "2") {
    engageRateLimit();
    if ($_SESSION['passok'] !== true) {
        // stop logins using only username and authcode
        sendError("Password integrity check failed!");
    }
    if (verifyTOTP($VARS['username'], $VARS['authcode'])) {
        doLoginUser($VARS['username'], $VARS['password']);
        insertAuthLog(1, $_SESSION['uid']);
        header('Location: home.php');
        die("Logged in, go to home.php");
    } else {
        $alert = $Strings->get("2fa incorrect", false);
        insertAuthLog(6, null, "Username: " . $VARS['username']);
    }
} else if ($VARS['progress'] == "chpasswd") {
    engageRateLimit();
    if (!is_empty($_SESSION['username'])) {
        $error = [];
        $result = change_password($VARS['oldpass'], $VARS['newpass'], $VARS['conpass'], $error);
        if ($result === TRUE) {
            $alert = $Strings->get(MESSAGES["password_updated"]["string"], false);
            $alerttype = MESSAGES["password_updated"]["type"];
        }
        switch (count($error)) {
            case 0:
                break;
            case 1:
                $alert = $Strings->get(MESSAGES[$error[0]]["string"], false);
                $alerttype = MESSAGES[$error[0]]["type"];
                break;
            case 2:
                $alert = $Strings->build(MESSAGES[$error[0]]["string"], ["arg" => $error[1]], false);
                $alerttype = MESSAGES[$error[0]]["type"];
                break;
            default:
                $alert = $Strings->get(MESSAGES["generic_op_error"]["string"], false);
                $alerttype = MESSAGES["generic_op_error"]["type"];
        }
    } else {
        session_destroy();
        header('Location: index.php');
        die();
    }
}
?>
<!DOCTYPE html>
<html>
    <head>
        <meta charset="UTF-8">
        <meta http-equiv="X-UA-Compatible" content="IE=edge">
        <meta name="viewport" content="width=device-width, initial-scale=1">

        <title><?php echo SITE_TITLE; ?></title>

        <link href="static/css/bootstrap.min.css" rel="stylesheet">
        <link href="static/css/font-awesome.min.css" rel="stylesheet">
        <link href="static/css/material-color/material-color.min.css" rel="stylesheet">
        <link href="static/css/app.css" rel="stylesheet">
        <?php if (CAPTCHA_ENABLED) { ?>
            <script src="<?php echo CAPTCHA_SERVER ?>/captcheck.dist.js"></script>
        <?php } ?>
    </head>
    <body>
        <div class="container">
            <div class="row">
                <div class="col-xs-12 col-sm-6 col-md-4 col-lg-4 col-sm-offset-3 col-md-offset-4 col-lg-offset-4">
                    <div>
                        <?php
                        if (SHOW_ICON == "both" || SHOW_ICON == "index") {
                            ?>
                            <img class="img-responsive banner-image" src="static/img/logo.svg" />
                        <?php } ?>
                    </div>
                    <div class="panel panel-orange">
                        <div class="panel-heading">
                            <h3 class="panel-title"><?php $Strings->get("sign in"); ?></h3>
                        </div>
                        <div class="panel-body">
                            <form action="" method="POST">
                                <?php
                                if (!is_empty($alert)) {
                                    $alerttype = isset($alerttype) ? $alerttype : "danger";
                                    ?>
                                    <div class="alert alert-<?php echo $alerttype ?>">
                                        <?php
                                        switch ($alerttype) {
                                            case "danger":
                                                $alerticon = "times";
                                                break;
                                            case "warning":
                                                $alerticon = "exclamation-triangle";
                                                break;
                                            case "info":
                                                $alerticon = "info-circle";
                                                break;
                                            case "success":
                                                $alerticon = "check";
                                                break;
                                            default:
                                                $alerticon = "square-o";
                                        }
                                        ?>
                                        <i class="fa fa-fw fa-<?php echo $alerticon ?>"></i> <?php echo $alert ?>
                                    </div>
                                    <?php
                                }

                                if (!$multiauth && !$change_password) {
                                    ?>
                                    <input type="text" class="form-control" name="username" placeholder="<?php $Strings->get("username"); ?>" required="required" autocomplete="off" autocorrect="off" autocapitalize="off" spellcheck="false" autofocus /><br />
                                    <input type="password" class="form-control" name="password" placeholder="<?php $Strings->get("password"); ?>" required="required" autocomplete="off" autocorrect="off" autocapitalize="off" spellcheck="false" /><br />
                                    <?php if (CAPTCHA_ENABLED) { ?>
                                        <div class="captcheck_container" data-stylenonce="<?php echo $SECURE_NONCE; ?>"></div>
                                        <br />
                                    <?php } ?>
                                    <input type="hidden" name="progress" value="1" />
                                    <?php
                                } else if ($multiauth) {
                                    ?>
                                    <div class="alert alert-info">
                                        <?php $Strings->get("2fa prompt"); ?>
                                    </div>
                                    <input type="text" class="form-control" name="authcode" placeholder="<?php $Strings->get("authcode"); ?>" required="required" autocomplete="off" autocorrect="off" autocapitalize="off" spellcheck="false" autofocus /><br />
                                    <input type="hidden" name="progress" value="2" />
                                    <input type="hidden" name="username" value="<?php echo $VARS['username']; ?>" />
                                    <?php
                                } else if ($change_password) {
                                    ?>
                                    <input type="password" class="form-control" name="oldpass" placeholder="Current password" required="required" autocomplete="off" autocorrect="off" autocapitalize="off" spellcheck="false" autofocus /><br />
                                    <input type="password" class="form-control" name="newpass" placeholder="New password" required="required" autocomplete="new-password" autocorrect="off" autocapitalize="off" spellcheck="false" /><br />
                                    <input type="password" class="form-control" name="conpass" placeholder="New password (again)" required="required" autocomplete="new-password" autocorrect="off" autocapitalize="off" spellcheck="false" /><br />
                                    <input type="hidden" name="progress" value="chpasswd" />
                                    <?php
                                }
                                ?>
                                <button type="submit" class="btn btn-primary">
                                    <?php $Strings->get("continue"); ?>
                                </button>
                            </form>
                        </div>
                    </div>
                </div>
            </div>
            <div class="footer">
                <?php echo FOOTER_TEXT; ?><br />
                Copyright &copy; <?php echo date('Y'); ?> <?php echo COPYRIGHT_NAME; ?>
            </div>
        </div>
        <script src="static/js/jquery-3.2.1.min.js"></script>
        <script src="static/js/bootstrap.min.js"></script>
    </body>
</html>