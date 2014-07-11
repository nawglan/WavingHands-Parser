use strict;
use warnings;
use ExtUtils::MakeMaker;

WriteMakefile(
    NAME                => 'WavingHands::Parser',
    AUTHOR              => 'Desmond Daignault <nawglan@gmail.com>',
    VERSION_FROM        => 'lib/WavingHands/Parser.pm',
    ABSTRACT_FROM       => 'lib/WavingHands/Parser.pm',
    PERL_MALLOC_OK      => 1,
    PL_FILES            => {},
    PREREQ_FATAL        => 1,
    PREREQ_PM => {
        'JSON' => 0,
        'File::Spec' => 0,
        'List::Util' => 0,
        'Parse::RecDescent' => 0,
        'mop' => 0
    },
    TEST_REQUIRES => {
        'Test::More' => 0,
    },
    META_ADD            => {
        no_index => {
            directory => [qw( t/data )],
        },
    },
    META_MERGE          => {
        "meta-spec" => { version => 2 },
        resources => {
            repository => {
                type => 'git',
                url => 'git://github.com/nawglan/WavingHands-Parser.git',
                web => 'https://github.com/nawglan/WavingHands-Parser',
            },
        },
    },
    dist                => { COMPRESS => 'gzip -9f', SUFFIX => 'gz', },
    clean               => { FILES => 'WavingHands::Parser-*' },
);
