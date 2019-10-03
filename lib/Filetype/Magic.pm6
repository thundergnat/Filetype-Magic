use v6;
unit module Filetype::Magic:ver<0.0.1>:auth<github:thundergnat>;

use NativeCall;

enum MAGIC_flags is export (
    MAGIC_NONE              => 0x000000, # No flags
    MAGIC_DEBUG             => 0x000001, # Turn on debugging
    MAGIC_COMPRESS          => 0x000004, # Check inside compressed files
    MAGIC_DEVICES           => 0x000008, # Look at the contents of devices
    MAGIC_MIME_TYPE         => 0x000010, # Return the MIME type
    MAGIC_SYMLINK           => 0x000002, # Follow symlinks
    MAGIC_CONTINUE          => 0x000020, # Return all matches
    MAGIC_CHECK             => 0x000040, # Print warnings to stderr
    MAGIC_PRESERVE_ATIME    => 0x000080, # Restore access time on exit
    MAGIC_RAW               => 0x000100, # Don't translate unprintable chars
    MAGIC_ERROR             => 0x000200, # Handle ENOENT etc as real errors
    MAGIC_MIME_ENCODING     => 0x000400, # Return the MIME encoding
    MAGIC_MIME              => 0x000410, # (MAGIC_MIME_TYPE|MAGIC_MIME_ENCODING)
    MAGIC_APPLE             => 0x000800, # Return the Apple creator and type

    MAGIC_NO_CHECK_COMPRESS => 0x001000, # Don't check for compressed files
    MAGIC_NO_CHECK_TAR      => 0x002000, # Don't check for tar files
    MAGIC_NO_CHECK_SOFT     => 0x004000, # Don't check magic entries
    MAGIC_NO_CHECK_APPTYPE  => 0x008000, # Don't check application
    MAGIC_NO_CHECK_ELF      => 0x010000, # Don't check for elf details
    MAGIC_NO_CHECK_TEXT     => 0x020000, # Don't check for text files
    MAGIC_NO_CHECK_CDF      => 0x040000, # Don't check for cdf files
    MAGIC_NO_CHECK_TOKENS   => 0x100000, # Don't check tokens
    MAGIC_NO_CHECK_ENCODING => 0x200000, # Don't check text encodings
);


class Magic is export {
    has Pointer $!magic-cookie = Nil;
    has $.database             = '';

    method TWEAK (:$magicfile = Nil, int32 :$flags = 0) {
        $!magic-cookie = self.magic-init($flags);
        $!database     = self.magic-database($magicfile, $flags);
        self.magic-load($!magic-cookie, $!database);
    }

    # Locate the magic database file, Nil for default database
    method magic-database ($magicfile = Nil, int32 $flags = 0) {
        sub magic_getpath(str $magicfile, int32 $flags) returns Str is native('magic') { * }
        magic_getpath($magicfile, $flags);
    }

    # Initialize the file-magic instance, allocate a data structure to hold
    # information and return a pointer to it.
    method magic-init (int32 $flags = 0) {
        sub magic_open(int32 $flags) returns Pointer is native('magic') { * }
        magic_open($flags) or self.magic-error;
    }

    # Load the database file into a data structure, return 0 on succes, -1 on failure
    method magic-load (Pointer $ms, str $magicfile) {
        sub magic_load(Pointer $ms, str $magicfile) returns int32 is native('magic') { * }
        magic_load($ms, $magicfile);
    }

    # Pass any errors back
    method magic-error () {
        sub magic_error(Pointer $ms) returns Str is native('magic') { * }
        magic_error($!magic-cookie);
    }

    # Allows modification of parameters after initialization
    method set-flags (int32 $flags = 0) {
        sub magic_setflags(Pointer $ms, int32 $flags) returns int32 is native('magic') { * }
        magic_setflags($!magic-cookie, $flags) or self.magic-error;
    }

    # Try to detect file type given a file path/name
    multi method type (Str $filename) {
        sub magic_file(Pointer $ms, str $fn ) returns Str is native('magic') { * }
        magic_file($!magic-cookie, $filename);
    }

    # Try to detect file type given an open file handle
    multi method type (IO::Handle $handle) {
        sub magic_descriptor(Pointer $ms, int32 $fh ) returns Str is native('magic') { * }
        magic_descriptor($!magic-cookie, $handle.native-descriptor);
    }

    # Try to detect file type given a string buffer. Needs to be encoded into a buf
    # to pass in to C function.
    multi method type (Buf $buf) {
        sub magic_buffer(Pointer $ms, str $str, int32 $size) returns Str is native('magic') { * }
        magic_buffer($!magic-cookie, $buf.decode('UTF8'), $buf.elems);
    }

    # Return the current version. First digit is major version number, rest are minor
    method version() {
        sub magic_version() returns int32 is native('magic') { * }
        magic_version()
    }
}

=begin pod
=head1 NAME
Filetype::Magic

Try to guess a files type using the libmagic heuristic library.

=head1 SYNOPSIS

=begin code
     use Filetype::Magic;

     my $magic = Magic.new;

     say $magic.type: '/path/to/file.name';
=end code

=head1 DESCRIPTION

Provides a Perl 6 interface to the libmagic shared library used by the 'file'
utility to guess file types, installed by default on most BSDs and Linuxs.
Libraries available for OSX and Windows as well.

Needs to have the shared library: libmagic-dev installed. May install the
shared library directly or install the file-dev package which will include the
shared file.

=begin table
Platform 	          |  Install Method
======================================================
Debian derivatives    |  [sudo] apt-get install libmagic-dev
FreeBSD               |  [sudo] pkg install libmagic-dev
Fedora                |  [sudo] dnf install libmagic-dev
OSX                   |  [sudo] brew install libmagic
OpenSUSE              |  [sudo] zypper install libmagic-dev
Red Hat               |  [sudo] yum install file-devel
Source Code on GitHub |  https://github.com/file/file
=end table

There is a series of flags which control the behavior of the search:

=begin table
Flag                     |  hex value  |  meaning
========================================================================
MAGIC_NONE               |  0x000000,  |  No flags
MAGIC_DEBUG              |  0x000001,  |  Turn on debugging
MAGIC_COMPRESS           |  0x000004,  |  Check inside compressed files
MAGIC_DEVICES            |  0x000008,  |  Look at the contents of devices
MAGIC_MIME_TYPE          |  0x000010,  |  Return the MIME type
MAGIC_SYMLINK            |  0x000002,  |   Follow symlinks
MAGIC_CONTINUE           |  0x000020,  |  Return all matches
MAGIC_CHECK              |  0x000040,  |  Print warnings to stderr
MAGIC_PRESERVE_ATIME     |  0x000080,  |  Restore access time on exit
MAGIC_RAW                |  0x000100,  |  Don't translate unprintable chars
MAGIC_ERROR              |  0x000200,  |  Handle ENOENT etc as real errors
MAGIC_MIME_ENCODING      |  0x000400,  |  Return the MIME encoding
MAGIC_MIME               |  0x000410,  |  (MAGIC_MIME_TYPE|MAGIC_MIME_ENCODING)
MAGIC_APPLE              |  0x000800,  |  Return the Apple creator and type
MAGIC_NO_CHECK_COMPRESS  |  0x001000,  |  Don't check for compressed files
MAGIC_NO_CHECK_TAR       |  0x002000,  |  Don't check for tar files
MAGIC_NO_CHECK_SOFT      |  0x004000,  |  Don't check magic entries
MAGIC_NO_CHECK_APPTYPE   |  0x008000,  |  Don't check application
MAGIC_NO_CHECK_ELF       |  0x010000,  |  Don't check for elf details
MAGIC_NO_CHECK_TEXT      |  0x020000,  |  Don't check for text files
MAGIC_NO_CHECK_CDF       |  0x040000,  |  Don't check for cdf files
MAGIC_NO_CHECK_TOKENS    |  0x100000,  |  Don't check tokens
MAGIC_NO_CHECK_ENCODING  |  0x200000,  |  Don't check text encodings
=end table

The flags may be set during construction by passing a :flag(WHATEVER) value in
to the C<.new( )> method, or may be adjusted later using the C<.set-flags( )> method.


=begin code
method set-flags(int32 $flags = 0)
=end code
Allows modification of parameters after initialization.

=begin code
method type(Str $filename)
   or
method type(IO::Handle $handle)
   or
method type(Buf $buffer)
=end code
Try to detect file type of a given a file path/name or open file handle or
string buffer.

=begin code
method version()
=end code
Return the current version. First digit is major version number, rest are minor.

--

There are several semi-private methods which mostly deal with initialization and
setup. There is nothing preventing you from accessing them, they are publically
available, but most people won't ever need to use them.

=begin code
method magic-database( str $magic-database, int32 $flags )
=end code
Location of the magic database file, pass Nil for default database. Pass any
flags C<or>ed together to adjust behavior.

=begin code
method magic-init(int32 $flags = 0)
=end code
Initialize the file-magic instance, allocate a data structure to hold
information and return a pointer to it. Pointer is stored in the class as
$!magic-cookie.

=begin code
method magic-load(Pointer $magic-struct, str $magicfile)
=end code
Load the database file into the data structure.

=begin code
method magic-error()
=end code
Pass any errors back up to the calling code.

--

A few methods dealing with generating, checking and compiling magic database
files have yet to be implemented.


=head1 AUTHOR

2019 Steve Schulze aka thundergnat

This package is free software and is provided "as is" without express or implied
warranty.  You can redistribute it and/or modify it under the same terms as Perl
itself.

=head1 LICENSE

Licensed under The Artistic 2.0; see LICENSE.


=end pod
