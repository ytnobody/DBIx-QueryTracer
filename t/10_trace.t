use strict;
use Test::More;
use DBI;
use DBIx::QueryTracer;
use File::Temp 'tempdir';
use File::Spec;

my $tempdir = tempdir(CLEANUP => 1);
my $dbfile = File::Spec->catfile($tempdir, 'qctest.sqlite3');

my $dbh = DBI->connect("dbi:SQLite:database=$dbfile", "", "");
$dbh->do('CREATE table item (id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT)');

subtest 'trace and count, queries' => sub {
    {
        my $guard = DBIx::QueryTracer->trace;
        my $sth = $dbh->prepare('INSERT INTO item (name) VALUES (?)');
        for my $name (qw/foo bar baz/) {
            $sth->execute($name);
        }
        $dbh->do('SELECT * FROM item');
    }
    is(DBIx::QueryTracer->count, 4);
    my @queries = DBIx::QueryTracer->queries;
    is_deeply [map {$_->{statement}} @queries], [
        'INSERT INTO item (name) VALUES (?)',
        'INSERT INTO item (name) VALUES (?)',
        'INSERT INTO item (name) VALUES (?)',
        'SELECT * FROM item',
    ];

    is_deeply [map {$_->{binds}} @queries], [
        [qw/foo/], [qw/bar/], [qw/baz/], [],
    ];
    is_deeply [map {[$_->{trace}->frames]->[1]->filename} @queries], [
        map {"t/10_trace.t"} 1..4
    ];

    {
        my $guard = DBIx::QueryTracer->trace;
        my $sth = $dbh->prepare('SELECT * FROM item where id=?');
        my @rows;
        for my $id (1 .. 3) {
            $sth->execute($id);
            push @rows, $sth->fetchrow_hashref;
        }
        is_deeply \@rows, [
            {id => 1, name => 'foo'},
            {id => 2, name => 'bar'},
            {id => 3, name => 'baz'},
        ];
    }
    is(DBIx::QueryTracer->count, 3);

};

done_testing;
