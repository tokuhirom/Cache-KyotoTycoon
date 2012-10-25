use inc::Module::Install;
name 'Cache-KyotoTycoon';
all_from 'lib/Cache/KyotoTycoon.pm';

requires 'Furl' => '1.00';
requires 'URI::Escape';
requires 'MIME::QuotedPrint';
requires 'MIME::Base64';
requires 'Exporter';

test_requires 'Test::Requires';
test_requires 'Test::TCP' => 1.17;
test_requires 'File::Which';

tests 't/*.t t/*/*.t t/*/*/*.t t/*/*/*/*.t';
test_requires 'Test::More' => 0.98; # done_testing, subtest
author_tests('xt');
WriteAll;
