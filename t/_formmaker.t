use Test::More tests => 2;

use File::Temp ( 'tempdir' );
use Rose::DBx::TestDB;
use Path::Class;
use Rose::HTML::Form;
use Rose::DBx::Object::Loader::FormMaker

my $debug = $ENV{PERL_DEBUG} || 0;

my $db = Rose::DBx::TestDB->new;

# create a schema that tests out all our column types
#
ok( $db->dbh->do(
    qq{
        CREATE TABLE foo (
            id       integer primary key autoincrement,
            name     varchar(16),
            static   char(8),
            my_int   integer not null default 0,
            my_dec   float
        );
    }
),
    "table foo created"
);

ok(
my $formmaker = Rose::DBx::Object::Loader::FormMaker->new(
        db               => $db,
	class_prefix     => qq[Test::DB],
	form_prefix      => qq[Test::Form],

    )#;
    , "form maker object created" );

#print STDERR qq[$formmaker\n];
#print STDERR qq[i$!\n]

my $dir = tempdir('rdbolf_XXXX', CLEANUP => 1);


$formmaker->make_modules(module_dir => $dir);

sleep 60;
