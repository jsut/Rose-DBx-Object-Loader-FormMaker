use strict;

use Test::More tests => 1;
use File::Path ();

BEGIN 
{
  use_ok('Rose::DBx::Object::Loader::FormMaker');
}

my $loader = Rose::DBx::Object::Loader::FormMaker->new(
                 db_dsn       => 'dbi:mysql:dbname=eat_local;host=localhost',
                 db_username  => 'perl',
                 db_password  => 'perl_4_woop',
                 db_options   => { AutoCommit => 1, ChopBlanks => 1 },
                 class_prefix => 'ACP::DB::',
                 form_prefix  => 'ACP::Form::',
);
print qq[sup\n];

File::Path::mkpath(qq[/tmp/_rdbolf]);

$loader->make_modules(module_dir => '/tmp/_rdbolf');


1;
