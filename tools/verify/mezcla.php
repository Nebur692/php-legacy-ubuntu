<?php
// EN: deterministic page: the same PHP must print exactly the same output. Runs inside the web SAPI.
// ES: página determinista: el mismo PHP tiene que dar exactamente la misma salida. Corre dentro del SAPI web.
date_default_timezone_set('Europe/Madrid');
header('Content-Type: text/plain; charset=utf-8');
session_start();
$_SESSION['n'] = isset($_SESSION['n']) ? $_SESSION['n'] + 1 : 1;
$t = 1762351200; // instante fijo
$out = array();
$out['sapi'] = PHP_SAPI;
$out['fecha'] = date('D, d M Y H:i:s T', $t) . ' | ' . gmdate(DATE_RFC2822, $t) . ' | ' . date('W-z-L-N', $t);
$out['strtotime'] = strtotime('2026-11-05 13:00:00 +1 week');
$out['numeros'] = number_format(1234567.891, 2, ',', '.') . ' ' . sprintf('%.15g %e %05.1f %x %b', 0.1 + 0.2, 12345.678, 3.14159, 255, 10) . ' ' . (7 / 3) . ' ' . intdiv_or(17, 5) . ' ' . round(2.5) . ' ' . round(-2.5) . ' ' . PHP_INT_MAX;
$out['cadenas'] = ucwords('hola mundo') . ' ' . str_pad('x', 5, '-', STR_PAD_BOTH) . ' ' . wordwrap('a b c d e f', 3, '|', true) . ' ' . strrev('áb') . ' ' . substr_count('banana', 'an') . ' ' . levenshtein('casa', 'cosa') . ' ' . similar_text('World', 'Word') . ' ' . soundex('Robert') . ' ' . metaphone('Thompson');
$out['mbstring'] = mb_strtoupper('ñandú ÁÉÍ', 'UTF-8') . ' ' . mb_strlen('añoß€', 'UTF-8') . ' ' . mb_substr('Español', 2, 3, 'UTF-8') . ' ' . bin2hex(mb_convert_encoding('café', 'ISO-8859-1', 'UTF-8'));
$out['iconv'] = bin2hex(iconv('UTF-8', 'ISO-8859-15//TRANSLIT', 'precio 5€ ñ'));
$out['preg'] = preg_replace('/(\w+) (\d+)/u', '$2-$1', 'abril 15, mayo 3') . ' ' . preg_match_all('/\p{Lu}/u', 'ÁrbOl Ñu', $m) . ' ' . implode(',', preg_split('/[\s,]+/', 'a, b  c,d'));
$out['json'] = json_encode(array('a' => 1.0, 'b' => 0.1, 'c' => 'ñ€', 'd' => array(1, 2), 'e' => null, 'f' => 1e20, 'g' => '</tag>')) . ' ' . var_export(json_decode('{"x":{"y":[1,2,{"z":true}]}}', true), true);
$out['serialize'] = serialize(array('x' => 1.5, 'y' => 'ñ', 'z' => array(true, null))) . ' ' . md5(serialize(unserialize(serialize(new ArrayObject(array(1, 2, 3))))));
$out['hash'] = md5('abc') . ' ' . sha1('abc') . ' ' . hash('sha256', 'abc') . ' ' . hash('crc32b', 'abc') . ' ' . crc32('abc') . ' ' . base64_encode(hash_hmac('sha512', 'm', 'k', true)) . ' ' . implode(',', array_slice(hash_algos(), 0, 50));
$out['openssl'] = function_exists('openssl_encrypt') ? openssl_encrypt('secreto', 'aes-256-cbc', str_repeat('k', 32), 0, str_repeat('i', 16)) . ' ' . bin2hex(openssl_digest('abc', 'sha384', true)) : 'sin openssl';
$h = password_hash('clave', PASSWORD_BCRYPT, array('cost' => 4));
$out['password'] = var_export(password_verify('clave', $h), true) . ' ' . var_export(password_verify('otra', $h), true) . ' ' . substr($h, 0, 7) . ' ' . crypt('clave', '$2y$04$abcdefghijklmnopqrstuu');
$x = simplexml_load_string('<r><a id="1">uno</a><a id="2">dos &amp; tres</a></r>');
$d = new DOMDocument(); $d->loadXML('<r><b>ñ</b></r>'); $xp = new DOMXPath($d);
$out['xml'] = (string) $x->a[1] . ' ' . (string) $x->a[0]['id'] . ' ' . $xp->query('//b')->item(0)->textContent . ' ' . trim($d->saveXML());
$out['arrays'] = implode(',', array_map(function ($v) { return $v * 2; }, array_filter(range(1, 10), function ($v) { return $v % 3; }))) . ' ' . json_encode(array_count_values(array('a', 'b', 'a'))) . ' ' . json_encode(array_merge_recursive(array('a' => array(1)), array('a' => array(2))));
$s = array(3, '10', 1.5, 'b', 'a', true); sort($s); $out['sort'] = json_encode($s);
$out['matematicas'] = sqrt(2) . ' ' . pow(2, 0.5) . ' ' . fmod(10, 3.3) . ' ' . base_convert('ff', 16, 2) . ' ' . bindec('1111') . ' ' . log(M_E) . ' ' . sin(M_PI / 6) . ' ' . floor(-1.5) . ' ' . (0.1 + 0.7) * 10 . ' ' . (int) ((0.1 + 0.7) * 10);
mt_srand(42); srand(42); $out['azar_con_semilla'] = mt_rand() . ' ' . mt_rand(1, 100) . ' ' . rand(1, 100);
$out['url'] = urlencode('a b&ñ') . ' ' . rawurlencode('a b&ñ') . ' ' . http_build_query(array('x' => array(1, 2), 'y' => 'ñ')) . ' ' . json_encode(parse_url('https://u:p@h.es:8080/r?q=1#f'));
$out['html'] = htmlspecialchars('<a href="x">\'ñ\'</a>') . ' ' . html_entity_decode('&eacute;&amp;&euro;', ENT_QUOTES, 'UTF-8') . ' ' . strip_tags('<b>negrita</b> <i>x</i>') . ' ' . nl2br("a\nb");
$out['sesion'] = 'n=' . $_SESSION['n'] . ' save_handler=' . ini_get('session.save_handler');
if (function_exists('imagecreatetruecolor')) {
  $im = imagecreatetruecolor(40, 30); $c = imagecolorallocate($im, 200, 50, 10);
  imagefilledrectangle($im, 5, 5, 30, 20, $c); imageline($im, 0, 0, 39, 29, imagecolorallocate($im, 0, 0, 255));
  imagestring($im, 2, 2, 2, 'Hi', imagecolorallocate($im, 255, 255, 255));
  $r = array();
  foreach (array('png', 'gif', 'jpeg') as $f) { ob_start(); call_user_func('image' . $f, $im); $b = ob_get_clean(); $r[] = $f . ':' . strlen($b) . ':' . md5($b); $i2 = imagecreatefromstring($b); $r[] = $f . '-leida:' . ($i2 ? imagesx($i2) . 'x' . imagesy($i2) : 'NO'); }
  $out['gd'] = implode(' ', $r);
} else { $out['gd'] = 'sin gd'; }
if (class_exists('ZipArchive')) { $z = new ZipArchive(); $f = tempnam(sys_get_temp_dir(), 'z'); $z->open($f, ZipArchive::OVERWRITE); $z->addFromString('a.txt', str_repeat('ñ', 100)); $z->close(); $z->open($f); $out['zip'] = $z->numFiles . ' ' . md5($z->getFromName('a.txt')); $z->close(); unlink($f); }
$out['gz'] = md5(gzuncompress(gzcompress(str_repeat('abc', 1000)))) . ' ' . strlen(gzencode('x', 9));
if (function_exists('bcadd')) { $out['bcmath'] = bcadd('1.234', '5.678', 3) . ' ' . bcdiv('1', '3', 20) . ' ' . bcpow('2', '100'); }
if (class_exists('NumberFormatter')) { $nf = new NumberFormatter('es_ES', NumberFormatter::CURRENCY); $out['intl'] = $nf->formatCurrency(1234.5, 'EUR') . ' ' . (class_exists('Collator') ? implode(',', call_user_func(function () { $a = array('ñu', 'nube', 'oso'); $c = new Collator('es_ES'); $c->sort($a); return $a; })) : ''); }
if (function_exists('mysqli_connect')) { $db = mysqli_connect('127.0.0.1', 'php', 'php', 'test'); $q = mysqli_query($db, 'SELECT nombre, saldo, alta FROM clientes ORDER BY id LIMIT 5'); $rows = array(); while ($row = mysqli_fetch_assoc($q)) { $rows[] = $row; } $out['mysqli'] = json_encode($rows); $st = mysqli_prepare($db, 'SELECT COUNT(*) FROM clientes WHERE saldo > ?'); $v = 100.5; mysqli_stmt_bind_param($st, 'd', $v); mysqli_stmt_execute($st); mysqli_stmt_bind_result($st, $cnt); mysqli_stmt_fetch($st); $out['mysqli'] .= ' prep=' . $cnt; }
if (class_exists('PDO')) { $p = new PDO('mysql:host=127.0.0.1;dbname=test;charset=utf8', 'php', 'php', array(PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION)); $s = $p->prepare('SELECT id, nombre FROM clientes WHERE nombre LIKE ? ORDER BY id'); $s->execute(array('%ñ%')); $out['pdo'] = json_encode($s->fetchAll(PDO::FETCH_ASSOC)); }
function intdiv_or($a, $b) { return (int) ($a / $b); }
foreach ($out as $k => $v) { echo $k, ': ', $v, "\n"; }
