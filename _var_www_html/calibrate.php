<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
<title>Calibrate</title>
</head>
<body>

<?php
system('(sudo /home/pi/calibrate.py >/dev/null 2>&1 &)');
echo "Calibrated !";
?>
<br />
<a href="javascript:void(0)" onclick="window.open('', '_self', ''); window.close()">Close window</a>

</body>
</html>
