$in_format = shift;
$out_format = shift;
$start = shift;
$end = shift;
$crop_w = int(shift); # % of size
$crop_h = int(shift); # % of size
$resize_w = int(shift);

$count = $end - $start + 1;

sub filename {
	my $i = shift;
	sprintf($in_format, $start+$i);
}

$first = filename(0);
$w = int(`identify -format "%[w]" $first`);
$h = int(`identify -format "%[h]" $first`);
$x_end = $w * (1 - ($crop_w / 100.0));

for($i=0;$i<$count;$i++) {
	$in = filename($i);
	$out = sprintf($out_format, $i);
	$x = int($x_end * $i/$count);
	print "convert $in -crop $crop_w%x$crop_h%+$x+0 -resize $resize_w $out\n";
}

$time = scalar(localtime);
$time =~ s/ /_/g;
$time =~ s/:/_/g;
#print "rm small/a0000367.jpg\n";
#print "rm small/a0000368.jpg\n";
$fadeout_duration = 30;
$fadeout_start = $count - $fadeout_duration;
print "ffmpeg -i 'small/a%*.jpg' -r 30 -b 50M  -vf fade=out:$fadeout_start:$fadeout_duration small/timelapse_$time.flv\n";
#twitter upload
print "ffmpeg -i 'small/a%*.jpg' -r 30 -b 10M -vf \"scale=1280:-1, fade=out:$fadeout_start:$fadeout_duration\" small/timelapse_$time.twtr.flv\n";


__END__
連番ファイルからタイムラプス動画を作るスクリプト
Requires: ImageMagick, ffmpeg

Example:
# In seq photos directory:
mkdir small
perl ~/Dropbox/lab/Timelapse/gen_sh.pl G%07d.JPG small/a%07d.jpg 18488 19170 75 75 1920 > a.sh
sh -x a.sh
# Example output movie path: small/timelapse_Fri_Sep_23_22_32_09_2016.flv
