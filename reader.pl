#!/usr/bin/env perl

use 5.14.2;
use warnings;

use WWW::Mechanize;
use HTTP::Cookies;
use Array::LineReader;



my $url = "https://accounts.google.com/ServiceLogin?service=mail&passi
+ve=true&rm=false&continue=http://mail.google.com/mail/&scc=1&ltmpl=de
+fault&ltmplcache=2";
my $username = 'USERNAME';
my $password = 'PASSWORD';
my $mech = WWW::Mechanize->new();
$mech->cookie_jar(HTTP::Cookies->new());
$mech->get($url);
$mech->form_id('gaia_loginform');
$mech->field("Email", $username);
$mech->field("Passwd", $password);
$mech->click;

my @feedurls;
tie @feedurls, 'Array::LineReader', '/home/rpoliveira/SCRIPTS/Reader/feedurls.txt';
my $numberoffeeds = @feedurls;

my $i = 0;
my $j = 0;
#my $j = 290;

#my $newurl = $feedurls[$i];
#$newurl =~ s/\R//g;
#$newurl .= "&c=COnmmuXRrKoC";


for( $i = 0; $i < $numberoffeeds; $i++)
{
  $mech->get($feedurls[$i]);
  #$mech->get($newurl);

  my $output_page = $mech->content();
  my $pos = rindex($feedurls[$i],"atom/feed%2F");
  my $pos2 = rindex($feedurls[$i],"?");
  my $feedname = substr($feedurls[$i],$pos+12,$pos2-$pos-12);
  $feedname =~ s/\R//g;

  my $outfile = "/home/rpoliveira/SCRIPTS/Reader/Blogs/" . $feedname . '-'. $j . '.xml';
  print "\n$outfile\n";

  open(OUTFILE, ">$outfile");
  binmode(OUTFILE, ":utf8");
  print OUTFILE "$output_page";
  close(OUTFILE);

  sleep(3);

  $pos = index($output_page,"continuation>");

  while  ($pos > 0)
  {
    $j++;

    my $continuation_code = substr($output_page,$pos+13,20);
    my $pos2 = index($continuation_code,"<");
    $continuation_code = substr($continuation_code,0,$pos2);
    #print $output_page;
    print "\n" . $continuation_code;

    my $nexturl = $feedurls[$i]; 
    $nexturl =~ s/\R//g;
    $nexturl .= '&c=' . $continuation_code;
    $mech->get($nexturl);
    $output_page = $mech->content();

    $outfile = "/home/rpoliveira/SCRIPTS/Reader/Blogs/" . $feedname . '-'. $j . '.xml';

    open(OUTFILE, ">$outfile");
    binmode(OUTFILE, ":utf8");
    print OUTFILE "$output_page";
    close(OUTFILE);

    sleep(3);

    $pos = index($output_page,"continuation>");

  }
 
  $j=0;
}
