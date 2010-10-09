use inc::Module::Install;
name 'KyotoTycoon';
all_from 'lib/KyotoTycoon.pm';

# requires '';
# requires 'Plack' =>  0.9949;

requires 'LWP::UserAgent';
requires 'URI::Escape';
requires 'MIME::QuotedPrint';
requires 'MIME::Base64';
requires 'Exporter' => 5.63; # use Exporter 'import';
requires 'parent';

test_requires 'Test::Requires';
test_requires 'Test::TCP';
test_requires 'File::Which';

readme_markdown_from 'lib/KyotoTycoon.pm';
tests 't/*.t t/*/*.t t/*/*/*.t t/*/*/*/*.t';
test_requires 'Test::More' => 0.96; # done_testing, subtest
author_tests('xt');
WriteAll;
