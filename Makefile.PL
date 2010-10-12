use inc::Module::Install;
name 'Cache-KyotoTycoon';
all_from 'lib/Cache/KyotoTycoon.pm';

requires 'WWW::Curl::Easy';
requires 'URI::Escape';
requires 'MIME::QuotedPrint';
requires 'MIME::Base64';
requires 'Exporter';

test_requires 'Test::Requires';
test_requires 'Test::TCP';
test_requires 'File::Which';

readme_markdown_from 'lib/Cache/KyotoTycoon.pm';
tests 't/*.t t/*/*.t t/*/*/*.t t/*/*/*/*.t';
test_requires 'Test::More' => 0.96; # done_testing, subtest
author_tests('xt');
WriteAll;
