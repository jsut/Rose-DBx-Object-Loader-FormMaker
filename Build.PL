use 5.008;
use strict;
use warnings;
use Module::Build;

my $build = Module::Build->new(
    module_name         => 'Rose::DBx::Object::Loader::FormMaker',
    license             => 'perl',
    create_readme       => 1,
    dist_author         => 'Adam Prime (adam.prime@utoronto.ca)',
    requires            => {
        'Rose::DB::Object::Loader' => '0',
        'Test::More'               => '0',
	'Rose::DBx::TestDB'        =>  0.04,
	'Path::Class'              =>  0,
    },
);

$build->create_build_script();
