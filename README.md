NAME Filetype::Magic
====================

Try to guess a files type using the libmagic heuristic library.

SYNOPSIS
========

         use Filetype::Magic;

         my $magic = Magic.new;

         say $magic.typr: '/path/to/file.name';

DESCRIPTION
===========

Provides a Perl 6 interface to the libmagic shared library used by the 'file' utility to guess file types, installed by default on most BSDs and Linuxs. Libraries available for OSX and Windows as well.

Needs to have the shared library: libmagic-dev installed. May install the shared library directly or install the file-dev package which will include the shared file.

<table class="pod-table">
<thead><tr>
<th>Platform</th> <th>Install Method</th>
</tr></thead>
<tbody>
<tr> <td>Debian derivatives</td> <td>[sudo] apt-get install libmagic-dev</td> </tr> <tr> <td>FreeBSD</td> <td>[sudo] pkg install libmagic-dev</td> </tr> <tr> <td>Fedora</td> <td>[sudo] dnf install libmagic-dev</td> </tr> <tr> <td>OSX</td> <td>[sudo] brew install libmagic</td> </tr> <tr> <td>OpenSUSE</td> <td>[sudo] zypper install libmagic-dev</td> </tr> <tr> <td>Red Hat</td> <td>[sudo] yum install file-devel</td> </tr> <tr> <td>Source Code on GitHub</td> <td>https://github.com/file/file</td> </tr>
</tbody>
</table>

There is a series of flags which control the behavior of the search:

<table class="pod-table">
<thead><tr>
<th>Flag</th> <th>hex value</th> <th>meaning</th>
</tr></thead>
<tbody>
<tr> <td>MAGIC_NONE</td> <td>0x000000,</td> <td>No flags</td> </tr> <tr> <td>MAGIC_DEBUG</td> <td>0x000001,</td> <td>Turn on debugging</td> </tr> <tr> <td>MAGIC_COMPRESS</td> <td>0x000004,</td> <td>Check inside compressed files</td> </tr> <tr> <td>MAGIC_DEVICES</td> <td>0x000008,</td> <td>Look at the contents of devices</td> </tr> <tr> <td>MAGIC_MIME_TYPE</td> <td>0x000010,</td> <td>Return the MIME type</td> </tr> <tr> <td>MAGIC_SYMLINK</td> <td>0x000002,</td> <td>Follow symlinks</td> </tr> <tr> <td>MAGIC_CONTINUE</td> <td>0x000020,</td> <td>Return all matches</td> </tr> <tr> <td>MAGIC_CHECK</td> <td>0x000040,</td> <td>Print warnings to stderr</td> </tr> <tr> <td>MAGIC_PRESERVE_ATIME</td> <td>0x000080,</td> <td>Restore access time on exit</td> </tr> <tr> <td>MAGIC_RAW</td> <td>0x000100,</td> <td>Don&#39;t translate unprintable chars</td> </tr> <tr> <td>MAGIC_ERROR</td> <td>0x000200,</td> <td>Handle ENOENT etc as real errors</td> </tr> <tr> <td>MAGIC_MIME_ENCODING</td> <td>0x000400,</td> <td>Return the MIME encoding</td> </tr> <tr> <td>MAGIC_MIME</td> <td>0x000410,</td> <td>(MAGIC_MIME_TYPE|MAGIC_MIME_ENCODING)</td> </tr> <tr> <td>MAGIC_APPLE</td> <td>0x000800,</td> <td>Return the Apple creator and type</td> </tr> <tr> <td>MAGIC_NO_CHECK_COMPRESS</td> <td>0x001000,</td> <td>Don&#39;t check for compressed files</td> </tr> <tr> <td>MAGIC_NO_CHECK_TAR</td> <td>0x002000,</td> <td>Don&#39;t check for tar files</td> </tr> <tr> <td>MAGIC_NO_CHECK_SOFT</td> <td>0x004000,</td> <td>Don&#39;t check magic entries</td> </tr> <tr> <td>MAGIC_NO_CHECK_APPTYPE</td> <td>0x008000,</td> <td>Don&#39;t check application</td> </tr> <tr> <td>MAGIC_NO_CHECK_ELF</td> <td>0x010000,</td> <td>Don&#39;t check for elf details</td> </tr> <tr> <td>MAGIC_NO_CHECK_TEXT</td> <td>0x020000,</td> <td>Don&#39;t check for text files</td> </tr> <tr> <td>MAGIC_NO_CHECK_CDF</td> <td>0x040000,</td> <td>Don&#39;t check for cdf files</td> </tr> <tr> <td>MAGIC_NO_CHECK_TOKENS</td> <td>0x100000,</td> <td>Don&#39;t check tokens</td> </tr> <tr> <td>MAGIC_NO_CHECK_ENCODING</td> <td>0x200000,</td> <td>Don&#39;t check text encodings</td> </tr>
</tbody>
</table>

The flags may be set during construction by passing a :flag(WHATEVER) value in to the `.new( )` method, or may be adjusted later using the `.set-flags( )` method.

    method set-flags(int32 $flags = 0)

Allows modification of parameters after initialization.

    method type(Str $filename)
       or
    method type(IO::Handle $handle)
       or
    method type(Buf $buffer)

Try to detect file type of a given a file path/name or open file handle or string buffer.

    method version()

Return the current version. First digit is major version number, rest are minor.

--

There are several semi-private methods which mostly deal with initialization and setup. There is nothing preventing you from accesing them, they are publically available, but most people won't ever need to use them.

    method magic-database( str $magic-database, int32 $flags )

Location of the magic database file, pass Nil for default database. Pass any flags `or`ed together to adjust behavior.

    method magic-init (int32 $flags = 0)

Initialize the file-magic instance, allocate a data structure to hold information and return a pointer to it. Pointer is stored in the class as $!magic-cookie.

    method magic-load (Pointer $magic-struct, str $magicfile)

Load the database file into the data structure.

    method magic-error ()

Pass any errors back up to the calling code.

AUTHOR
======

2019 Steve Schulze aka thundergnat

This package is free software and is provided "as is" without express or implied warranty. You can redistribute it and/or modify it under the same terms as Perl itself.

LICENSE
=======

Licensed under The Artistic 2.0; see LICENSE.

