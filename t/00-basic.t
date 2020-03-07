use Test;
use Filetype::Magic;

my $magic = Magic.new();

isa-ok( $magic, 'Filetype::Magic::Magic', 'Can create instance' );

isa-ok( $magic.version, 'Int', 'Version returns a sane value' );

is( lc($magic.type( Buf.new: "#!/usr/bin/perl\nprint 'Hi';".encode('UTF8') ) ~~ m:i/'Perl script'/),
   'perl script',
   'Detects a perl string buffer ok'
);

is( $magic.type( Buf.new: "#!/usr/bin/perl6\nprint 'Hi';".encode('UTF8') ),
   'a /usr/bin/perl6 script, ASCII text executable',
   'Detects a perl6 string buffer (sort-of) ok'
);

my $fh = $*PROGRAM-NAME.IO.open;

is( $magic.type( $fh ), 'ASCII text', 'Detects a file handle ok' ) ;

$fh.close;

my $dir = $*PROGRAM-NAME.IO.dirname;

for
  'camelia.zip', 'zip archive data',
  'camelia.svg', 'svg scalable vector graphics',
  'camelia.ico', 'ms windows icon',
  'camelia.png', 'png image'
  -> $file, $text {
      is-deeply( lc($magic.type( "$dir/test-files/$file" )).contains($text), True, "Detects type: $text");
}

$magic.set-flags(MAGIC_MIME_TYPE);

for
  'camelia.zip', 'application/zip',
  'camelia.svg', 'image/svg+xml',
  'camelia.ico', 'image/x-icon',
  'camelia.png', 'image/png'
  -> $file, $text {
      is($magic.type( "$dir/test-files/$file" ), $text, "Detects MIME type: $text");
}

if $magic.version >= 532 { # Only available in 5.32 or later

    is( $magic.get-flags, 16, 'Gets set flags correctly');

    $magic.set-flags(MAGIC_MIME_TYPE +| MAGIC_MIME_ENCODING);

    is( $magic.get-flags, 1040, 'Gets multiple set flags correctly');

}

done-testing;
