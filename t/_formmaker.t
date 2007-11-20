use Test::More tests => 1;

use File::Temp ( 'tempdir' );
use Rose::DBx::TestDB;
use Path::Class;
use Rose::HTML::Form;

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
