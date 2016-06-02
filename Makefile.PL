use ExtUtils::MakeMaker;
WriteMakefile(
    'NAME'         => 'Sledge::Plugin::Mail',
    'VERSION_FROM' => 'lib/Sledge/Plugin/Mail.pm', # finds $VERSION
    'PREREQ_PM'    => {
        Class::Accessor => 0,
        Edge::Mailer    => 0,
        Test::More      => 0.32,
    },
);
