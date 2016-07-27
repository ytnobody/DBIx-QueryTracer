[![Build Status](https://travis-ci.org/ytnobody/DBIx-QueryTracer.svg?branch=master)](https://travis-ci.org/ytnobody/DBIx-QueryTracer) [![Coverage Status](https://img.shields.io/coveralls/ytnobody/DBIx-QueryTracer/master.svg?style=flat)](https://coveralls.io/r/ytnobody/DBIx-QueryTracer?branch=master)
# NAME

DBIx::QueryTracer - Query Tracer for DBI

# SYNOPSIS

    use DBI;
    use DBIx::QueryTracer;
    my $dbh = DBI->connect(...);
    {
        DBIx::QueryTracer->trace;
        ### Throw any queries via $dbh
    };
    my $query_count = DBIx::QueryTracer->count;
    my @trace_data  = DBIx::QueryTracer->queries;

# DESCRIPTION

DBIx::QueryTracer is a query tracer tool module.

# METHODS

- trace

    Return the guard object.

    Tracing queries until the guard object become undef.

- count

    Return queries count that traced.

- queries

    Return queries information as hashref in perl array.

# LICENSE

Copyright (C) ytnobody.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

# AUTHOR

ytnobody <ytnobody@gmail.com>
