use Test;
use Filetype::Magic;

plan 15;

my $magic = Magic.new();

isa-ok( $magic, 'Filetype::Magic::Magic', 'Can create instance' );

isa-ok( $magic.version, 'Int', 'Version returns a sane value' );

is( $magic.type( Buf.new: "#!/usr/bin/perl\nprint 'Hi';".encode('UTF8') ),
   'Perl script text executable',
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
  'camelia.zip', 'Zip archive data, at least v1.0 to extract',
  'camelia.svg', 'SVG Scalable Vector Graphics image',
  'camelia.ico', 'MS Windows icon resource - 1 icon, 32x32, 32 bits/pixel',
  'camelia.png', 'PNG image data, 32 x 32, 8-bit/color RGBA, non-interlaced'
  -> $file, $text {
      is($magic.type( "$dir/test-files/$file" ), $text, "Detects type: $text");
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

is( $magic.get-flags, 16, 'Gets set flags correctly');

$magic.set-flags(MAGIC_MIME_TYPE +| MAGIC_MIME_ENCODING);

is( $magic.get-flags, 1040, 'Gets multiple set flags correctly');

done-testing;
