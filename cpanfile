requires 'perl', '5.008001';
requires 'Clone';
requires 'Guard';
requires 'Devel::StackTrace';

on 'test' => sub {
    requires 'Test::More', '0.98';
    requires 'DBI';
};


