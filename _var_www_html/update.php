<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
<title>Update</title>
</head>
<body>

<?php

if (!isset($_POST["Update"])) {
?>
<p>Clicking on the update button will launch the update procedure.<br />
The TenboReader will check if updates are available and if there are install them.<br />
The TenboReader needs to be connected to the Internet.<br />
This may take a few minutes, please leave this page open.<br />
<form method="post" action="update.php">
<input type="submit" name="Update" value="Update">
</form></p>
<?php
} else {
?>
<p>Update procedure completed!</p>
<p>System log:<br />
<textarea rows="7" cols="30">
<?php
echo system('(sudo /home/pi/systemupdate/systemupdate.sh &)');
echo "</textarea></p>";
}
?>
<br />
<a href="javascript:void(0)" onclick="window.open('', '_self', ''); window.close()">Close window</a>

</body>
</html>
