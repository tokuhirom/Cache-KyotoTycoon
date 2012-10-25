use strict;
use warnings FATAL => 'all';
use Module::Build;

my $build = Module::Build->new(
    license              => 'perl',
    recursive_test_files => 1,
    dynamic_config       => 0,
    build_requires       => {
        'Test::Requires' => '0',
        'Test::More'     => '0.98',
        'Test::TCP'      => '1.17',
        'File::Which'    => '0'
    },
    configure_requires => { 'Module::Build' => '0.38' },
    requires           => {
        'perl'              => '5.008001',
        'URI::Escape'       => '0',
        'MIME::Base64'      => '0',
        'MIME::QuotedPrint' => '0',
        'Exporter'          => '0',
        'Furl'              => '1.00'
    },
    no_index    => { 'directory' => [ 'inc', 't', 'xt' ] },
    name        => 'Cache-KyotoTycoon',
    module_name => 'Cache::KyotoTycoon',

    test_files => ( -d '.git' || $ENV{RELEASE_TESTING} ) ? 't/ xt/' : 't/',

    create_readme  => 1,
    create_license => 1,
);
$build->create_build_script();
