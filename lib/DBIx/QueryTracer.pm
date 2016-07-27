package DBIx::QueryTracer;
use 5.008001;
use strict;
use warnings;
use Clone 'clone';
use Guard 'guard';
use Devel::StackTrace;

our $VERSION = "0.01";
our $IS_TRACING = 0;
our $_DO;
our $_EXECUTE;
our @_QUERIES;
our @_SCOPE_QUERIES;

{
    no strict 'refs';
    no warnings 'redefine';
    $_DO         = clone(\&DBI::db::do);
    $_EXECUTE    = clone(\&DBI::st::execute);

    *DBI::st::execute = sub {
        my ($sth, @binds) = @_;
        if ($IS_TRACING) {
            push @DBIx::QueryTracer::_QUERIES, {
                trace     => Devel::StackTrace->new,
                method    => 'execute',
                statement => $sth->{Statement},
                binds     => [@binds], 
            };
        }
        $_EXECUTE->($sth, @binds);
    };

    *DBI::db::do = sub {
        my ($dbh, $statement, $attr, @binds) = @_;
        if ($IS_TRACING) {
            push @DBIx::QueryTracer::_QUERIES, {
                trace     => Devel::StackTrace->new,
                method    => 'do',
                statement => $statement,
                binds     => [@binds], 
                attr      => $attr,
            };
        }
        $_DO->($dbh, $statement, $attr, @binds);
    };
};

sub trace {
    $IS_TRACING = 1;
    @_QUERIES = ();
    @_SCOPE_QUERIES = ();
    my $guard = guard {
        @_SCOPE_QUERIES = @_QUERIES;
        $IS_TRACING = 0;
    };
    $guard;
}

sub queries {
    @_SCOPE_QUERIES;
}

sub count {
    scalar(shift->queries);
}

1;
__END__

=encoding utf-8

=head1 NAME

DBIx::QueryTracer - Query Tracer for DBI

=head1 SYNOPSIS

    use DBI;
    use DBIx::QueryTracer;
    my $dbh = DBI->connect(...);
    {
        DBIx::QueryTracer->trace;
        ### Throw any queries via $dbh
    };
    my $query_count = DBIx::QueryTracer->count;
    my @trace_data  = DBIx::QueryTracer->queries;


=head1 DESCRIPTION

DBIx::QueryTracer is a query tracer tool module.

=head1 METHODS

=over 4

=item trace

Return the guard object.

Tracing queries until the guard object become undef.

=item count

Return queries count that traced.

=item queries

Return queries information as hashref in perl array.

=back

=head1 LICENSE

Copyright (C) ytnobody.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=head1 AUTHOR

ytnobody E<lt>ytnobody@gmail.comE<gt>

=cut

